import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/team_member.dart';

/// In-memory team list. Teammates can use `TeamRepository.instance.members`
/// for the "Assign To" dropdown and avatars.
class TeamRepository extends ChangeNotifier {
  TeamRepository._();
  static final TeamRepository instance = TeamRepository._();

  static const _palette = <Color>[
    Color(0xFF1E64D0),
    Color(0xFF7FB77E),
    Color(0xFF9B8AE0),
    Color(0xFF2F6FB5),
    Color(0xFF2EB67D),
    Color(0xFFE08A3C),
    Color(0xFFD65DB1),
  ];

  final List<TeamMember> _members = [
    const TeamMember(
      id: '1',
      name: 'John Doe',
      role: 'Project Manager',
      email: 'john@team.com',
      color: Color(0xFF1E64D0),
    ),
    const TeamMember(
      id: '2',
      name: 'Sarah Lee',
      role: 'UI/UX Designer',
      email: 'sarah@team.com',
      color: Color(0xFF7FB77E),
    ),
    const TeamMember(
      id: '3',
      name: 'Michael Kim',
      role: 'Mobile Developer',
      email: 'michael@team.com',
      color: Color(0xFF9B8AE0),
    ),
    const TeamMember(
      id: '4',
      name: 'Emily Wong',
      role: 'QA Tester',
      email: 'emily@team.com',
      color: Color(0xFF2F6FB5),
    ),
    const TeamMember(
      id: '5',
      name: 'David Liu',
      role: 'Documentation',
      email: 'david@team.com',
      color: Color(0xFF2EB67D),
    ),
  ];

Future<void> registerMember({
  required String name,
  required String role,
  required String email,
  required String password,
}) async {
  final normalizedEmail = email.trim().toLowerCase();

  if (byEmail(normalizedEmail) != null) {
    throw Exception('An account with this email already exists.');
  }

  final member = TeamMember(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    name: name.trim(),
    role: role,
    email: normalizedEmail,
    color: _palette[_members.length % _palette.length],
  );

  await DatabaseHelper.instance.insertTeamMember(
    member: member,
    password: password,
  );

  _members.add(member);
  notifyListeners();
}

Future<void> loadRegisteredMembers() async {
  final rows = await DatabaseHelper.instance.getAllTeamMembers();

  for (final row in rows) {
    final email = row['email'] as String;
    final existingIndex = _members.indexWhere(
      (member) => member.email.toLowerCase() == email.toLowerCase(),
    );

    final member = TeamMember(
      id: row['id'] as String,
      name: row['name'] as String,
      role: row['role'] as String,
      email: email,
      color: Color(row['colorValue'] as int),
    );

    if (existingIndex == -1) {
      _members.add(member);
    } else {
      _members[existingIndex] = member;
    }
  }

  notifyListeners();
}


List<TeamMember> get members => List.unmodifiable(_members);

TeamMember? byEmail(String email) {
  final normalizedEmail = email.trim().toLowerCase();

  for (final member in _members) {
    if (member.email.toLowerCase() == normalizedEmail) {
      return member;
    }
  }

  return null;
}

void add({
  required String name,
  required String role,
  required String email,
}) {
  final normalizedEmail = email.trim().toLowerCase();

  if (byEmail(normalizedEmail) != null) return;

  _members.add(
    TeamMember(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      role: role,
      email: normalizedEmail,
      color: _palette[_members.length % _palette.length],
    ),
  );

  notifyListeners();
}

Future<void> update(TeamMember updated) async {
  final index = _members.indexWhere(
    (member) => member.id == updated.id,
  );

  if (index == -1) return;

  final isRegistered = await DatabaseHelper.instance
      .getTeamMemberByEmail(_members[index].email);

  if (isRegistered != null &&
      isRegistered['id'] == updated.id) {
    await DatabaseHelper.instance.updateTeamMember(updated);
  }

  _members[index] = updated;

  if (AppSession.currentUser.value?.id == updated.id) {
    AppSession.currentUser.value = updated;
  }

  notifyListeners();
}

void remove(String id) {
  _members.removeWhere((member) => member.id == id);
  notifyListeners();
}


Future<TeamMember?> authenticate({
  required String email,
  required String password,
}) async {
  await loadRegisteredMembers();

  final row = await DatabaseHelper.instance.getTeamMemberByEmail(email);

  if (row == null) return null;

  final savedHash = row['passwordHash'] as String;

  if (!DatabaseHelper.instance.verifyPassword(password, savedHash)) {
    return null;
  }

  return byEmail(email);
}
}

/// Who is currently signed in. Read it anywhere:
/// AppSession.currentUser.value
class AppSession {
  static final ValueNotifier<TeamMember?> currentUser =
      ValueNotifier<TeamMember?>(null);

  static void signIn(TeamMember user) {
    currentUser.value = user;
  }

  static void signOut() {
    currentUser.value = null;
  }
}
