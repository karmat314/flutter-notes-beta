import 'package:flutter/material.dart';
import 'package:flutter_notes_beta/settings_screen.dart';
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
        title: const Text(
          'Notes',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: Consumer<MyAppState>(
        builder: (context, myAppState, child) {
          final filteredNotes = myAppState.notes.where((note) {
            return note.title.toLowerCase().contains(_searchQuery);
          }).toList();

          return filteredNotes.isEmpty
              ? Center(
            child: Text(
              'No notes found',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: filteredNotes.length,
            itemBuilder: (context, index) {
              final note = filteredNotes[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 2.0,
                child: ListTile(
                  title: Text(
                    note.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteEditScreen(note: note),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newNote = Note();
          Provider.of<MyAppState>(context, listen: false).addNote(newNote);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditScreen(note: newNote),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

}
