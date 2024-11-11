import 'package:flutter/material.dart';

class Group {
  String id;
  String name;

  Group({required this.id, required this.name});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };

  static Group fromJson(Map<String, dynamic> json) {
    return Group(id: json['id'], name: json['name']);
  }
}