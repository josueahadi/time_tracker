import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import '../models/project.dart';
import '../models/task.dart';

class ProjectTaskManagementScreen extends StatefulWidget {
  final int initialTab;

  const ProjectTaskManagementScreen({super.key, this.initialTab = 0});

  @override
  _ProjectTaskManagementScreenState createState() =>
      _ProjectTaskManagementScreenState();
}

class _ProjectTaskManagementScreenState
    extends State<ProjectTaskManagementScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.index = widget.initialTab;
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF6A4C93),
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Projects'),
            Tab(text: 'Tasks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_ProjectsTab(), _TasksTab()],
      ),
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: provider.projects.length,
                itemBuilder: (context, index) {
                  final project = provider.projects[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(project.name),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteProjectDialog(context, project, provider);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteProjectDialog(
    BuildContext context,
    Project project,
    TimeEntryProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Project'),
        content: Text(
          'Are you sure you want to delete "${project.name}"? This will also delete all related time entries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteProject(project.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: provider.tasks.length,
                itemBuilder: (context, index) {
                  final task = provider.tasks[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(task.name),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteTaskDialog(context, task, provider);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteTaskDialog(
    BuildContext context,
    Task task,
    TimeEntryProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${task.name}"? This will also delete all related time entries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTask(task.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Add Project/Task Dialogs
void showAddProjectDialog(BuildContext context) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Add Project'),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Project Name',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              final project = Project(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: controller.text,
              );
              Provider.of<TimeEntryProvider>(
                context,
                listen: false,
              ).addProject(project);
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    ),
  );
}

void showAddTaskDialog(BuildContext context) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Add Task'),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Task Name',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              final task = Task(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: controller.text,
              );
              Provider.of<TimeEntryProvider>(
                context,
                listen: false,
              ).addTask(task);
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    ),
  );
}
