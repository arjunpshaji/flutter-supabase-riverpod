import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase/features/auth/presentation/viewmodels/auth_view_model.dart';

/// The screen shown once a session exists. Currently just a sign-out button —
/// this is where the notes feature is meant to land.
///
/// [ConsumerWidget] rather than the stateful variant because nothing here is
/// mutable: the only interaction delegates straight to a provider.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            onPressed: () {
              // Textbook `ref.read`: fire an action once, in response to a tap.
              // `.notifier` gets the AuthViewModel instance itself rather than
              // its state, which is what lets us call methods on it.
              //
              // No Navigator call afterwards — signing out clears the session,
              // `authStateProvider` emits null, and AuthGate swaps this screen
              // for LoginScreen on its own.
              ref.read(authViewModelProvider.notifier).signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      // An empty Padding with no child: the notes list goes here.
      body: Padding(padding: EdgeInsetsGeometry.all(24)),
    );
  }
}
