import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'model/Group.dart';

class GroupSelectionDialog extends StatefulWidget {
  final List<Group> availableGroups;
  final List<Group> selectedGroups;

  GroupSelectionDialog({
    required this.availableGroups,
    required this.selectedGroups,
  });

  @override
  _GroupSelectionDialogState createState() => _GroupSelectionDialogState();
}

class _GroupSelectionDialogState extends State<GroupSelectionDialog> {
  late Set<Group> tempSelectedGroups;

  @override
  void initState() {
    super.initState();
    // Initialize temporary selected groups from the initially selected groups
    tempSelectedGroups = Set<Group>.from(widget.selectedGroups);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Groups"),
      content: SingleChildScrollView(
        child: Column(
          children: widget.availableGroups.map((group) {
            return CheckboxListTile(
              title: Text(group.name),
              value: tempSelectedGroups.contains(group),
              onChanged: (bool? isChecked) {
                setState(() {
                  if (isChecked == true) {
                    tempSelectedGroups.add(group);
                  } else {
                    tempSelectedGroups.remove(group);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("Done"),
          onPressed: () {
            // Return the selected groups to the parent widget
            Navigator.pop(context, tempSelectedGroups.toList());
          },
        ),
      ],
    );
  }
}
