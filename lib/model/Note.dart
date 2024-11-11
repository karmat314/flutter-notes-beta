import 'package:uuid/uuid.dart';

import 'Group.dart';


class Note {
  final String id;
  String title;
  final DateTime createdAt;
  bool vaulted;
  List<Group> groups;

  Note({
    String? id,
    this.title = '',
    DateTime? createdAt,
    this.vaulted = false,
    List<Group>? groups,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        groups = groups ?? [];

  // Convert Note to JSON (with groups)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'vaulted': vaulted,
      'groups': groups.map((group) => group.toJson()).toList(), // Serialize groups
    };
  }

  // Create Note from JSON (with groups)
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'New Note',
      createdAt: DateTime.parse(json['createdAt'] as String),
      vaulted: json['vaulted'] as bool? ?? false,
      groups: (json['groups'] as List<dynamic>?)?.map((groupJson) => Group.fromJson(groupJson as Map<String, dynamic>)).toList() ?? [],
    );
  }
}


