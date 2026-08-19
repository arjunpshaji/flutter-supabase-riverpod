import 'package:flutter_supabase/features/auth/data/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state_provider.g.dart';

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
@riverpod
Stream<User?> authState(Ref ref) async* {
  final repository = ref.read(authRepositoryProvider);

  yield repository.currentUser;
  await for (final authState in repository.authStateChanges) {
    yield authState.session?.user;
  }
}
