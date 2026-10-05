import 'package:flutter/material.dart';

import 'placeholder_screens.dart';
import 'team_members_screen.dart';

/// Navigation shell: bottom navigation with 4 tabs.
/// Each tab keeps its state thanks to IndexedStack.
///
/// Teammates: swap the placeholder tab widgets below for your real screens
/// (DashboardScreen, TaskListScreen, ProfileScreen).
class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex.clamp(0, 3);

  // Same order as the bottom bar items below.
  final List<Widget> _tabs = const [
    DashboardScreen(), // 0 Home
    TaskListScreen(), // 1 Tasks
    TeamMembersScreen(), // 2 Team
    ProfileScreen(), // 3 Profile
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back on a non-home tab returns to Home instead of leaving the app.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _index = 0);
      },
      child: Scaffold(
        body: IndexedStack(index: _index, children: _tabs),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_box_outlined),
              activeIcon: Icon(Icons.check_box_rounded),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups_rounded),
              label: 'Team',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
