Project & SLA Task Tracker
Overview
Project & SLA Task Tracker is a Flutter application for creating and
managing tasks while keeping track of deadlines and SLA status. It
includes a dashboard, task management screens, team-member management,
and sign-in/sign-up screens.
The app is built as a frontend project and uses SQLite for local storage
of supported task and team-member data.
Main Features
- Sign in and sign up: screens for entering the app and
  registering a local user.
- Dashboard: summary cards and an overview of task progress and
  SLA categories.
- Task list: view the tasks available in the app.
- Task details: view information about a selected task and access
  task actions.
- Create and edit tasks: enter task information, assign a team
  member, set a due date and priority, and update existing tasks.
- SLA status: classify tasks as On Track, At Risk, Overdue, or
  Completed according to the rules in the app.
- Team members: view and manage team-member information.
- Profile: view the profile area within the app.
- Local persistence: SQLite (sqflite) stores supported task and
  team-member data.
Technology Used
- Flutter for the user interface.
- Dart for application logic.
- SQLite with sqflite for local storage.
- path to help build database file paths.
- crypto for hashing passwords in the local sign-in/sign-up
  flow.
Project Structure
lib/
├── app/
│   └── router.dart
├── data/
│   ├── sample_tasks.dart
│   ├── task_repository.dart
│   └── team_repository.dart
├── logic/
│   └── sla_status.dart
├── models/
│   ├── task.dart
│   └── team_member.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── main_shell.dart
│   ├── profile_screen.dart
│   ├── sign_in_screen.dart
│   ├── sign_up_screen.dart
│   ├── task_detail_screen.dart
│   ├── task_form_screen.dart
│   ├── task_list_screen.dart
│   └── team_members_screen.dart
└── services/
    └── database_helper.dart
The structure may change as the team continues development.
Getting Started
Requirements
- Flutter SDK
- Dart SDK (included with Flutter)
- An Android emulator, iOS simulator, or supported device
Run the app
1. Clone the repository:
   git clone <repository-url>
2. Move into the project directory:
   cd <project-folder>
3. Install dependencies:
   flutter pub get
4. Check the project:
   flutter analyze
5. Run the app:
   flutter run
Replace <repository-url> and <project-folder> with the actual
values.
Local Data and Authentication
The project uses a local SQLite database rather than a remote backend.
This suits the assignment requirement to demonstrate local persistence
without building a backend service.
The sign-in/sign-up flow is local and should not be treated as
production authentication. It does not replace a secure server-based
authentication system. Test the actual registration, sign-in, and
persistence behaviour before the demonstration.
SLA Status
The app uses four SLA categories:
- On Track
- At Risk
- Overdue
- Completed
The exact conditions are defined in lib/logic/sla_status.dart. Review
that file and explain the implemented At Risk rule during the
demonstration. Do not assume a threshold that is not present in the
code.
Testing Before the Demo
- Register a user and test sign-in with valid and invalid details.
- Create a task and confirm it appears in the task list and dashboard.
- Edit a task and confirm the changes appear.
- Test task completion and deletion.
- Check that task statuses match the SLA logic.
- Close and reopen the app to check whether saved data remains
  available.
- Test form validation and error messages.
- Run flutter analyze and address any reported issues.
Only describe a feature as working in the demo after testing it.
Team Contributions
This is a group project. Each team member should document their own work
in the contribution tracker and make meaningful commits on their
assigned Git branch. The repository history should accurately reflect
each member's work.
