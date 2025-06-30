import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';

class TimeEntryProvider with ChangeNotifier {
  List<Project> _projects = [];
  List<Task> _tasks = [];
  List<TimeEntry> _timeEntries = [];

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;
  List<TimeEntry> get timeEntries => _timeEntries;

  TimeEntryProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load projects
    final projectsData = prefs.getString('time_tracker_projects');
    if (projectsData != null) {
      final List<dynamic> projectsList = jsonDecode(projectsData);
      _projects = projectsList.map((json) => Project.fromJson(json)).toList();
    }

    // Load tasks
    final tasksData = prefs.getString('time_tracker_tasks');
    if (tasksData != null) {
      final List<dynamic> tasksList = jsonDecode(tasksData);
      _tasks = tasksList.map((json) => Task.fromJson(json)).toList();
    }

    // Load time entries
    final timeEntriesData = prefs.getString('time_tracker_time_entries');
    if (timeEntriesData != null) {
      final List<dynamic> timeEntriesList = jsonDecode(timeEntriesData);
      _timeEntries = timeEntriesList
          .map((json) => TimeEntry.fromJson(json))
          .toList();
    }

    // Initialize sample data if no data exists
    if (_projects.isEmpty && _tasks.isEmpty && _timeEntries.isEmpty) {
      await _initializeSampleData();
    }

    notifyListeners();
  }

  Future<void> _saveProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = jsonEncode(_projects.map((p) => p.toJson()).toList());
    await prefs.setString('time_tracker_projects', projectsJson);
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('time_tracker_tasks', tasksJson);
  }

  Future<void> _saveTimeEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final timeEntriesJson = jsonEncode(
      _timeEntries.map((te) => te.toJson()).toList(),
    );
    await prefs.setString('time_tracker_time_entries', timeEntriesJson);
  }

  Future<void> _initializeSampleData() async {
    // Add sample projects
    final sampleProjects = [
      Project(id: '1', name: 'Project Alpha', isDefault: false),
      Project(id: '2', name: 'Project Beta', isDefault: false),
      Project(id: '3', name: 'Project Gamma', isDefault: false),
    ];

    // Add sample tasks
    final sampleTasks = [
      Task(id: '1', name: 'Task A'),
      Task(id: '2', name: 'Task B'),
      Task(id: '3', name: 'Task C'),
    ];

    _projects.addAll(sampleProjects);
    _tasks.addAll(sampleTasks);

    await _saveProjects();
    await _saveTasks();
  }

  // Project methods
  Future<void> addProject(Project project) async {
    _projects.add(project);
    await _saveProjects();
    notifyListeners();
  }

  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((p) => p.id == projectId);
    _timeEntries.removeWhere((te) => te.projectId == projectId);
    await _saveProjects();
    await _saveTimeEntries();
    notifyListeners();
  }

  // Task methods
  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    _timeEntries.removeWhere((te) => te.taskId == taskId);
    await _saveTasks();
    await _saveTimeEntries();
    notifyListeners();
  }

  // Time entry methods
  Future<void> addTimeEntry(TimeEntry timeEntry) async {
    _timeEntries.add(timeEntry);
    await _saveTimeEntries();
    notifyListeners();
  }

  Future<void> deleteTimeEntry(String timeEntryId) async {
    _timeEntries.removeWhere((te) => te.id == timeEntryId);
    await _saveTimeEntries();
    notifyListeners();
  }

  // Utility methods
  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Map<String, List<TimeEntry>> getTimeEntriesGroupedByProject() {
    Map<String, List<TimeEntry>> grouped = {};
    for (var entry in _timeEntries) {
      if (grouped[entry.projectId] == null) {
        grouped[entry.projectId] = [];
      }
      grouped[entry.projectId]!.add(entry);
    }
    return grouped;
  }
}
