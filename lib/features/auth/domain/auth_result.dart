/// Outcome of an auth action, expressed in the app's own vocabulary.
///
/// This lives in the **domain** layer, which holds plain Dart types with no
/// Supabase or Flutter imports. The point is decoupling: screens react to
/// [AuthResult] and never need to know that "no session came back from signUp"
/// is Supabase's way of saying "check your inbox".
///
/// Compare the two shapes:
/// ```dart
/// if (response.session == null) { ... }                    // leaks backend detail into the UI
/// if (result == AuthResult.verificationEmailSent) { ... }  // intent is explicit
/// ```
///
/// Because it is an enum, `switch` over it is exhaustive — add a case and the
/// analyzer points at every place that needs updating.
enum AuthResult{
  /// A session exists; `AuthGate` will show the home screen.
  signedIn,

  /// Sign-up succeeded but Supabase requires email confirmation first, so there
  /// is no session yet. The user stays on the sign-up screen.
  verificationEmailSent,

  /// The session was cleared; `AuthGate` falls back to the login screen.
  signedOut
}
