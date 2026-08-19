import 'package:flutter_supabase/core/supabase/supabase_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data-layer access to the `notes` table. **Scaffolded, not yet working** —
/// see the note on the provider below before building on this.
///
/// Same shape as `AuthRepository`: the [SupabaseClient] is injected rather than
/// grabbed from the global singleton, so tests can substitute a fake.
///
/// Row-level security is what makes queries here safe. With an RLS policy such
/// as `auth.uid() = user_id` on the table, Supabase filters by the caller's JWT
/// server-side, so a plain `notes.select()` returns only the current user's
/// rows — the client never has to add `.eq('user_id', ...)` and cannot be
/// tricked into reading someone else's data. Without RLS enabled, the anon key
/// would expose the whole table.
class NotesRepository {
  NotesRepository(this._client);

  final SupabaseClient _client;
  static const _table = 'notes';

  /// Query builder for the table, the starting point for every operation:
  ///
  /// ```dart
  /// await notes.select();                       // read
  /// await notes.insert({'title': 'Hi'});        // create
  /// await notes.update({'title': 'Edited'}).eq('id', id);
  /// await notes.update({'deleted_at': DateTime.now().toIso8601String()})
  ///            .eq('id', id);                   // soft delete
  /// ```
  ///
  /// Pair the results with `NoteModel.fromJson` to get typed objects back.
  SupabaseQueryBuilder get notes => _client.from(_table);

  // BROKEN — this provider is never generated. Two problems:
  //
  //  1. `@riverpod` only works on top-level functions and top-level classes.
  //     Here it sits on an *instance method inside* NotesRepository, which the
  //     generator ignores, so `notesRepositoryProvider` does not exist.
  //  2. The file has no `part 'notes_repository.g.dart';` directive, so even a
  //     correctly placed annotation would have nowhere to write its output.
  //
  // The fix is to move this function outside the class body and add the part
  // directive at the top of the file, exactly like `authRepositoryProvider`:
  //
  //     part 'notes_repository.g.dart';
  //
  //     class NotesRepository { ... }
  //
  //     @riverpod
  //     NotesRepository notesRepository(Ref ref) =>
  //         NotesRepository(ref.read(supabaseClientProvider));
  //
  // then rerun: dart run build_runner build --delete-conflicting-outputs
  @riverpod
  NotesRepository notesRepository(Ref ref) {
    return NotesRepository(ref.read(supabaseClientProvider));
  }
}
