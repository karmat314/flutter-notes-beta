import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/Note.dart';

class MyAppState extends ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get notes => _notes;

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners(); // Notify listeners after adding a note
  }

  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners(); // Notify listeners after updating a note
    }
  }

  void removeNoteById(String id) async {
    // Remove from the local list
    notes.removeWhere((note) => note.id == id);

    // Remove from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(id); // Remove the entry corresponding to the note ID

    // Notify listeners
    notifyListeners();
  }

}