import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/Group.dart';
import 'note_edit_screen.dart';
import 'note_state.dart';

import 'package:intl/intl.dart'; // Add this import for date formatting

class GroupDetailScreen extends StatelessWidget {
  final Group group;

  GroupDetailScreen({required this.group});

  @override
  Widget build(BuildContext context) {
    // Access MyAppState to get all notes
    final myAppState = Provider.of<MyAppState>(context);

    // Filter notes that belong to the selected group
    final groupNotes = myAppState.notes.where((note) => note.groups.contains(group)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${group.name} Notes'),
      ),
      body: groupNotes.isEmpty
          ? Center(
        child: Text(
          'No notes in this group',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: groupNotes.length,
        itemBuilder: (context, index) {
          final note = groupNotes[index];

          // Format createdAt date to 'MMM dd, yyyy' format
          final formattedDate = DateFormat('MMM dd, yyyy').format(note.createdAt);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 3.0,
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
            child: ListTile(
              title: Text(
                note.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              subtitle: Text('Last modified: $formattedDate'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteEditScreen(
                      note: note,
                      isBeingCreated: false,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

