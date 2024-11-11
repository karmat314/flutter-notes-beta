import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/Group.dart';
import 'note_state.dart';

class AddGroupScreen extends StatelessWidget {
  final TextEditingController _groupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_groupNameController.text.isNotEmpty) {
                  final newGroup = Group(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _groupNameController.text,
                  );

                  Provider.of<MyAppState>(context, listen: false).addGroup(newGroup);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
