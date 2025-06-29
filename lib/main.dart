import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/time_entry_provider.dart';
import 'screens/home_screen.dart';
import 'screens/project_task_management_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimeEntryProvider(),
      child: MaterialApp(
        title: 'Time Tracker',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
        routes: {
          '/projects': (context) => ProjectTaskManagementScreen(initialTab: 0),
          '/tasks': (context) => ProjectTaskManagementScreen(initialTab: 1),
        },
      ),
    );
  }
}
