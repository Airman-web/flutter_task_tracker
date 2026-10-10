import 'package:flutter/material.dart';
import 'team_members_screen.dart';
import 'profile_screen.dart';
import '../data/task_repository.dart';
import 'dashboard_screen.dart';
import 'task_list_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int get _initialIndex => widget.initialIndex.clamp(0, 3);

  late int _selectedIndex = _initialIndex;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Rebuild whenever a task is added, edited or deleted
    TaskRepository.instance.addListener(_onTasksChanged);
    _loadTasks();
  }

  @override
  void dispose() {
    TaskRepository.instance.removeListener(_onTasksChanged);
    super.dispose();
  }

  void _onTasksChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadTasks() async {
    try {
      await TaskRepository.instance.load();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = TaskRepository.instance.tasks;
    final screens = [
      DashboardScreen(tasks: tasks),
      TaskListScreen(tasks: tasks),
      const TeamMembersScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: (value) {
            setState(() {
              _selectedIndex = value;
            });
          },
          selectedItemColor: const Color(0xFF2C6EEA),
          unselectedItemColor: const Color(0xFF6E7788),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Team',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
