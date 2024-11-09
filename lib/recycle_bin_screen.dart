import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'note_state.dart';

class RecycleBinScreen extends StatelessWidget {
  const RecycleBinScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deleted Notes'),
      ),
      body: Consumer<MyAppState>(
        builder: (context, appState, child) {
          final deletedNotes = appState.deletedNotes;

          if (deletedNotes.isEmpty) {
            return Center(child: Text('No deleted notes'));
          }

          return ListView.builder(
            itemCount: deletedNotes.length,
            itemBuilder: (context, index) {
              final note = deletedNotes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(note.createdAt?.toLocal().toString() ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.restore),
                      onPressed: () {
                        appState.restoreNote(note);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirm Delete'),
                              content: Text('Are you sure you want to permanently delete this note?'),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Dismiss the dialog
                                  },
                                ),
                                TextButton(
                                  child: Text('Delete'),
                                  onPressed: () {
                                    // Perform permanent delete
                                    appState.deleteNotePermanently(note);

                                    Navigator.of(context).pop(); // Dismiss the dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
