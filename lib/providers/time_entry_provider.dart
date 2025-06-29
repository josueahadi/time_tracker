import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';

class TimeEntryProvider with ChangeNotifier {
  final LocalStorage _storage = LocalStorage('time_tracker');

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
    await _storage.ready;

    // Load projects
    final projectsData = _storage.getItem('projects');
    if (projectsData != null) {
      _projects = (projectsData as List)
          .map((json) => Project.fromJson(json))
          .toList();
    }

    // Load tasks
    final tasksData = _storage.getItem('tasks');
    if (tasksData != null) {
      _tasks = (tasksData as List).map((json) => Task.fromJson(json)).toList();
    }

    // Load time entries
    final timeEntriesData = _storage.getItem('timeEntries');
    if (timeEntriesData != null) {
      _timeEntries = (timeEntriesData as List)
          .map((json) => TimeEntry.fromJson(json))
          .toList();
    }

    notifyListeners();
  }

  Future<void> _saveProjects() async {
    await _storage.setItem(
      'projects',
      _projects.map((p) => p.toJson()).toList(),
    );
  }

  Future<void> _saveTasks() async {
    await _storage.setItem('tasks', _tasks.map((t) => t.toJson()).toList());
  }

  Future<void> _saveTimeEntries() async {
    await _storage.setItem(
      'timeEntries',
      _timeEntries.map((te) => te.toJson()).toList(),
    );
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
