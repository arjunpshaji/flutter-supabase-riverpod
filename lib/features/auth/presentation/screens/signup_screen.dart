import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase/core/validators/app_validator.dart';
import 'package:flutter_supabase/features/auth/domain/auth_result.dart';
import 'package:flutter_supabase/features/auth/presentation/viewmodels/auth_view_model.dart';

/// Account registration screen.
///
/// Compared with `LoginScreen` this one demonstrates the full validated-form
/// pattern: a [Form] with a [GlobalKey], [TextFormField]s wired to
/// [AppValidator], and a submit handler that refuses to call the network until
/// `validate()` passes.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  // `late final` with an initialiser gives lazy creation: the controller is
  // built on first access and can never be reassigned.
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  late final TextEditingController _confirmPasswordController =
      TextEditingController();

  /// Handle to the [Form]'s state, so the button can call `validate()` without
  /// holding a reference to the widget itself.
  late final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Shows a banner once sign-up reports that a confirmation email went out.
    //
    // `ref.listen` must be called *during build*: Riverpod re-registers the
    // subscription on every rebuild and tears it down with the element. Calling
    // it from `initState` throws at runtime — use `ref.listenManual` if you
    // really need to subscribe outside build (see LoginScreen).
    //
    // Why listen rather than watch? Showing a banner is a side effect, and
    // `listen` fires only on an actual state *change*, so an unrelated rebuild
    // will not show it twice.
    ref.listen(authViewModelProvider, (p, n) {
      n.whenOrNull(
        data: (result) {
          if (result == AuthResult.verificationEmailSent) {
            ScaffoldMessenger.of(context).showMaterialBanner(
              MaterialBanner(
                content: Text("Verification email sent"),
                actions: [
                  TextButton(
                    onPressed: ScaffoldMessenger.of(context).hideCurrentMaterialBanner,
                    child: Text("Dismiss"),
                  ),
                ],
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        // A Form renders nothing itself; it coordinates the fields beneath it so
        // that one `validate()` call runs every child validator at once.
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tear-off: AppValidator.email already matches the expected
              // `String? Function(String?)` signature, so no closure is needed.
              TextFormField(
                controller: _emailController,
                validator: AppValidator.email,
              ),
              SizedBox(height: 12),
              TextFormField(
                obscureText: true,
                controller: _passwordController,
                validator: AppValidator.password,
              ),
              SizedBox(height: 12),
              TextFormField(
                obscureText: true,
                controller: _confirmPasswordController,
                // This one needs the other field's text, so it is written
                // inline. LEARNING NOTE: AppValidator.confirmPassword already
                // does exactly this and would keep the rules in one place:
                //   validator: (v) => AppValidator.confirmPassword(
                //       v, _passwordController.text),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return "Password required";
                  } else if (_passwordController.text != value) {
                    return "Pasword and confirm password must be same";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                // LEARNING NOTE: unlike LoginScreen this button is never
                // disabled while loading, so it can be tapped repeatedly and
                // fire several sign-up requests. Watching
                // `authViewModelProvider` and checking `isLoading` fixes it.
                onPressed: () {
                  // `validate()` runs every child validator and repaints their
                  // error text; it returns true only when all returned null.
                  final bool isValid =
                      _formKey.currentState?.validate() ?? false;

                  if (!isValid) {
                    return;
                  } else {
                    ref
                        .read(authViewModelProvider.notifier)
                        .signUp(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                  }
                },
                child: Text("Signup"),
              ),
              SizedBox(height: 8),
              TextButton(
                // LEARNING NOTE: the label says "Already a User? Sign In" but
                // this pushes SignupScreen again — it should go to LoginScreen.
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                    (x) => false,
                  );
                },
                child: Text("Already a User? Sign In"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
