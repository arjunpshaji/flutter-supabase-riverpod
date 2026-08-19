import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase/features/auth/domain/auth_result.dart';
import 'package:flutter_supabase/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutter_supabase/features/auth/presentation/viewmodels/auth_view_model.dart';

/// Email + password sign-in screen.
///
/// [ConsumerStatefulWidget] is Riverpod's [StatefulWidget]: needed here because
/// [TextEditingController]s are mutable objects that must survive rebuilds and
/// then be disposed. In the [ConsumerState] below, `ref` is available everywhere
/// as a field — including `initState` and `dispose` — not just in `build`.
///
/// Notice this screen never navigates after a successful login. Supabase pushes
/// the new session onto `authStateProvider`, `AuthGate` rebuilds, and the login
/// screen is simply replaced. State drives navigation, not the other way round.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    // `listenManual` is the variant allowed *outside* build. Plain `ref.listen`
    // must be called during build (Riverpod re-registers it on every rebuild);
    // `listenManual` sets up the subscription once and ties it to this State's
    // lifecycle instead.
    //
    // Why listen rather than watch? Showing a snackbar is a side effect, and
    // side effects must not run inside build — a rebuild for any unrelated
    // reason would fire the snackbar again. `listen` runs the callback only on
    // an actual state *change*.
    //
    // `whenOrNull` handles just the branch we care about and ignores loading and
    // error, instead of forcing all three like `when` does.
    ref.listenManual(authViewModelProvider, (p, n) {
      n.whenOrNull(
        data: (result) {
          if (result == AuthResult.signedIn) {
            return ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Successfully Signed in")));
          }
        },
      );
    });
  }

  @override
  void dispose() {
    // LEARNING NOTE: convention is to dispose your own objects *first* and call
    // `super.dispose()` last, because the base class tears down the element this
    // State still belongs to. It happens to work here, but controllers-then-super
    // is the order you will see everywhere else.
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watched (not read) so the button rebuilds the moment the request starts
    // and again when it finishes.
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.all(24),
        child: Column(
          children: [
            // LEARNING NOTE: unlike SignupScreen these are plain TextFields with
            // no Form and no validators, so an empty email reaches Supabase and
            // fails server-side. TextFormField + AppValidator inside a Form
            // would catch it before the network call.
            TextField(
              controller: _emailController,
              decoration: InputDecoration(label: Text("Email")),
            ),
            SizedBox(height: 16),
            // LEARNING NOTE: missing `obscureText: true`, so the password is
            // typed in the clear here (SignupScreen sets it correctly).
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(label: Text("Password")),
            ),
            SizedBox(height: 18),
            ElevatedButton(
              // A null `onPressed` is what actually disables a button in
              // Flutter — this is the guard against double submission.
              onPressed: authState.isLoading
                  ? null
                  : () {
                      // `ref.read` inside a callback: we want the notifier once,
                      // to call a method on it. `watch` here would subscribe the
                      // callback to rebuilds, which makes no sense for an action.
                      ref
                          .read(authViewModelProvider.notifier)
                          .signin(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                    },
              child: authState.isLoading
                  ? CircularProgressIndicator()
                  : Text("Login"),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // `pushAndRemoveUntil` with an always-false predicate clears the
                // entire stack, so sign-up *replaces* login rather than stacking
                // on top of it — no back button returning to a half-filled form.
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                  (x) => false,
                );
              },
              child: Text("New User? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
