import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/time_entry_provider.dart';
import '../models/time_entry.dart';
import 'add_time_entry_screen.dart';
import 'project_task_management_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isGroupedByProjects = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Time Tracking', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4A9B8E),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) {
            setState(() {
              _isGroupedByProjects = index == 1;
            });
          },
          tabs: [
            Tab(text: 'All Entries'),
            Tab(text: 'Grouped by Projects'),
          ],
        ),
      ),
      drawer: _buildDrawer(),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          if (provider.timeEntries.isEmpty) {
            return _buildEmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllEntries(provider),
              _buildGroupedEntries(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTimeEntryScreen()),
          );
        },
        backgroundColor: Colors.amber,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            color: Color(0xFF4A9B8E),
            child: Center(
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.folder),
            title: Text('Projects'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProjectTaskManagementScreen(initialTab: 0),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.task),
            title: Text('Tasks'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProjectTaskManagementScreen(initialTab: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, size: 80, color: Colors.grey[400]),
          SizedBox(height: 20),
          Text(
            'No time entries yet!',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 10),
          Text(
            'Tap the + button to add your first entry.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAllEntries(TimeEntryProvider provider) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: provider.timeEntries.length,
      itemBuilder: (context, index) {
        final entry = provider.timeEntries[index];
        return _buildTimeEntryCard(entry, provider);
      },
    );
  }

  Widget _buildGroupedEntries(TimeEntryProvider provider) {
    final groupedEntries = provider.getTimeEntriesGroupedByProject();

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: groupedEntries.keys.length,
      itemBuilder: (context, index) {
        final projectId = groupedEntries.keys.elementAt(index);
        final entries = groupedEntries[projectId]!;
        final project = provider.getProjectById(projectId);

        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              project?.name ?? 'Unknown Project',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${entries.length} entries'),
            children: entries
                .map((entry) => _buildTimeEntryCard(entry, provider))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildTimeEntryCard(TimeEntry entry, TimeEntryProvider provider) {
    final project = provider.getProjectById(entry.projectId);
    final task = provider.getTaskById(entry.taskId);

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          '${project?.name ?? 'Unknown'} - ${task?.name ?? 'Unknown'}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('yyyy-MM-dd').format(entry.date)}'),
            Text('Time: ${entry.totalTime} hours'),
            if (entry.note.isNotEmpty) Text('Note: ${entry.note}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _showDeleteDialog(context, entry, provider);
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    TimeEntry entry,
    TimeEntryProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Entry'),
        content: Text('Are you sure you want to delete this time entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTimeEntry(entry.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
