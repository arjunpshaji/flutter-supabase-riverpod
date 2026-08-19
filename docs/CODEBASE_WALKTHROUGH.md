# Codebase Walkthrough — Flutter + Supabase + Riverpod (codegen)

A bottom-up, layer-by-layer tour of this repository, written as a learning
reference. Read it alongside the source: every `file.dart:NN` reference points at
a real line, and the inline doc comments in the code repeat the key points where
you will actually need them.

**Contents**

0. [The one mental model](#0-the-one-mental-model-that-explains-everything)
1. [The tree, ordered by dependency direction](#1-the-tree-ordered-by-dependency-direction)
2. [Level 0 — `main.dart`, the boot sequence](#2-level-0--libmaindart-the-boot-sequence)
3. [Level 1 — `core/`, the seam](#3-level-1--core-the-seam)
4. [Level 2 — `auth_repository.dart`, the data layer](#4-level-2--auth_repositorydart-the-data-layer)
5. [Level 3 — `auth_result.dart`, the domain](#5-level-3--auth_resultdart-the-domain)
6. [Level 4 — presentation, and the split that matters most](#6-level-4--presentation-and-the-split-that-matters-most)
7. [Level 5 — `auth_gate.dart`, where it converges](#7-level-5--auth_gatedart-where-it-all-converges)
8. [Three traces, step by step](#8-three-traces-step-by-step)
9. [The codegen mental model](#9-the-codegen-mental-model)
10. [What is actually broken — exercise list](#10-what-is-actually-broken-your-exercise-list)

---

## 0. The one mental model that explains everything

This app has **no navigation logic**. That is the single idea the whole
architecture hangs off. Nobody calls `Navigator.push` after login. Instead:

> Supabase owns the session → a stream broadcasts it → one widget watches that
> stream → the screen you see is a *pure function* of the session.

Every other decision — why there is a repository, why two different auth
providers exist, why everything is an `AsyncValue` — follows from wanting that
sentence to stay true.

---

## 1. The tree, ordered by dependency direction

Arrows point **downward = "depends on"**. Nothing lower may import anything
higher. That rule is what makes the layering real rather than decorative.

```
lib/
│
├── main.dart ......................... LEVEL 0  boot + ProviderScope
│     └─ app/
│          └── auth_gate.dart ......... LEVEL 5  the router
│
├── core/ ............................. LEVEL 1  infrastructure, feature-agnostic
│   ├── supabase/supabase_client.dart ..... the injection point
│   └── validators/app_validator.dart ..... pure functions
│
└── features/
    ├── auth/
    │   ├── data/repositories/auth_repository.dart ..... LEVEL 2  talks to Supabase
    │   ├── domain/auth_result.dart ................... LEVEL 3  plain Dart, zero imports
    │   └── presentation/                               LEVEL 4
    │       ├── providers/auth_state_provider.dart ....   "who is logged in?"
    │       ├── viewmodels/auth_view_model.dart .......   "did my button work?"
    │       └── screens/{login,signup}_screen.dart ....   dumb-ish widgets
    │
    ├── home/presentation/screens/home_screen.dart
    └── notes/ ........................................ scaffolded, not wired
        ├── data/models/note_model.dart
        └── data/repositories/notes_repository.dart
```

**Test yourself:** open `auth_result.dart` — it has *zero* imports. That is not
laziness, it is the definition of a domain type. The day you add
`import 'package:supabase_flutter/...'` to it, the layering has broken.

---

## 2. LEVEL 0 — `lib/main.dart`, the boot sequence

`lib/main.dart:29` — `void main() async {`

The `async` is load-bearing. Three things must complete *before* the first widget
exists, and they must happen in this order:

| Line | Call | Why it must come first |
|---|---|---|
| 30 | `WidgetsFlutterBinding.ensureInitialized()` | `runApp()` normally does this. Because you `await` plugin work before `runApp`, you must bind the engine yourself. Remove it → *"Binding has not yet been initialized"*. |
| 32 | `await dotenv.load()` | Reads `.env` into a map. `.env` ships as a **Flutter asset** (declared in `pubspec.yaml`). Not magic — delete the asset entry and this throws in release builds while still working in debug. |
| 33 | `await Supabase.initialize(...)` | Creates `Supabase.instance.client`, **restores a persisted session from disk**, and starts the token-refresh timer. |

That middle capability in step 3 is worth pausing on. **It is why you stay logged
in across app restarts** and why not one line of your code does it. The SDK wrote
the session to local storage at login and reads it back here.

`lib/main.dart:34-35` — `dotenv.env['SUPABASE_URL']!`

The `!` is a deliberate crash. A typo'd env key becomes an immediate, obvious
`Null check operator` failure at launch rather than a mystifying 401 twenty
minutes into debugging. Fail fast, fail loud.

`lib/main.dart:55` — `ProviderScope`

Riverpod's storage. Every provider's state lives in this object. It must sit
above any widget that reads a provider — hence the root. **Providers are lazy:**
`supabaseClient(...)` at `supabase_client.dart:38` does not execute at startup.
It runs the first time something reads it, and the result is cached from then on.

`lib/main.dart:62` — `home: AuthGate()`

No `routes:` table, no `onGenerateRoute`. The first screen is a *decision*, not a
constant.

---

## 3. LEVEL 1 — `core/`, the seam

### `lib/core/supabase/supabase_client.dart:37-39`

```dart
@riverpod
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;
```

Nine words of code, and beginners always ask the same question: *`Supabase.instance.client`
is already a global singleton — why wrap it?*

Because a global is a hard dependency and a provider is a **seam**. Compare:

```dart
// Without the provider — untestable. This line reaches out to the real network.
class AuthRepository { final _client = Supabase.instance.client; }

// With it — one line swaps the whole backend out.
ProviderContainer(overrides: [supabaseClientProvider.overrideWithValue(fake)]);
```

That override is not hypothetical: `test/auth_view_model_test.dart` does exactly
this with `authRepositoryProvider`. **The reason this code is testable is that
repositories receive the client instead of fetching it.** Dependency injection
with no DI framework.

`lib/core/supabase/supabase_client.dart:10` — `part 'supabase_client.g.dart';`

Learn this contract now, because it is the #1 codegen error:

- `part` = "this file has a second half, written by a machine."
- The generated half declares `supabaseClientProvider`.
- Forget the `part` line → *"Undefined name supabaseClientProvider"*.
- Edit the `.g.dart` by hand → your changes vanish on the next build.

### `lib/core/validators/app_validator.dart`

`static` methods, no state, no dependencies — the easiest code in the repo to
test. The contract to memorize is **inverted**:

```dart
return null;              // ✅ valid
return "Email required";  // ❌ invalid — the string IS the error shown to the user
```

Every passing branch must return `null`. Forget one `else` and the field silently
reports failure forever.

Note the two shapes at the call site:

- `validator: AppValidator.email` — a **tear-off**. Works because the signature
  already is `String? Function(String?)`.
- `confirmPassword` takes two arguments, so it *cannot* be torn off; it needs a
  closure.

---

## 4. LEVEL 2 — `auth_repository.dart`, the data layer

`lib/features/auth/data/repositories/auth_repository.dart:19` — `class AuthRepository`

Notice what this class **does not** contain: no `try`/`catch`, no `isLoading`
flag, no user-facing strings. That is the discipline. Exceptions are allowed to
fly out and get caught exactly one layer up. Why? Because *the repository does
not know how a failure should look* — a snackbar? a red field? a retry? — so it
refuses to decide.

**The four methods, and what each one really does:**

`:40 signup()` — returns `AuthResponse`, and the interesting part is the branch
it forces on you:

| Result | Meaning |
|---|---|
| `response.session != null` | Email confirmation is **off** in your dashboard → user is already in |
| `response.session == null` | Confirmation is **on** → email sent, no session yet |

This is a Supabase *configuration* leaking into control flow, and it is precisely
why `AuthResult` exists (Level 3).

`:52 signin()` — bad credentials **throw** `AuthException`. They do not return an
empty response. Get this wrong and you will write a null check that never fires.

`:62 signout()` — clears the session, revokes the refresh token, and emits on the
stream. That emission is the entire logout implementation; see the trace in §8.

`:71 currentUser` — **synchronous**, reading the in-memory session. This tiny
detail powers the no-spinner cold start below.

`:80 authStateChanges` — `onAuthStateChange` fires on sign-in, sign-out, token
refresh, password recovery, and once at startup on session restore.

`:90-94` — the provider factory:

```dart
@riverpod
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.read(supabaseClientProvider));
```

**`ref.read` vs `ref.watch` inside a provider body** — the rule:

- `watch` → "if this dependency changes, rebuild me." Correct for anything dynamic.
- `read` → "grab it once." Correct here, because the Supabase client is fixed for
  the process lifetime. Watching it would only add churn.

---

## 5. LEVEL 3 — `auth_result.dart`, the domain

Twenty lines, three enum values, zero imports — and architecturally the most
significant file in the app.

```dart
if (response.session == null) { ... }                    // backend detail in your UI
if (result == AuthResult.verificationEmailSent) { ... }  // intent, in your language
```

The first version means every screen must understand Supabase's semantics. The
second means screens speak the app's own vocabulary. **Translation happens once,
in the view model.** As a bonus, `switch` over an enum is exhaustive: add a
fourth case and the analyzer walks you to every site needing an update.

---

## 6. LEVEL 4 — presentation, and the split that matters most

Here is the piece most people get wrong when learning Riverpod. There are **two**
auth providers and they are not redundant:

| | `authStateProvider` | `AuthViewModel` |
|---|---|---|
| Question | *Who is logged in?* | *Did the button I pressed work?* |
| Type | `AsyncValue<User?>` | `AsyncValue<AuthResult?>` |
| Source | Supabase's stream | Return value of the last action |
| Consumer | `AuthGate` only | Buttons and snackbars |
| Lifetime | Forever | Per action |

Session truth is **pushed** by the backend; action results are **pulled** by a
button press. Conflating them is how you end up with "logged in but stuck on the
login screen" bugs.

### `auth_state_provider.dart:31-38` — session truth

```dart
@riverpod
Stream<User?> authState(Ref ref) async* {
  final repository = ref.read(authRepositoryProvider);
  yield repository.currentUser;                      // ← line 34
  await for (final authState in repository.authStateChanges) {
    yield authState.session?.user;                   // ← line 36
  }
}
```

Four things happening in six lines:

1. **Returning `Stream<T>` from `@riverpod`** generates a *stream provider* —
   watching it yields `AsyncValue<User?>`, so loading/data/error are modelled for
   you.
2. **`async*` + `yield`** makes this a generator: it never returns, it emits.
3. **Line 34, the first yield, is the good idea.** It emits the *cached* user
   synchronously. Delete it and every cold start for a logged-in user shows a
   spinner flash before the stream's first event lands. This is why `currentUser`
   being synchronous (§4) mattered.
4. **Line 36 maps down**: `AuthState → Session? → User?`. On sign-out `session`
   is null, so this yields `null` — and that single null is what sends the user
   back to the login screen.

### `auth_view_model.dart` — the action state

`:27` — `class AuthViewModel extends _$AuthViewModel`

`@riverpod` on a **class** (not a function) generates a *Notifier*: the
`_$AuthViewModel` base you extend, plus `authViewModelProvider`. Two handles, and
the distinction is essential:

```dart
ref.watch(authViewModelProvider)           // the AsyncValue state  → for display
ref.read(authViewModelProvider.notifier)   // the instance itself   → for calling methods
```

`:36 build()` returns `null` — "no action attempted yet". That is why the type is
`AuthResult?`: `null` is a meaningful third state alongside data and error.
Riverpod wraps it in `AsyncData` for you.

`:53-55` — **the three-step mutation idiom**, repeated identically in all three
methods:

```dart
state = const AsyncLoading();               // 1. buttons disable this frame
state = await AsyncValue.guard(() async {   // 2. run it
  ...
});                                          // 3. result assigned back
```

`AsyncValue.guard` is the idiom to internalize. It runs your callback and:

- normal return → `AsyncData(value)`
- thrown exception → `AsyncError(error, stackTrace)`, stack preserved

**That is why this file contains no `try`/`catch` and why a wrong password cannot
crash the app** — the failure becomes a *state*, and states are renderable.

---

## 7. LEVEL 5 — `auth_gate.dart`, where it all converges

`lib/app/auth_gate.dart:29` — `final authState = ref.watch(authStateProvider);`

`ConsumerWidget` = `StatelessWidget` + a `WidgetRef`. `watch` subscribes: new
value → rebuild.

`:31-47` — `authState.when(...)` forces all three branches:

```
data(user)  → user == null ? LoginScreen : HomeScreen
error(e, s) → error text        (a real app maps this to a message + retry)
loading()   → CircularProgressIndicator
```

`AsyncValue` is a sealed union, so **you cannot forget the loading case** — the
type system will not let you. Compare with the `bool isLoading` + `String? error`
approach, where forgetting a combination is trivially easy.

---

## 8. Three traces, step by step

**A. Cold start, user was logged in yesterday**

```
1  main()                      Supabase.initialize restores session from disk
2  ProviderScope built         nothing runs yet — providers are lazy
3  AuthGate.build              ref.watch(authStateProvider) → provider WAKES UP
4  authState line 34           yield currentUser  → non-null, synchronously
5  AuthGate rebuild            data(user) → HomeScreen        ← no spinner
6  authState line 36           await for … keeps listening forever
```

**B. Sign in**

```
1  tap Login                   ref.read(...notifier).signin(...)
2  vm line 80                  state = AsyncLoading
3  LoginScreen rebuild         onPressed: null → button disabled, spinner shown
4  repository.signin           network call
5  Supabase                    session persisted to disk + pushed onto the stream
   ├─ 6a  authStateProvider    yields the new User
   │      AuthGate rebuild     → HomeScreen                   ← navigation, no Navigator
   └─ 6b  vm line 83           returns AuthResult.signedIn
          state = AsyncData    listenManual fires → snackbar
```

Steps 6a and 6b are **independent**. Navigation comes from the session stream;
the snackbar comes from the action result. Two consumers, one event, zero
coupling.

**C. Sign out** — `HomeScreen` calls `signOut()` → repository clears the session
→ stream emits `null` → `AuthGate` renders `LoginScreen`. `HomeScreen` never
mentions navigation.

---

## 9. The codegen mental model

Three generators, one command:

```
@riverpod   (riverpod_generator)  → *.g.dart          providers
@freezed    (freezed)             → *.freezed.dart    copyWith, ==, hashCode
@JsonKey…   (json_serializable)   → *.g.dart          fromJson / toJson
```

```powershell
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # while developing
```

**The naming rules** — memorize these two and codegen stops feeling like magic:

| You write | You get |
|---|---|
| `@riverpod` on function `fooBar` | `fooBarProvider`, value = return type, cached |
| `@riverpod` on class `FooBar` | `_$FooBar` base + `fooBarProvider` (a Notifier) |

**`note_model.dart` needs two `part` lines** because two generators write to it —
`.freezed.dart` *and* `.g.dart`. Miss either and the build fails.

And the Postgres ↔ Dart boundary, in `note_model.dart`:

```dart
@JsonKey(name: 'user_id') required String userId,
```

Supabase columns are `snake_case`; Dart fields are `camelCase`; **this project
has no global rename rule**, so every mismatched field needs its own annotation.
Miss one and `fromJson` throws at *runtime*, not compile time. Fields that
already match (`id`, `title`, `content`) need nothing.

`deletedAt` being nullable tells you the table uses **soft deletes** — rows get
marked, not removed — so queries must filter them out.

---

## 10. What is actually broken (your exercise list)

Each of these is documented in place in the source rather than fixed, on purpose.
Ordered by how much you will learn fixing them:

1. **`notes_repository.dart:56`** — `@riverpod` sits on a method *inside* the
   class, and the file has no `part` directive. Result: `notesRepositoryProvider`
   does not exist. The analyzer says it plainly: *"The annotation 'riverpod' can
   only be used on classes or top-level functions."* Fix = move it out + add the
   `part` line. **Best first exercise — it teaches the codegen contract by
   breaking it.**
2. **`auth_view_model.dart:82`** — `signin`'s guard callback has no `else`, so a
   null session falls through and returns `null`, producing `AsyncData(null)` —
   identical to "nothing happened yet". The UI shows *nothing*.
3. **`auth_view_model.dart:98`** — `signOut` has no re-entrancy guard, but
   `test/auth_view_model_test.dart` asserts one exists. That test fails today.
   Fix: early-return when `state.isLoading`.
4. **`signup_screen.dart`** — three leaked controllers (no `dispose`), a submit
   button that never disables (tap it 5× = 5 sign-up requests), and "Already a
   User? Sign In" navigating to `SignupScreen`.
5. **`login_screen.dart`** — password field missing `obscureText: true`; no
   `Form`/validators despite `AppValidator` existing; `super.dispose()` called
   before the controllers.
6. **`main.dart:5`** — unused import.

Two nits worth knowing: `EdgeInsetsGeometry.all(24)` works but the idiomatic call
is `EdgeInsets.all(24)`; and `HomeScreen`'s body is a `Padding` with no child —
that is the hole the notes list goes in.

**Suggested path:** fix #1 (learn codegen) → build a `notesProvider` streaming
from Supabase (learn stream providers + row-level security) → render it in
`HomeScreen` (learn `AsyncValue.when` on real data).

---

## Appendix — commands

```powershell
flutter pub get
flutter run                       # -d chrome | windows | <device id>
flutter analyze
flutter test
flutter test test/auth_view_model_test.dart           # single file
flutter test --plain-name "ignores repeated signOut"  # single test

dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs
```

**Known baseline:** both tests in `test/` currently fail —
`auth_view_model_test.dart` for reason #3 above, and `widget_test.dart` because
it pumps `MyApp` without the `dotenv` / `Supabase.initialize` setup that `main()`
performs. Neither failure is caused by your changes.
