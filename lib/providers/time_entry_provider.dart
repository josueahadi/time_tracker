import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';
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
    // Load projects
    final projectsData = localStorage.getItem('time_tracker_projects');
    if (projectsData != null) {
      final List<dynamic> projectsList = jsonDecode(projectsData);
      _projects = projectsList.map((json) => Project.fromJson(json)).toList();
    }

    // Load tasks
    final tasksData = localStorage.getItem('time_tracker_tasks');
    if (tasksData != null) {
      final List<dynamic> tasksList = jsonDecode(tasksData);
      _tasks = tasksList.map((json) => Task.fromJson(json)).toList();
    }

    // Load time entries
    final timeEntriesData = localStorage.getItem('time_tracker_time_entries');
    if (timeEntriesData != null) {
      final List<dynamic> timeEntriesList = jsonDecode(timeEntriesData);
      _timeEntries = timeEntriesList
          .map((json) => TimeEntry.fromJson(json))
          .toList();
    }

    notifyListeners();
  }

  Future<void> _saveProjects() async {
    final projectsJson = jsonEncode(_projects.map((p) => p.toJson()).toList());
    localStorage.setItem('time_tracker_projects', projectsJson);
  }

  Future<void> _saveTasks() async {
    final tasksJson = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    localStorage.setItem('time_tracker_tasks', tasksJson);
  }

  Future<void> _saveTimeEntries() async {
    final timeEntriesJson = jsonEncode(
      _timeEntries.map((te) => te.toJson()).toList(),
    );
    localStorage.setItem('time_tracker_time_entries', timeEntriesJson);
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
