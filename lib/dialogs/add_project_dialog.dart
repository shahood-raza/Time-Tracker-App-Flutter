import 'package:flutter/material.dart';

class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({super.key});
  @override
  AddProjectDialogState createState() => AddProjectDialogState();
}
class AddProjectDialogState extends State<AddProjectDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Project'),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(labelText: 'Project name'),
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
            final projectname = _nameController.text;
            if (projectname.isNotEmpty) {
              Navigator.of(context).pop(projectname);
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
