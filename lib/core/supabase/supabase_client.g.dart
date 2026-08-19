// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(supabaseClient)
final supabaseClientProvider = SupabaseClientProvider._();

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

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
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
  SupabaseClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$supabaseClientHash() => r'834a58d6ae4b94e36f4e04a10d8a7684b929310e';
