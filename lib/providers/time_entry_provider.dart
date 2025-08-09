import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';
import '../models/time_entry.dart';
import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../models/task.dart';

class TimeEntryProvider with ChangeNotifier {
  final LocalStorage storage;

  List<TimeEntry> _entries = [];
final List<Project> _projects = [
  Project(id: 'p1', name: 'Employee Attendance System'),
  Project(id: 'p2', name: 'Client Invoice Tracker'),
  Project(id: 'p3', name: 'Project Management Tool'),
  Project(id: 'p4', name: 'CRM Dashboard'),
  Project(id: 'p5', name: 'Inventory Control System'),
  Project(id: 'p6', name: 'E-commerce Admin Panel'),
];
  final List<Task> _tasks = [
    Task(id: 't1', name: 'UI Design'),
    Task(id: 't2', name: 'Flutter Coding'),
    Task(id: 't3', name: 'Backend Setup'),
    Task(id: 't4', name: 'Chart Integration'),
    Task(id: 't5', name: 'REST API Calls'),
    Task(id: 't6', name: 'Error Handling'),
  ];

  List<TimeEntry> get entries => _entries;

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  TimeEntryProvider(this.storage) {
    _loadEntriesFromStorage();
  }

  Future<void> _loadEntriesFromStorage() async {
    final storedEntry = storage.getItem('entries');
    if (storedEntry != null) {
      final List<dynamic> decoded = jsonDecode(storedEntry);
      _entries = decoded.map((entry) => TimeEntry.fromJson(entry)).toList();
      notifyListeners();
    }
  }

  void _saveEntryToStorage() {
    final encoded = jsonEncode(
      _entries.map((entry) => entry.toJson()).toList(),
    );
    storage.setItem('entries', encoded);
  }

  void addEntry(TimeEntry entry) {
    _entries.add(entry);
    _saveEntryToStorage();
    notifyListeners();
  }

  void deleteEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    _saveEntryToStorage();
    notifyListeners();
  }

  void addOrUpdateEntry(TimeEntry entry) {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
    } else {
      _entries.add(entry);
    }
    _saveEntryToStorage();
    notifyListeners();
  }

  // add projects
  void addProject(Project project) {
    if (!_projects.any((proj) => proj.name == project.name)) {
      _projects.add(project);
      notifyListeners();
    }
  }

  // delete projects
  void deleteProject(String id) {
    _projects.removeWhere((proj) => proj.id == id);
    notifyListeners();
  }

  //add tasks
  void addTask(Task task) {
    if (!_tasks.any((tk) => tk.name == task.name)) {
      _tasks.add(task);
      notifyListeners();
    }
  }

  //remove tasks
  void deleteTask(String id) {
    _tasks.removeWhere((tk) => tk.id == id);
    notifyListeners();
  }
}
