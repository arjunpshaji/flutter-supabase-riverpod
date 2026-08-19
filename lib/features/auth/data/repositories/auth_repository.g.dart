// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the app-wide [AuthRepository], wired to the shared Supabase client.
///
/// `ref.read` is used instead of `ref.watch` because `supabaseClientProvider`
/// never changes after startup — there is nothing to react to, so rebuilding
/// this repository would be pointless churn. Inside a provider body, prefer
/// `ref.watch` for dependencies that *can* change and `ref.read` for ones that
/// genuinely cannot.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Provides the app-wide [AuthRepository], wired to the shared Supabase client.
///
/// `ref.read` is used instead of `ref.watch` because `supabaseClientProvider`
/// never changes after startup — there is nothing to react to, so rebuilding
/// this repository would be pointless churn. Inside a provider body, prefer
/// `ref.watch` for dependencies that *can* change and `ref.read` for ones that
/// genuinely cannot.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Provides the app-wide [AuthRepository], wired to the shared Supabase client.
  ///
  /// `ref.read` is used instead of `ref.watch` because `supabaseClientProvider`
  /// never changes after startup — there is nothing to react to, so rebuilding
  /// this repository would be pointless churn. Inside a provider body, prefer
  /// `ref.watch` for dependencies that *can* change and `ref.read` for ones that
  /// genuinely cannot.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'15f23dab58620a6354124a0e21df7cbc08a8890d';
