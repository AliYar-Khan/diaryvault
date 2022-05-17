part of 'notes_bloc.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

class InitializeNote extends NotesEvent {
  // if id is present, then we are updating an existing note else we are creating a new one
  final String? id;

  const InitializeNote([this.id]);
}

class UpdateNote extends NotesEvent {
  // only these 4 things can eb changed by user
  final DateTime? createdAt;
  final String? title;
  final String? body;
  final NoteAsset? noteAsset;

  const UpdateNote({this.createdAt, this.title, this.body, this.noteAsset});
}

/// if newNote is true, then create a new note, otherwise update the existing note
class SaveNote extends NotesEvent {}

class DeleteNote extends NotesEvent {}

/// Even if user discards the note, we have to delete all the saved assets
/// If newNote is true, then delete all assets, else delete only new assets
class DiscardNote extends NotesEvent {}
