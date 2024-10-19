import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/Note.dart';
import 'note_edit_screen.dart';
import 'note_state.dart'; // Import the NoteEditScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = ''; // State to manage the search query

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0), // Height of the search bar
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase(); // Update search query
                });
              },
            ),
          ),
        ),
      ),
      body: Consumer<MyAppState>(
        builder: (context, myAppState, child) {
          // Filter notes based on search query
          final filteredNotes = myAppState.notes.where((note) {
            return note.title.toLowerCase().contains(_searchQuery);
          }).toList();

          return ListView.builder(
            itemCount: filteredNotes.length,
            itemBuilder: (context, index) {
              final note = filteredNotes[index];
              return ListTile(
                title: Text(note.title),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteEditScreen(note: note),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newNote = Note(); // Create a new note
          Provider.of<MyAppState>(context, listen: false).addNote(newNote); // Add it to the state
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditScreen(note: newNote), // Navigate to edit screen
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
