import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'note_state.dart';
import 'recycle_bin_screen.dart';


class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final myAppState = Provider.of<MyAppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Settings',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.restore_from_trash, color: Colors.deepPurple),
                title: Text('Recycle Bin'),
                subtitle: Text('View and manage deleted notes'),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecycleBinScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red),
                title: Text('Clear Storage'),
                subtitle: Text('Permanently delete all notes and recycle bin items'),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 18),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Clear Storage'),
                        content: Text('Are you sure you want to delete all notes including those in the recycle bin? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          ElevatedButton(
                            child: Text('Clear All'),
                            onPressed: () {
                              myAppState.clearAllNotes();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('All notes have been deleted')),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



