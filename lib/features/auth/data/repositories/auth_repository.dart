import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase/core/supabase/supabase_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository.g.dart';

/// Thin wrapper around Supabase Auth (GoTrue).
///
/// This is the **data layer**: it knows about Supabase types and nothing about
/// widgets or Riverpod. Its job is to be the single place the rest of the app
/// touches authentication, so swapping Supabase for another backend later means
/// rewriting this class only.
///
/// Note what it deliberately does *not* do: no try/catch, no loading flags, no
/// mapping to UI strings. Errors propagate as [AuthException]s and are caught
/// one layer up by `AuthViewModel`'s `AsyncValue.guard`. Keeping error handling
/// out of the repository lets each caller decide how a failure is presented.
class AuthRepository {

  AuthRepository(this._client);

  /// Injected rather than read from `Supabase.instance` directly — that is what
  /// makes this class testable (see `test/auth_view_model_test.dart`).
  final SupabaseClient _client;

  /// GoTrue is Supabase's auth service; `client.auth` is its Dart handle.
  GoTrueClient get _auth => _client.auth;

  /// Creates a new account.
  ///
  /// The returned [AuthResponse] tells you which flow you are in:
  /// * `response.session != null` — email confirmation is **off** in the
  ///   Supabase dashboard, so the user is signed in immediately.
  /// * `response.session == null` — confirmation is **on**; Supabase sent a
  ///   verification email and no session exists until the user clicks the link.
  ///
  /// `AuthViewModel.signUp` turns that distinction into an `AuthResult` the UI
  /// can act on.
  Future<AuthResponse> signup({
    required String email,
    required String password,
  }) {
    return _auth.signUp(email: email, password: password);
  }

  /// Signs an existing user in with email + password.
  ///
  /// On success the SDK persists the session to device storage and pushes it
  /// onto [authStateChanges]. Wrong credentials **throw** an [AuthException]
  /// rather than returning an empty response.
  Future<AuthResponse> signin({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(password: password, email: email);
  }

  /// Clears the local session and revokes the refresh token, then emits a
  /// signed-out event on [authStateChanges] — which is what makes `AuthGate`
  /// swap back to the login screen.
  Future<void> signout() {
    return _auth.signOut();
  }

  /// The cached user, read synchronously from the in-memory session.
  ///
  /// Being synchronous makes it safe to call during the first frame, which is
  /// what lets `authStateProvider` answer "logged in?" immediately instead of
  /// flashing a spinner while the stream warms up.
  User? get currentUser => _auth.currentUser;

  /// The cached session, including the JWT and its expiry.
  Session? get currentSession => _auth.currentSession;

  /// Fires on every auth change: sign-in, sign-out, token refresh, password
  /// recovery, and once at startup when a stored session is restored.
  ///
  /// This stream is the app's source of truth for "is someone logged in".
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;
}

/// Provides the app-wide [AuthRepository], wired to the shared Supabase client.
///
/// `ref.read` is used instead of `ref.watch` because `supabaseClientProvider`
/// never changes after startup — there is nothing to react to, so rebuilding
/// this repository would be pointless churn. Inside a provider body, prefer
/// `ref.watch` for dependencies that *can* change and `ref.read` for ones that
/// genuinely cannot.
@riverpod
AuthRepository authRepository(Ref ref){
  return AuthRepository(
    ref.read(supabaseClientProvider),
  );
}
