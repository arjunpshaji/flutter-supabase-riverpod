import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Every file that uses code generation needs a `part` directive naming the file
// the generator will write. The generated half declares `supabaseClientProvider`
// and the private `_$supabaseClientHash` used for hot reload. Regenerate with:
//     dart run build_runner build --delete-conflicting-outputs
// Never edit the .g.dart file by hand — it is overwritten on every build.
part 'supabase_client.g.dart';

/// The single [SupabaseClient] used by the whole app.
///
/// `Supabase.instance.client` is already a global singleton created in `main()`,
/// so why wrap it in a provider at all? Because a provider is an **injection
/// point**. Every repository depends on `supabaseClientProvider` rather than on
/// the global, which means a test can swap in a fake with one line:
///
/// ```dart
/// ProviderContainer(
///   overrides: [supabaseClientProvider.overrideWithValue(fakeClient)],
/// );
/// ```
///
/// Reaching for the global directly inside repositories would make them
/// impossible to test without a live network connection.
///
/// ## How the codegen naming works
/// `@riverpod` on a **function** named `supabaseClient` generates a provider
/// called `supabaseClientProvider`, whose value is this function's return type.
/// The function runs once, lazily, and the result is cached for the life of the
/// [ProviderScope]. (`@riverpod` on a *class* generates a Notifier instead — see
/// `AuthViewModel`.)
///
/// [Ref] is the handle a provider uses to read other providers, register
/// teardown (`ref.onDispose`), and control caching (`ref.keepAlive`).
@riverpod
SupabaseClient supabaseClient(Ref ref){
  return Supabase.instance.client;
}
