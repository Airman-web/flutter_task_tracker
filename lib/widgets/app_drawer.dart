import 'package:flutter/material.dart';

import '../app/router.dart';
import '../app/theme.dart';
import '../data/team_repository.dart';
import 'member_avatar.dart';

/// Side menu opened by the hamburger icon. Any screen can use it:
///   Scaffold(drawer: const AppDrawer(), ...)
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppSession.currentUser.value;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user != null) MemberAvatar(member: user, radius: 28),
                  const SizedBox(height: 12),
                  Text(user?.name ?? 'Guest',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  Text(user?.role ?? '',
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_rounded),
              title: const Text('Task Statistics'),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.pushNamed(context, Routes.taskStatistics);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_task_rounded),
              title: const Text('Create Task'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.createTask);
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text('Sign Out',
                  style: TextStyle(color: AppColors.danger)),
              onTap: () {
                AppSession.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, Routes.signIn, (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
