import 'package:uuid/uuid.dart';

import 'Group.dart';

class Note {
  final String id;
  String title;
  final DateTime createdAt;

  List<Group> groups = [];

  Note({
    String? id,
    this.title = '',
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Convert Note to JSON (without content)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Note from JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'New Note',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
