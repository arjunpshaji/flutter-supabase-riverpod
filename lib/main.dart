import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase/app/auth_gate.dart';
import 'package:flutter_supabase/features/auth/presentation/screens/signup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Entry point of the application.
///
/// This function is `async` and does real work *before* [runApp], which is why
/// the setup order matters:
///
/// 1. [WidgetsFlutterBinding.ensureInitialized] — normally `runApp` binds the
///    Flutter engine for you. Because we `await` plugin work (asset loading,
///    platform channels) before `runApp`, we must bind it ourselves first.
///    Skipping this line throws "Binding has not yet been initialized".
/// 2. `dotenv.load()` — reads the `.env` file into the `dotenv.env` map. `.env`
///    is bundled as a Flutter **asset** (see `flutter: assets:` in
///    pubspec.yaml); without that entry the file is not shipped and this throws.
/// 3. [Supabase.initialize] — builds the process-wide singleton
///    `Supabase.instance.client`. It also restores any session persisted on the
///    device from a previous launch and starts the token auto-refresh timer.
///    That is why a logged-in user stays logged in across app restarts without
///    any code from us.
///
/// The `!` null assertions on the env lookups are deliberate fail-fast
/// behaviour: a missing or misspelled key should crash loudly at launch rather
/// than show up later as a confusing 401 from the API.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(MyApp());
}

/// The root widget of the app.
///
/// [ProviderScope] is where Riverpod stores the state of every provider. It has
/// to sit **above** any widget that reads a provider, so in practice it wraps
/// the whole app. Providers are created lazily — a provider's body does not run
/// until something reads it for the first time.
///
/// [MaterialApp.home] is [AuthGate] rather than a concrete screen: this app has
/// no route table, so "which screen do I show first?" is decided reactively from
/// the auth state instead of imperatively at startup.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Supabase',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: AuthGate(),
      ),
    );
  }
}
