import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/Group.dart';
import 'model/Note.dart';

import 'dart:convert';

class MyAppState extends ChangeNotifier {
  final List<Note> _notes = [];
  final List<Note> _deletedNotes = [];

  List<Note> get notes => _notes;
  List<Note> get deletedNotes => _deletedNotes;

  MyAppState() {
    _loadNotes();
    _loadDeletedNotes();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGroups = prefs.getStringList('groups') ?? [];
    _groups = savedGroups
        .map((groupData) => Group.fromJson(jsonDecode(groupData)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final groupsJson = _groups.map((group) => jsonEncode(group.toJson())).toList();
    await prefs.setStringList('groups', groupsJson);
  }

  void addGroup(Group group) {
    _groups.add(group);
    _saveGroups(); // Save groups after adding
    notifyListeners();
  }

  void removeGroup(String groupId) {
    _groups.removeWhere((group) => group.id == groupId);
    _saveGroups(); // Save groups after removing
    notifyListeners();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotes = prefs.getStringList('notes') ?? [];
    _notes.addAll(savedNotes.map((noteData) => Note.fromJson(jsonDecode(noteData))));
    notifyListeners();
  }

  Future<void> _loadDeletedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDeletedNotes = prefs.getStringList('deletedNotes') ?? [];
    _deletedNotes.addAll(savedDeletedNotes.map((noteData) => Note.fromJson(jsonDecode(noteData))));
    notifyListeners();
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('notes', _notes.map((note) => jsonEncode(note.toJson())).toList());
  }

  Future<void> _saveDeletedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('deletedNotes', _deletedNotes.map((note) => jsonEncode(note.toJson())).toList());
  }

  Future<void> clearAllNotes() async {
    _notes.clear();
    _deletedNotes.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notes');
    await prefs.remove('deletedNotes');
    notifyListeners();
  }

  void addNote(Note note) {
    _notes.add(note);
    _saveNotes();
    notifyListeners();
  }

  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      _saveNotes();
      notifyListeners();
    }
  }

  void removeNoteById(String id) {
    _notes.removeWhere((note) => note.id == id);
    _saveNotes();
    notifyListeners();
  }

  void deleteNoteToRecycleBin(Note note) {
    _notes.remove(note);
    _deletedNotes.add(note);
    _saveNotes();
    _saveDeletedNotes();
    notifyListeners();
  }

  void restoreNote(Note note) {
    _deletedNotes.remove(note);
    _notes.add(note);
    _saveNotes();
    _saveDeletedNotes();
    notifyListeners();
  }

  void deleteNotePermanently(Note note) {
    _deletedNotes.remove(note);
    _saveDeletedNotes();
    notifyListeners();
  }

  List<Group> _groups = [];

  List<Group> get groups => _groups;


  List<Note> get vaultedNotes => _notes.where((note) => note.vaulted).toList();

  void unlockNote(Note note) {
    note.vaulted = false;
    _saveNotes();
    notifyListeners();
  }
}
