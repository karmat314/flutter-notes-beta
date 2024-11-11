import 'package:flutter/material.dart';

class Group {
  final String id;
  final String name;

  Group({required this.id, required this.name});

  // Convert Group to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Create Group from JSON
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
