import 'package:flutter/material.dart';

import '../models/team_member.dart';

/// Circle avatar with the member's initials. Reusable by any screen.
class MemberAvatar extends StatelessWidget {
  final TeamMember member;
  final double radius;

  const MemberAvatar({super.key, required this.member, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: member.color,
      child: Text(
        member.initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }
}
