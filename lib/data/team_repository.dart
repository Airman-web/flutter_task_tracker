import 'package:flutter/material.dart';

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

  List<TeamMember> get members => List.unmodifiable(_members);

  TeamMember? byEmail(String email) {
    final e = email.trim().toLowerCase();
    for (final m in _members) {
      if (m.email.toLowerCase() == e) return m;
    }
    return null;
  }

  void add({required String name, required String role, required String email}) {
    _members.add(TeamMember(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      role: role,
      email: email,
      color: _palette[_members.length % _palette.length],
    ));
    notifyListeners();
  }

  void update(TeamMember updated) {
    final i = _members.indexWhere((m) => m.id == updated.id);
    if (i == -1) return;
    _members[i] = updated;
    // Keep the signed-in user in sync if they were edited.
    if (AppSession.currentUser.value?.id == updated.id) {
      AppSession.currentUser.value = updated;
    }
    notifyListeners();
  }

  void remove(String id) {
    _members.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}

/// Who is currently signed in. Read it anywhere:
///   AppSession.currentUser.value
class AppSession {
  static final ValueNotifier<TeamMember?> currentUser = ValueNotifier(null);

  static void signIn(TeamMember user) => currentUser.value = user;
  static void signOut() => currentUser.value = null;
}
