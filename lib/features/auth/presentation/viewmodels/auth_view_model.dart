import 'package:flutter_supabase/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_supabase/features/auth/domain/auth_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'auth_view_model.g.dart';

/// Drives the auth **actions** the UI can trigger: sign up, sign in, sign out.
///
/// Its state is `AsyncValue<AuthResult?>`, which screens use two ways:
/// * `ref.watch(...).isLoading` — to disable buttons and show a spinner.
/// * `ref.listen(...)` — to fire one-shot UI (snackbar, banner) when a specific
///   [AuthResult] arrives.
///
/// It is **not** the source of truth for "am I logged in" — that is
/// `authStateProvider`. This class only reports how the last operation went,
/// while the session stream independently drives navigation. That split is why
/// no screen has to push or pop a route after a successful login.
///
/// ## What the codegen produces
/// `@riverpod` on a **class** generates a Notifier: the `_$AuthViewModel` base
/// class this extends, plus `authViewModelProvider`. Two ways to reach it:
/// * `ref.watch(authViewModelProvider)` → the current `AsyncValue` state;
/// * `ref.read(authViewModelProvider.notifier)` → this instance, to call methods.
///
/// Inside a Notifier, `ref` is a field (no need to pass it around) and `state`
/// is the read/write property whose assignment notifies listeners.
@riverpod
class AuthViewModel extends _$AuthViewModel {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  /// Builds the initial state; called lazily on first read.
  ///
  /// `null` means "no auth action attempted yet" — distinct from a completed
  /// action, which is why the type is `AuthResult?` and not `AuthResult`.
  /// Riverpod wraps this return value in `AsyncData` automatically.
  @override
  FutureOr<AuthResult?> build() {
    return null;
  }

  /// Registers a new account.
  ///
  /// Every mutation in this class follows the same three-step shape:
  /// 1. set `AsyncLoading` so buttons disable immediately;
  /// 2. run the call inside [AsyncValue.guard];
  /// 3. assign the result back to `state`.
  ///
  /// [AsyncValue.guard] is the key idiom: it runs the callback, wraps a normal
  /// return in `AsyncData` and any thrown exception in `AsyncError` (preserving
  /// the stack trace). That is why there is no try/catch anywhere here, and why
  /// a wrong password can never crash the app — it becomes an error state the UI
  /// can render.
  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _repository.signup(email: email, password: password);

      // A session means email confirmation is disabled — the user is already in.
      if(response.session != null){
        return AuthResult.signedIn;
      }

      // No session means Supabase sent a confirmation email instead.
      return AuthResult.verificationEmailSent;

    });
  }

  /// Signs an existing user in.
  ///
  /// Wrong credentials throw [AuthException] inside the guard, so the state
  /// becomes `AsyncError` and the screen can surface the message.
  ///
  /// LEARNING NOTE: the callback has no `else` branch, so when `session` is null
  /// it falls off the end and implicitly returns `null` — the state becomes
  /// `AsyncData(null)`, indistinguishable from the initial state, and the UI
  /// shows nothing at all. Returning an explicit [AuthResult] (or throwing) on
  /// that path would make the outcome unambiguous.
  Future<void> signin({required String email, required String password}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _repository.signin(email: email, password: password);

      if(response.session != null){
        return AuthResult.signedIn;
      }
    });
  }

  /// Clears the session. `AuthGate` reacts via `authStateProvider` and returns
  /// the user to the login screen — no navigation call needed here.
  ///
  /// LEARNING NOTE: `test/auth_view_model_test.dart` expects a second call made
  /// while one is already in flight to be ignored, but nothing guards against
  /// re-entry, so that test currently fails. The usual fix is an early return
  /// when `state.isLoading` is already true.
  Future<void> signOut() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.signout();
      return AuthResult.signedOut;
    });
  }
}
