# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app (Dart 3.12 / Flutter 3.44 stable) using Supabase for auth and data, Riverpod for state, all wired through code generation. Not a git repository.

`docs/CODEBASE_WALKTHROUGH.md` is a layer-by-layer tour of the architecture with line references, runtime traces, and a list of known defects — useful background before changing auth or the provider wiring.

## Commands

```powershell
flutter pub get
flutter run                       # -d chrome | windows | <device id>
flutter analyze                   # lint (flutter_lints ^6.0.0)
flutter test
flutter test test/auth_view_model_test.dart          # single file
flutter test --plain-name "ignores repeated signOut" # single test by name

# Code generation — REQUIRED after touching any @riverpod / @freezed / @JsonSerializable code
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # during active dev
```

**Baseline: both tests in `test/` currently fail.** `auth_view_model_test.dart` asserts that `AuthViewModel.signOut()` ignores re-entrant calls while one is in flight — that guard is not implemented. `widget_test.dart` pumps `MyApp` directly, which fails because `main()`'s `dotenv.load()` / `Supabase.initialize()` never ran. Don't assume a failure here was caused by your change; check against this baseline first.

## Configuration

Supabase credentials live in `.env` at the repo root (`SUPABASE_URL`, `SUPABASE_ANON_KEY`), loaded by `flutter_dotenv` in `main()` and declared as a Flutter asset in `pubspec.yaml`. `.env` is **not** in `.gitignore` — check before adding version control. Missing/renamed keys crash at startup via the `!` null assertions in `main.dart`.

## Architecture

Feature-first layering under `lib/`:

- `core/` — cross-feature infrastructure. `core/supabase/supabase_client.dart` exposes the single `supabaseClientProvider` (wraps `Supabase.instance.client`); every repository takes its `SupabaseClient` from there. `core/validators/app_validator.dart` holds static form validators.
- `features/<name>/data/` — `repositories/` (thin wrappers over the Supabase SDK) and `models/` (Freezed + json_serializable).
- `features/<name>/domain/` — plain Dart types, e.g. `AuthResult` enum.
- `features/<name>/presentation/` — `screens/`, `viewmodels/` (`@riverpod` notifiers), `providers/` (stream/derived providers).
- `app/auth_gate.dart` — root router. Watches `authStateProvider` and switches between `LoginScreen` and `HomeScreen`; there is no named-route table or router package, screen-to-screen moves use `Navigator.pushAndRemoveUntil`.

### State flow

`AuthRepository` exposes Supabase's `onAuthStateChange`. `authStateProvider` (`Stream<User?>`) yields the current user first, then every subsequent session user — this is the source of truth for "am I logged in", and `AuthGate` is its only consumer. Separately, `AuthViewModel` (`AsyncValue<AuthResult?>`) is the *action* state: screens call `signUp`/`signin`/`signOut` on it, read `.isLoading` for button state, and `ref.listen` for one-shot UI (snackbars, banners) keyed off the `AuthResult` value. Keep that split — session truth in `authStateProvider`, transient operation results in the view model. All view-model mutations go through `AsyncValue.guard` so Supabase exceptions land in the error state rather than propagating.

`signUp` returning a null session means Supabase requires email confirmation, which is why it maps to `AuthResult.verificationEmailSent` rather than `signedIn`.

### Code generation conventions

Generated `*.g.dart` / `*.freezed.dart` files sit next to their source and are checked in — never hand-edit them; change the annotated source and rerun build_runner. Every file with an annotation needs its matching `part '<file>.g.dart';` directive. `@riverpod` on a function named `fooBar` generates `fooBarProvider`; on a class `FooBar` it generates `fooBarProvider` plus the `_$FooBar` base class.

Supabase column names are snake_case and map to camelCase Dart fields via explicit `@JsonKey(name: 'user_id')` annotations (see `NoteModel`) — there is no global field-rename config.

### Notes feature (incomplete)

`features/notes/` is scaffolded but not wired up: `NotesRepository` has its `@riverpod` factory declared *inside* the class body and the file lacks a `part` directive, so no `notesRepositoryProvider` is generated. Fix by moving the annotated function to top level and adding the part directive before building on it. `NoteModel` implies a `notes` table with `id, user_id, title, content, created_at, updated_at, deleted_at` (soft delete).
