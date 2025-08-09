import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});
  @override
  AddTaskDialogState createState() => AddTaskDialogState();
}

class AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Task'),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(labelText: 'Task name'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final taskName = _nameController.text;
            if (taskName.isNotEmpty) {
              Navigator.of(context).pop(taskName);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose(){
    _nameController.dispose();
    super.dispose();
  }
}
