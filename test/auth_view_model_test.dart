import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_supabase/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_supabase/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository()
      : super(
          SupabaseClient('https://example.supabase.co', 'anon-key'),
        );

  int signOutCalls = 0;

  @override
  Future<void> signout() async {
    signOutCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  test('ignores repeated signOut calls while a request is already running', () async {
    final repository = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(authViewModelProvider.notifier);

    await Future.wait([notifier.signOut(), notifier.signOut()]);

    expect(repository.signOutCalls, 1);
  });
}
