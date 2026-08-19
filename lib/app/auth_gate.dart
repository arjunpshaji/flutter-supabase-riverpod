import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_supabase/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_supabase/features/auth/presentation/providers/auth_state_provider.dart';

/// Decides which screen the user sees, based on whether a session exists.
///
/// This is the app's de-facto router. Instead of pushing and popping routes on
/// login and logout, the widget tree simply *reacts* to the auth stream: when
/// Supabase reports a new session the gate rebuilds and swaps [LoginScreen] for
/// [HomeScreen] (and back again on sign-out). No navigation code required.
///
/// [ConsumerWidget] is Riverpod's version of [StatelessWidget] — identical,
/// except `build` receives a [WidgetRef] used to talk to providers.
///
/// `ref.watch` **subscribes**: this widget rebuilds every time the provider
/// emits a new value. Use `watch` for anything the UI displays, and `ref.read`
/// only for one-off actions inside callbacks (see [HomeScreen]).
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // authStateProvider is a *stream* provider, so watching it yields an
    // AsyncValue<User?> — a union of loading / data / error. Riverpod forces us
    // to handle all three, which is why there is no "is it still loading?"
    // boolean to forget about.
    final authState = ref.watch(authStateProvider);
    return authState.when(
      // data: the stream emitted a value. A null user means "no session".
      data: (user) {
        if (user == null) {
          return LoginScreen();
        } else {
          return HomeScreen();
        }
      },
      // error: the stream threw. Shown raw here; a production app would map it
      // to a friendly message plus a retry button.
      error: (error, stackTrace) {
        return Scaffold(body: Center(child: Text(error.toString())));
      },
      // loading: the first frame, before the stream has emitted anything.
      loading: () {
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
