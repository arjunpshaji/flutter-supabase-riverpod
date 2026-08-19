// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The currently signed-in [User], or `null` when nobody is signed in.
///
/// This is the app's **session truth**, and `AuthGate` is its only consumer.
/// Keep it separate from `AuthViewModel`: this provider answers "who is logged
/// in?", while the view model answers "did the button I just pressed succeed?".
/// Merging the two is the usual way auth state gets tangled.
///
/// ## Why `async*` and two yields
/// Returning a `Stream<User?>` from an `@riverpod` function generates a *stream
/// provider*, so watching it gives an `AsyncValue<User?>` with loading / data /
/// error branches already modelled.
///
/// The first `yield` emits the **cached** user synchronously. Without it the UI
/// would sit in `AsyncLoading` until Supabase's stream pushed its first event —
/// a visible spinner flash on every cold start for an already-logged-in user.
///
/// The `await for` then relays every subsequent change indefinitely. `async*`
/// keeps the generator alive; Riverpod cancels the subscription automatically
/// once the last listener goes away.
///
/// `authState.session?.user` maps Supabase's event object down to just the user:
/// on sign-out `session` is null, so this yields `null` and `AuthGate` returns
/// to the login screen.

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// The currently signed-in [User], or `null` when nobody is signed in.
///
/// This is the app's **session truth**, and `AuthGate` is its only consumer.
/// Keep it separate from `AuthViewModel`: this provider answers "who is logged
/// in?", while the view model answers "did the button I just pressed succeed?".
/// Merging the two is the usual way auth state gets tangled.
///
/// ## Why `async*` and two yields
/// Returning a `Stream<User?>` from an `@riverpod` function generates a *stream
/// provider*, so watching it gives an `AsyncValue<User?>` with loading / data /
/// error branches already modelled.
///
/// The first `yield` emits the **cached** user synchronously. Without it the UI
/// would sit in `AsyncLoading` until Supabase's stream pushed its first event —
/// a visible spinner flash on every cold start for an already-logged-in user.
///
/// The `await for` then relays every subsequent change indefinitely. `async*`
/// keeps the generator alive; Riverpod cancels the subscription automatically
/// once the last listener goes away.
///
/// `authState.session?.user` maps Supabase's event object down to just the user:
/// on sign-out `session` is null, so this yields `null` and `AuthGate` returns
/// to the login screen.

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  /// The currently signed-in [User], or `null` when nobody is signed in.
  ///
  /// This is the app's **session truth**, and `AuthGate` is its only consumer.
  /// Keep it separate from `AuthViewModel`: this provider answers "who is logged
  /// in?", while the view model answers "did the button I just pressed succeed?".
  /// Merging the two is the usual way auth state gets tangled.
  ///
  /// ## Why `async*` and two yields
  /// Returning a `Stream<User?>` from an `@riverpod` function generates a *stream
  /// provider*, so watching it gives an `AsyncValue<User?>` with loading / data /
  /// error branches already modelled.
  ///
  /// The first `yield` emits the **cached** user synchronously. Without it the UI
  /// would sit in `AsyncLoading` until Supabase's stream pushed its first event —
  /// a visible spinner flash on every cold start for an already-logged-in user.
  ///
  /// The `await for` then relays every subsequent change indefinitely. `async*`
  /// keeps the generator alive; Riverpod cancels the subscription automatically
  /// once the last listener goes away.
  ///
  /// `authState.session?.user` maps Supabase's event object down to just the user:
  /// on sign-out `session` is null, so this yields `null` and `AuthGate` returns
  /// to the login screen.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'244eebc08122f5974ff154dea03f9c64638de481';
