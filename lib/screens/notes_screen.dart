

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cubit/note_cubit.dart';
import '../cubit/note_state.dart';
import '../models/note_model.dart';

class Notescreen extends StatefulWidget {
  const Notescreen({super.key});

  @override
  State<Notescreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<Notescreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void editnote(notemodel note) {
    TextEditingController titleEdit =
        TextEditingController(text: note.title);
    TextEditingController descriptionEdit =
        TextEditingController(text: note.description);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleEdit,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: descriptionEdit,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleEdit.text.trim().isEmpty) {
                  showMessage('Title cannot be empty');
                  return;
                }

                context.read<NoteCubit>().updateNote(
                      note.id,
                      titleEdit.text,
                      descriptionEdit.text,
                    );

                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      titleEdit.dispose();
      descriptionEdit.dispose();
    });
  }

  void deleteNote(notemodel note) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<NoteCubit>().deleteNote(note.id);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteCubit, NoteState>(
      listener: (context, state) {
        if (state is NoteSuccess) {
          showMessage(state.message);

          if (state.message == 'Note added successfully') {
            titleController.clear();
            descriptionController.clear();
          }
        }
        if (state is NoteError) {
          showMessage(state.message);
        }
      },
      builder: (context, state) {
        NoteCubit cubit = context.read<NoteCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Notes'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: state is NoteLoading
                          ? null
                          : () {
                              if (titleController.text.trim().isEmpty) {
                                showMessage('Title cannot be empty');
                                return;
                              }

                              cubit.addNote(
                                titleController.text,
                                descriptionController.text,
                              );
                            },
                      child: const Text('Add Note'),
                    ),
                  ],
                ),
              ),
              if (state is NoteLoading)
                const LinearProgressIndicator(),
              Expanded(
                child: StreamBuilder<
                    QuerySnapshot<Map<String, dynamic>>>(
                  stream: cubit.getNotes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Something went wrong'),
                      );
                    }
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>
                        documents = snapshot.data!.docs;

                    if (documents.isEmpty) {
                      return const Center(
                        child: Text('No Notes Yet'),
                      );
                    }
                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        var document = documents[index];

                        notemodel note = notemodel.frommap(
                          document.data(),
                          document.id,
                        );

                        return ListTile(
                          leading: Checkbox(
                            value: note.isDone,
                            onChanged: (value) {
                              cubit.toggleNote(
                                note.id,
                                value ?? false,
                              );
                            },
                          ),
                          title: Text(
                            note.title,
                            style: TextStyle(
                              decoration: note.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(note.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  editnote(note);
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () {
                                  deleteNote(note);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
