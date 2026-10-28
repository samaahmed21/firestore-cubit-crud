

abstract class NoteState {}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteSuccess extends NoteState {
  String message;

  NoteSuccess(this.message);
}

class NoteError extends NoteState {
  String message;

  NoteError(this.message);
}
