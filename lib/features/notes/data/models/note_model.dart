import 'package:freezed_annotation/freezed_annotation.dart';

// Two generated halves, two part directives — this file uses two generators at
// once and needs both:
//   *.freezed.dart -> Freezed: the _$NoteModel mixin, copyWith, ==, hashCode,
//                     toString, and the _NoteModel implementation class.
//   *.g.dart       -> json_serializable: _$NoteModelFromJson / ...ToJson.
// Forget either line and the build fails with "part not found" or an undefined
// _$ symbol. Rebuild with:
//   dart run build_runner build --delete-conflicting-outputs
part 'note_model.freezed.dart';
part 'note_model.g.dart';

/// A row of the Supabase `notes` table.
///
/// Freezed makes this an **immutable value class**: no setters, `==` compares
/// field-by-field rather than by identity, and updates are made by copying:
///
/// ```dart
/// final renamed = note.copyWith(title: 'New title');
/// ```
///
/// Value equality matters for Riverpod — a provider only notifies listeners when
/// the new state `!=` the old one, so hand-written models without `==` cause
/// either missed rebuilds or rebuild storms.
///
/// ## Reading the syntax
/// `abstract class ... with _$NoteModel` plus a `const factory` constructor
/// assigned to `= _NoteModel` is Freezed's required shape: you declare the
/// fields in the factory's parameter list, and the generator writes the concrete
/// `_NoteModel` subclass that actually holds them.
///
/// ## Postgres <-> Dart naming
/// Supabase columns are snake_case, Dart fields are camelCase, and there is no
/// global rename rule configured in this project — so every mismatched field
/// carries an explicit [JsonKey]. Miss one and `fromJson` throws at runtime on a
/// null it did not expect, not at compile time. Fields whose names already match
/// (`id`, `title`, `content`) need no annotation.
///
/// [deletedAt] being nullable implies **soft deletes**: rows are marked rather
/// than removed, so queries need `.isFilter('deleted_at', null)` to hide them.
@freezed
abstract class NoteModel with _$NoteModel {
  const factory NoteModel({
    required String id,
    @JsonKey(name: 'user_id')
    required String userId,
    required String title,
    /// Nullable: a note may have a title but no body yet.
    String? content,
    @JsonKey(name: 'created_at')
    required DateTime createdAt,
    @JsonKey(name: 'updated_at')
    required DateTime updatedAt,
    /// Non-null once the row is soft-deleted; null means the note is live.
    @JsonKey(name: 'deleted_at')
    DateTime? deletedAt,
  }) = _NoteModel;

  /// Builds a [NoteModel] from a Supabase row.
  ///
  /// Supabase returns `List<Map<String, dynamic>>`, so this is the boundary
  /// where untyped JSON becomes a typed object:
  /// ```dart
  /// final rows = await notes.select();
  /// final parsed = rows.map(NoteModel.fromJson).toList();
  /// ```
  /// The generated `toJson()` (from the mixin) goes the other way for inserts.
  /// ISO-8601 timestamp strings are converted to [DateTime] automatically.
  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      _$NoteModelFromJson(json);

  //
}
