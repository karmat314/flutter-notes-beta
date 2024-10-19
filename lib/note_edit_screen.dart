import 'package:flutter/material.dart';
import 'package:flutter_notes_beta/quill_configurations.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/quill_delta.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';


import 'model/Note.dart';
import 'note_state.dart';

class NoteEditScreen extends StatefulWidget {
  final Note note;

  const NoteEditScreen({super.key, required this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late QuillController _controller; // Declare controller here
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
    _controller = QuillController.basic(); // Initialize controller with basic setup
    _loadNoteContent(widget.note.id); // Load existing note content
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadNoteContent(String noteId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedContent = prefs.getString(noteId);

    if (savedContent != null) {
      final Delta delta = Delta.fromJson(jsonDecode(savedContent));
      setState(() {
        _controller = QuillController(
          document: Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      });
    }
  }

  String recognizedText = '';

  Future<void> _saveNoteContent(String noteId) async {
    final prefs = await SharedPreferences.getInstance();
    final content = jsonEncode(_controller.document.toDelta().toJson());
    await prefs.setString(noteId, content);
  }

  Future<String> recognizeText(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);

    await textRecognizer.close();

    // Append recognized text to the Quill editor's document
    setState(() {
      // Get the current length of the document
      final length = _controller.document.length;

      // Append the recognized text as plain text
      _controller.document.insert(length - 1, recognizedText.text);
    });

    return recognizedText.text.replaceAll(RegExp(r'\s+'), ' ');

  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      String text = await recognizeText(image.path);
      print(text); // Display the recognized text
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              // Update the note title
              widget.note.title = _titleController.text;

              // Save the note content to SharedPreferences
              await _saveNoteContent(widget.note.id);

              // Notify listeners that the note has been updated
              Provider.of<MyAppState>(context, listen: false).updateNote(widget.note);

              // Navigate back to the home screen after saving
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Provider.of<MyAppState>(context, listen: false).removeNoteById(widget.note.id);
              // Navigate back to the home screen after saving
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
                hintText: 'Enter note title',
              ),
            ),
            const SizedBox(height: 8),
            QuillSimpleToolbar(
              controller: _controller,
              configurations:
              QuillConfigurations.getToolbarConfigurations(controller: _controller),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: QuillEditor.basic(
                controller: _controller,
                configurations:
                QuillConfigurations.getEditorConfigurations(controller: _controller),
              ),
            ),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            Text(
              recognizedText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
