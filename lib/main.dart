import 'package:flutter/material.dart';

import 'app/router.dart';
import 'app/theme.dart';

void main() => runApp(const SlaTrackerApp());

class SlaTrackerApp extends StatelessWidget {
  const SlaTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project & SLA Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: Routes.signIn,
      onGenerateRoute: AppRouter.generate,
    );
  }
}
