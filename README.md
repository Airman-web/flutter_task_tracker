# Project & SLA Task Tracker

A Flutter mobile app for creating and managing tasks in a small software team. Every task gets an SLA status based on its deadline, so it is easy to see what is on track and what needs attention.

Built for the Mobile Application Development course at ALU (Group30). There is no backend. All data is stored on the device with SQLite.

**Demo video:** [Watch the walkthrough](https://drive.google.com/file/d/1rxU7uo5TchwqXE5m6jQiIhIgsxl5Bzp9/view?usp=sharing)

## Features

- **Sign in and sign up:** register a local user and sign in.
- **Dashboard:** summary cards and a progress overview by SLA status.
- **Task list:** see all tasks with their SLA status.
- **Task details:** view one task and its actions.
- **Create and edit tasks:** set a title, description, assignee, due date and priority.
- **SLA status:** every task is On Track, At Risk, Overdue or Completed.
- **Team members:** view and manage team members.
- **Profile:** view the profile area.
- **Local storage:** tasks and team members are saved with SQLite, so they are still there after the app is closed and reopened.

## SLA Status

The rules compare calendar dates, not the time of day. They live in `lib/logic/sla_status.dart`.

| Status | Rule |
|---|---|
| Completed | The task is marked done, whatever the due date. |
| Overdue | Not done, and the due date is before today. |
| At Risk | Not done, and due today or within the next two days. |
| On Track | Not done, and due more than two days away. |

## Tech Stack

- Flutter and Dart
- SQLite through `sqflite` for local storage
- `path` for building the database file path
- `crypto` for hashing passwords in the local sign-in flow

## Project Structure

```
lib/
├── app/
│   ├── router.dart
│   └── theme.dart
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
├── services/
│   └── database_helper.dart
├── utils/
│   └── task_validators.dart
├── widgets/
│   ├── app_drawer.dart
│   └── member_avatar.dart
└── main.dart
test/
└── sla_status_test.dart
```

## Getting Started

### Requirements

- Flutter SDK (Dart is included)
- An Android emulator, an iOS simulator or a physical device

Run the app on an emulator or a device. `sqflite` does not work in a web browser.

### Run the app

```bash
git clone https://github.com/Airman-web/flutter_task_tracker.git
cd flutter_task_tracker
flutter pub get
flutter run
```

## Local Data and Sign In

The app uses a local SQLite database, not a remote server. The sign in and sign up flow is also local. Passwords are hashed with `crypto`, but this is not production authentication and does not replace a secure server-based system.

## Testing

```bash
flutter analyze
flutter test
```

`test/sla_status_test.dart` checks the SLA rules.

## Team

| Name | GitHub |
|---|---|
| David Chukwuebuka Achibiri | [@joules65](https://github.com/joules65) |
| Bulamba Isimbi Melissa | [@Melissa24808](https://github.com/Melissa24808) |
| Crispin Hebert Hirwa | [@Hirwavsopps](https://github.com/Hirwavsopps) |
| Emmanuel Ayomikun Atigbi | [@Airman-web](https://github.com/Airman-web) |
