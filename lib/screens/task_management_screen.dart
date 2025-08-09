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
      appBar: AppBar(title: Text('Manage Tasks')),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.tasks.length,
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              return ListTile(
                title: Text(task.name),
                trailing: IconButton(
                  onPressed: () {
                    provider.deleteTask(task.id);
                  },
                  icon: Icon(Icons.delete),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
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
            Navigator.pop(context);
          }
        },
        tooltip: 'Add Task',
        child: Icon(Icons.add),
      ),
    );
  }
}
