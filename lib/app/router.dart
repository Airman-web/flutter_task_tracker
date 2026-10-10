import 'package:flutter/material.dart';

import '../models/task.dart';
import '../screens/main_shell.dart';
import '../screens/sign_in_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/task_detail_screen.dart';
import '../screens/task_form_screen.dart';

class Routes {
  static const signIn = '/';
  static const signUp = '/sign-up';
  static const home = '/home';

  static const taskDetails = '/task-details';
  static const createTask = '/create-task';
  static const taskStatistics = '/task-statistics';
}

class AppRouter {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case Routes.signIn:
        return _page(const SignInScreen(), settings);

      case Routes.signUp:
        return _page(const SignUpScreen(), settings);

      case Routes.home:
        final initialTab = settings.arguments is int
            ? settings.arguments as int
            : 0;

        return _page(MainShell(initialIndex: initialTab), settings);

      case Routes.taskDetails:
        final task = settings.arguments;

        if (task is Task) {
          return _page(TaskDetailScreen(task: task), settings);
        }

        return _page(
          const _RouteErrorScreen(
            message: 'A task must be provided to view task details.',
          ),
          settings,
        );

      case Routes.createTask:
        final task = settings.arguments;

        if (task == null || task is Task) {
          return _page(TaskFormScreen(task: task as Task?), settings);
        }

        return _page(
          const _RouteErrorScreen(message: 'Invalid task provided.'),
          settings,
        );

      case Routes.taskStatistics:
        return _page(const _StatisticsComingSoonScreen(), settings);

      default:
        return _page(const SignInScreen(), settings);
    }
  }

  static MaterialPageRoute _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}

class _StatisticsComingSoonScreen extends StatelessWidget {
  const _StatisticsComingSoonScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Statistics')),
      body: const Center(
        child: Text('Task statistics will be available soon.'),
      ),
    );
  }
}

class _RouteErrorScreen extends StatelessWidget {
  final String message;

  const _RouteErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(child: Text(message)),
    );
  }
}
