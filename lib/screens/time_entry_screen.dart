import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/time_entry.dart';
// import '../models/project.dart';
// import '../models/task.dart';
import '../providers/time_entry_provider.dart';

class TimeEntryScreen extends StatefulWidget {
  const TimeEntryScreen({super.key});
  @override
  TimeEntryScreenState createState() => TimeEntryScreenState();
}

class TimeEntryScreenState extends State<TimeEntryScreen> {
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _totalTimeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedProjectId;
  String? _selectedTaskId;
  DateTime? _pickedDate;
  @override
  Widget build(BuildContext context) {
    final timeEntryProvider = Provider.of<TimeEntryProvider>(context);
    final project = timeEntryProvider.projects;
    final task = timeEntryProvider.tasks;
    return Scaffold(
      appBar: AppBar(title: Text('Add Time Entry')),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            // dropDown for projects
            DropdownButtonFormField(
              value: _selectedProjectId,
              items: project.map((proj) {
                return DropdownMenuItem(value: proj.id, child: Text(proj.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProjectId = value;
                });
              },
            ),
            DropdownButtonFormField(
              value: _selectedTaskId,
              items: task.map((tk) {
                return DropdownMenuItem(value: tk.id, child: Text(tk.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTaskId = value;
                });
              },
            ),
            //for date = dateTimePicker
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Icons.edit_calendar),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  _pickedDate = pickedDate;
                  _dateController.text = DateFormat(
                    'MMM dd, yyyy',
                  ).format(pickedDate);
                }
              },
            ),
            TextField(
              controller: _totalTimeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Total Time (in hours)'),
            ),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notes: '),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _saveEntry(context);
              },
              child: Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }

void _saveEntry(BuildContext context) {
  if (_selectedProjectId == null) {
    _showError(context, 'Please select a project');
    return;
  }
  if (_selectedTaskId == null) {
    _showError(context, 'Please select a task');
    return;
  }
  if (_pickedDate == null) {
    _showError(context, 'Please select a date');
    return;
  }
  if (_totalTimeController.text.trim().isEmpty ||
      double.tryParse(_totalTimeController.text.trim()) == null) {
    _showError(context, 'Please enter valid total time in hours');
    return;
  }

  final entryTime = TimeEntry(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    projectId: _selectedProjectId!,
    taskId: _selectedTaskId!,
    totalTime: double.parse(_totalTimeController.text.trim()),
    date: _pickedDate!,
    notes: _notesController.text.trim(),
  );

  Provider.of<TimeEntryProvider>(context, listen: false).addEntry(entryTime);
  Navigator.pop(context);
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
    ),
  );
}
  @override
  void dispose() {
    _projectController.dispose();
    _taskController.dispose();
    _dateController.dispose();
    _totalTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
