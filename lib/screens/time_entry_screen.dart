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
      appBar: AppBar(title: Text('Add Time Entry'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            // dropDown for projects
            DropdownButtonFormField(
              value: _selectedProjectId,
              decoration: InputDecoration(
                labelText: 'Project',
                prefixIcon: const Icon(
                  Icons.folder_open_sharp,
                  color: Colors.blueAccent,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              items: project.map((proj) {
                return DropdownMenuItem(value: proj.id, child: Text(proj.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProjectId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: _selectedTaskId,
              decoration: InputDecoration(
                labelText: 'Task',
                prefixIcon: const Icon(
                  Icons.task_outlined,
                  color: Colors.blueAccent,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              items: task.map((tk) {
                return DropdownMenuItem(value: tk.id, child: Text(tk.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTaskId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            //for date
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date',
                prefixIcon: const Icon(
                  Icons.edit_calendar,
                  color: Colors.blueAccent,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
            const SizedBox(height: 16),

            TextField(
              controller: _totalTimeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total Time (in hours)',
                prefixIcon: const Icon(
                  Icons.timer_outlined,
                  color: Colors.blueAccent,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
           const SizedBox(height: 16.0),
            TextField(
              controller: _notesController,
             decoration: InputDecoration(
                labelText: 'Notes',
                prefixIcon: const Icon(Icons.note_alt_sharp, color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
           const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _saveEntry(context);
              },
              style: ElevatedButton.styleFrom(
                 
                backgroundColor: Colors.blueAccent, 
                foregroundColor: Colors.white, 
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), 
                ),
                elevation: 4, 
              ),
              child: Text(
                'Save Entry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
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
