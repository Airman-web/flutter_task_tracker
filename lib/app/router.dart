import 'package:flutter/material.dart';

import '../screens/main_shell.dart';
import '../screens/placeholder_screens.dart';
import '../screens/sign_in_screen.dart';

/// All route names in one place so every teammate navigates the same way.
///
/// Usage:  Navigator.pushNamed(context, Routes.taskDetails, arguments: task);
class Routes {
  static const signIn = '/';
  static const home = '/home'; // Navigation shell (bottom tabs)

  // Pushed on top of the shell (full screen, with back button)
  static const taskDetails = '/task-details';
  static const createTask = '/create-task';
  static const taskStatistics = '/task-statistics';
}

class AppRouter {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case Routes.signIn:
        return _page(const SignInScreen(), settings);

      case Routes.home:
        // Optional: pass an int to open a specific tab (0 Home, 1 Tasks,
        // 2 Team, 3 Profile). Example: arguments: 2
        final initialTab = settings.arguments is int
            ? settings.arguments as int
            : 0;
        return _page(MainShell(initialIndex: initialTab), settings);

      // ---- Teammates: replace the placeholder widgets below with your
      // ---- real screens. Route names stay the same.
      case Routes.taskDetails:
        return _page(const TaskDetailsScreen(), settings);
      case Routes.createTask:
        return _page(const CreateTaskScreen(), settings);
      case Routes.taskStatistics:
        return _page(const TaskStatisticsScreen(), settings);

      default:
        return _page(const SignInScreen(), settings);
    }
  }

  static MaterialPageRoute _page(Widget child, RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => child, settings: settings);
}
