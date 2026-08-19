// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the auth **actions** the UI can trigger: sign up, sign in, sign out.
///
/// Its state is `AsyncValue<AuthResult?>`, which screens use two ways:
/// * `ref.watch(...).isLoading` — to disable buttons and show a spinner.
/// * `ref.listen(...)` — to fire one-shot UI (snackbar, banner) when a specific
///   [AuthResult] arrives.
///
/// It is **not** the source of truth for "am I logged in" — that is
/// `authStateProvider`. This class only reports how the last operation went,
/// while the session stream independently drives navigation. That split is why
/// no screen has to push or pop a route after a successful login.
///
/// ## What the codegen produces
/// `@riverpod` on a **class** generates a Notifier: the `_$AuthViewModel` base
/// class this extends, plus `authViewModelProvider`. Two ways to reach it:
/// * `ref.watch(authViewModelProvider)` → the current `AsyncValue` state;
/// * `ref.read(authViewModelProvider.notifier)` → this instance, to call methods.
///
/// Inside a Notifier, `ref` is a field (no need to pass it around) and `state`
/// is the read/write property whose assignment notifies listeners.

@ProviderFor(AuthViewModel)
final authViewModelProvider = AuthViewModelProvider._();

/// Drives the auth **actions** the UI can trigger: sign up, sign in, sign out.
///
/// Its state is `AsyncValue<AuthResult?>`, which screens use two ways:
/// * `ref.watch(...).isLoading` — to disable buttons and show a spinner.
/// * `ref.listen(...)` — to fire one-shot UI (snackbar, banner) when a specific
///   [AuthResult] arrives.
///
/// It is **not** the source of truth for "am I logged in" — that is
/// `authStateProvider`. This class only reports how the last operation went,
/// while the session stream independently drives navigation. That split is why
/// no screen has to push or pop a route after a successful login.
///
/// ## What the codegen produces
/// `@riverpod` on a **class** generates a Notifier: the `_$AuthViewModel` base
/// class this extends, plus `authViewModelProvider`. Two ways to reach it:
/// * `ref.watch(authViewModelProvider)` → the current `AsyncValue` state;
/// * `ref.read(authViewModelProvider.notifier)` → this instance, to call methods.
///
/// Inside a Notifier, `ref` is a field (no need to pass it around) and `state`
/// is the read/write property whose assignment notifies listeners.
final class AuthViewModelProvider
    extends $AsyncNotifierProvider<AuthViewModel, AuthResult?> {
  /// Drives the auth **actions** the UI can trigger: sign up, sign in, sign out.
  ///
  /// Its state is `AsyncValue<AuthResult?>`, which screens use two ways:
  /// * `ref.watch(...).isLoading` — to disable buttons and show a spinner.
  /// * `ref.listen(...)` — to fire one-shot UI (snackbar, banner) when a specific
  ///   [AuthResult] arrives.
  ///
  /// It is **not** the source of truth for "am I logged in" — that is
  /// `authStateProvider`. This class only reports how the last operation went,
  /// while the session stream independently drives navigation. That split is why
  /// no screen has to push or pop a route after a successful login.
  ///
  /// ## What the codegen produces
  /// `@riverpod` on a **class** generates a Notifier: the `_$AuthViewModel` base
  /// class this extends, plus `authViewModelProvider`. Two ways to reach it:
  /// * `ref.watch(authViewModelProvider)` → the current `AsyncValue` state;
  /// * `ref.read(authViewModelProvider.notifier)` → this instance, to call methods.
  ///
  /// Inside a Notifier, `ref` is a field (no need to pass it around) and `state`
  /// is the read/write property whose assignment notifies listeners.
  AuthViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authViewModelHash();

  @$internal
  @override
  AuthViewModel create() => AuthViewModel();
}

String _$authViewModelHash() => r'75ed7bfc769c63d33c441e4cde654953987adca4';

/// Drives the auth **actions** the UI can trigger: sign up, sign in, sign out.
///
/// Its state is `AsyncValue<AuthResult?>`, which screens use two ways:
/// * `ref.watch(...).isLoading` — to disable buttons and show a spinner.
/// * `ref.listen(...)` — to fire one-shot UI (snackbar, banner) when a specific
///   [AuthResult] arrives.
///
/// It is **not** the source of truth for "am I logged in" — that is
/// `authStateProvider`. This class only reports how the last operation went,
/// while the session stream independently drives navigation. That split is why
/// no screen has to push or pop a route after a successful login.
///
/// ## What the codegen produces
/// `@riverpod` on a **class** generates a Notifier: the `_$AuthViewModel` base
/// class this extends, plus `authViewModelProvider`. Two ways to reach it:
/// * `ref.watch(authViewModelProvider)` → the current `AsyncValue` state;
/// * `ref.read(authViewModelProvider.notifier)` → this instance, to call methods.
///
/// Inside a Notifier, `ref` is a field (no need to pass it around) and `state`
/// is the read/write property whose assignment notifies listeners.

abstract class _$AuthViewModel extends $AsyncNotifier<AuthResult?> {
  FutureOr<AuthResult?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthResult?>, AuthResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthResult?>, AuthResult?>,
              AsyncValue<AuthResult?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
