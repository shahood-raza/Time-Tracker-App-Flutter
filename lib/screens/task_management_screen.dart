import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import '../models/task.dart';
import '../dialogs/add_task_dialog.dart';

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Tasks',
       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      )),
      body:Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<TimeEntryProvider>(
          builder: (context, provider, child) {
            if (provider.tasks.isEmpty) {
              return const Center(
                child: Text(
                  'No tasks added yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              itemCount: provider.tasks.length,
              itemBuilder: (context, index) {
                final task = provider.tasks[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        task.name.isNotEmpty
                            ? task.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      task.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        provider.deleteTask(task.id);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        elevation: 6,
        shape: CircleBorder(
          side: BorderSide(color: Colors.white, width: 3),
        ),

        onPressed: () async {
          final taskName = await showDialog<String>(
            context: context,
            builder: (context) => AddTaskDialog(),
          );

          if (taskName != null && taskName.isNotEmpty) {
            final task = Task(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: taskName,
            );
            Provider.of<TimeEntryProvider>(
              context,
              listen: false,
            ).addTask(task);
          }
        },
        tooltip: 'Add Task',
        child: Icon(Icons.add),
      ),
    );
  }
}
