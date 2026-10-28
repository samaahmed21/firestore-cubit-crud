
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import 'note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  NoteCubit() : super(NoteInitial());

  final notes = FirebaseFirestore.instance.collection('notes');

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotes() {
    return notes.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addNote(String title, String description) async {
    if (title.trim().isEmpty) {
      emit(NoteError('Title cannot be empty'));
      return;
    }

    emit(NoteLoading());

    try {
      notemodel note = notemodel(
        id: '',
        title: title.trim(),
        description: description.trim(),
      );

      await notes.add({
        ...note.tomap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      emit(NoteSuccess('Note added successfully'));
    } catch (e) {
      emit(NoteError('Something went wrong'));
    }
  }
  Future<void> updateNote(
      String id, String title, String description) async {
    if (title.trim().isEmpty) {
      emit(NoteError('Title cannot be empty'));
      return;
    }
    emit(NoteLoading());

    try {
      await notes.doc(id).update({
        'title': title.trim(),
        'description': description.trim(),
      });

      emit(NoteSuccess('Note updated successfully'));
    } catch (e) {
      emit(NoteError('Something went wrong'));
    }
  }
  Future<void> toggleNote(String id, bool isDone) async {
    emit(NoteLoading());

    try {
      await notes.doc(id).update({
        'isDone': isDone,
      });

      emit(NoteSuccess('Note status updated'));
    } catch (e) {
      emit(NoteError('Something went wrong'));
    }
  }
  Future<void> deleteNote(String id) async {
    emit(NoteLoading());

    try {
      await notes.doc(id).delete();
      emit(NoteSuccess('Note deleted successfully'));
    } catch (e) {
      emit(NoteError('Something went wrong'));
    }
  }
}
