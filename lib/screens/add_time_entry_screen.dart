import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/time_entry_provider.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  _AddTimeEntryScreenState createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _timeController = TextEditingController(text: '1');
  final _noteController = TextEditingController();

  Project? _selectedProject;
  Task? _selectedTask;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Time Entry', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4A9B8E),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Selection
                  Text(
                    'Project',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<Project>(
                    value: _selectedProject,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    hint: Text('Select Project'),
                    items: provider.projects.map((project) {
                      return DropdownMenuItem(
                        value: project,
                        child: Text(project.name),
                      );
                    }).toList(),
                    onChanged: (project) {
                      setState(() {
                        _selectedProject = project;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a project';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Task Selection
                  Text(
                    'Task',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<Task>(
                    value: _selectedTask,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    hint: Text('Select Task'),
                    items: provider.tasks.map((task) {
                      return DropdownMenuItem(
                        value: task,
                        child: Text(task.name),
                      );
                    }).toList(),
                    onChanged: (task) {
                      setState(() {
                        _selectedTask = task;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a task';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Date Selection
                  Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Select Date'),
                  ),
                  SizedBox(height: 16),

                  // Time Input
                  Text(
                    'Total Time (in hours)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _timeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter time';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Note Input
                  Text(
                    'Note',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      hintText: 'Enter note (optional)',
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveTimeEntry(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A9B8E),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Save Time Entry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTimeEntry(TimeEntryProvider provider) {
    if (_formKey.currentState!.validate()) {
      final timeEntry = TimeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: _selectedProject!.id,
        taskId: _selectedTask!.id,
        date: _selectedDate,
        totalTime: double.parse(_timeController.text),
        note: _noteController.text,
      );

      provider.addTimeEntry(timeEntry);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
