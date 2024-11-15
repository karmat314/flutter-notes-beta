import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_group_screen.dart';
import 'group_detail_screen.dart';
import 'note_state.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: Consumer<MyAppState>(
        builder: (context, myAppState, child) {
          final groups = myAppState.groups;

          return groups.isEmpty
              ? Center(
            child: Text(
              'No groups created yet',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: Text(group.name),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Show confirmation dialog
                      final bool? shouldDelete = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Group'),
                          content: Text('Are you sure you want to delete this group?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      // Delete group if confirmed
                      if (shouldDelete == true) {
                        Provider.of<MyAppState>(context, listen: false).removeGroup(group.id);
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupDetailScreen(group: group),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddGroupScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
