import 'package:flutter/material.dart';
import 'package:flutter_notes_beta/settings_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'groups_screen.dart';
import 'model/Note.dart';
import 'note_edit_screen.dart';
import 'note_state.dart'; // Import the NoteEditScreen
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = ''; // State to manage the search query
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _authenticateAndShowNote(Note note) async {
    bool authenticated = false;

    try {
      // Attempt to authenticate
      authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access the vault.',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      print('Authentication error: $e');
    }

    if (authenticated) {
      // Navigate to the vault screen if authentication is successful
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteEditScreen(note: note, isBeingCreated: false),
        ),
      );
    } else {
      // Optionally, show a message if authentication fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed.')),
      );
    }
  }

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
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupsPage()),
              );
            },
          ),
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
                  title: Row(
                    children: [
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      if (note.vaulted) ...[
                        const SizedBox(width: 8), // Optional spacing between text and icon
                        const Icon(
                          Icons.lock,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ],
                  ),

                  subtitle: Text(
                    'Created: ${DateFormat('dd/MM/yyyy').format(note.createdAt)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if(!note.vaulted){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteEditScreen(note: note, isBeingCreated: false),
                        ),
                      );
                    }
                    else{
                       _authenticateAndShowNote(note);
                    }

                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create a new empty note with no ID
          final newNote = Note();

          // Navigate to the NoteEditScreen to edit the new note
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditScreen(note: newNote, isBeingCreated: true),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

    );
  }

}
