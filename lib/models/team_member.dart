import 'package:flutter/material.dart';

class TeamMember {
  final String id;
  final String name;
  final String role;
  final String email;
  final Color color;

  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.color,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  TeamMember copyWith({String? name, String? role, String? email}) {
    return TeamMember(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      color: color,
    );
  }
}
