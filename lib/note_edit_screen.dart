import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_beta/quill_configurations.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/quill_delta.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:share_plus/share_plus.dart';

import 'model/Note.dart';
import 'note_state.dart';

class NoteEditScreen extends StatefulWidget {
  final Note note;
  final bool isBeingCreated;

  const NoteEditScreen({super.key, required this.note, required this.isBeingCreated});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late QuillController _controller; // Declare controller here
  final TextEditingController _titleController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  late final bool isBeingCreated;


  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
    _controller = QuillController.basic(); // Initialize controller with basic setup
    _loadNoteContent(widget.note.id); // Load existing note content
    _speech = stt.SpeechToText();
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




  String _lastRecognizedWords = ''; // Track the last recognized words

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          // Print recognized words to Logcat
          if (kDebugMode) {
            print("Recognized words: ${result.recognizedWords}");
          }

          // Find the difference between the current and previous recognized words
          final newWords = result.recognizedWords.replaceFirst(_lastRecognizedWords, '').trim();

          // Only append if there are new words
          if (newWords.isNotEmpty) {
            setState(() {
              // Update the last recognized words to the current result
              _lastRecognizedWords = result.recognizedWords;

              // Append the new words to the document
              final length = _controller.document.length;
              _controller.document.insert(length - 1, newWords + ' ');
            });
          }
        },
      );
    }
  }




  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isBeingCreated ? 'Create Note' : 'Edit Note'), // Conditional title
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              // Check if title or content is empty
              if (_titleController.text.isEmpty || _controller.document.isEmpty()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Title and content cannot be empty')),
                );
                return; // Exit without saving
              }

              // Update the note title
              widget.note.title = _titleController.text;

              final newNote = Note();
              newNote.title = widget.note.title;

              Provider.of<MyAppState>(context, listen: false).addNote(newNote);

              // Save the note content to SharedPreferences
              await _saveNoteContent(widget.note.id);

              // Notify listeners that the note has been updated
              Provider.of<MyAppState>(context, listen: false).updateNote(widget.note);

              // Navigate back to the home screen after saving
              Navigator.pop(context);
            },
          ),

          // Show delete button only if the note has an id (i.e., editing an existing note)
          if (!widget.isBeingCreated)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Provider.of<MyAppState>(context, listen: false).deleteNoteToRecycleBin(widget.note);
                // Navigate back to the home screen after saving
                Navigator.pop(context);
              },
            ),

          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : null, // Red if listening, default otherwise
            ),
            onPressed: _isListening ? _stopListening : _startListening,
          ),

          IconButton(
            onPressed: () {
              final content = _controller.document.toPlainText();
              Share.share(content, subject: widget.note.title);
            },
            icon: Icon(Icons.share),
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
              configurations: QuillConfigurations.getToolbarConfigurations(controller: _controller),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: QuillEditor.basic(
                controller: _controller,
                configurations: QuillConfigurations.getEditorConfigurations(controller: _controller),
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
