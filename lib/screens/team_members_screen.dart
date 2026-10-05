import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/team_repository.dart';
import '../models/team_member.dart';
import '../widgets/app_drawer.dart';
import '../widgets/member_avatar.dart';

class TeamMembersScreen extends StatelessWidget {
  const TeamMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = TeamRepository.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Team Members'),
        actions: [
          IconButton(
            tooltip: 'Add member',
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            onPressed: () => _showMemberDialog(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: repo,
        builder: (context, _) {
          final members = repo.members;
          if (members.isEmpty) {
            return const Center(
              child: Text('No team members yet.',
                  style: TextStyle(color: AppColors.textMuted)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _MemberTile(member: members[i]),
          );
        },
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final TeamMember member;
  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final isMe = AppSession.currentUser.value?.id == member.id;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 14, right: 4),
        leading: MemberAvatar(member: member),
        title: Row(
          children: [
            Flexible(
              child: Text(member.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            if (isMe) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('You',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
        subtitle: Text(member.role,
            style: const TextStyle(color: AppColors.textMuted)),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'edit') {
              _showMemberDialog(context, existing: member);
            } else if (value == 'remove') {
              _confirmRemove(context, member);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            if (!isMe)
              const PopupMenuItem(
                value: 'remove',
                child:
                    Text('Remove', style: TextStyle(color: AppColors.danger)),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmRemove(BuildContext context, TeamMember m) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Remove member?'),
      content: Text('${m.name} will be removed from the team.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove',
                style: TextStyle(color: AppColors.danger))),
      ],
    ),
  );
  if (ok == true) TeamRepository.instance.remove(m.id);
}

/// Add (existing == null) or edit a team member.
Future<void> _showMemberDialog(BuildContext context,
    {TeamMember? existing}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final role = TextEditingController(text: existing?.role ?? '');
  final email = TextEditingController(text: existing?.email ?? '');
  final formKey = GlobalKey<FormState>();

  String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? 'Add Team Member' : 'Edit Team Member'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Full name'),
              validator: required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: role,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Role'),
              validator: required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Email'),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            final repo = TeamRepository.instance;
            if (existing == null) {
              repo.add(
                name: name.text.trim(),
                role: role.text.trim(),
                email: email.text.trim(),
              );
            } else {
              repo.update(existing.copyWith(
                name: name.text.trim(),
                role: role.text.trim(),
                email: email.text.trim(),
              ));
            }
            Navigator.pop(ctx);
          },
          child: Text(existing == null ? 'Add' : 'Save'),
        ),
      ],
    ),
  );

  name.dispose();
  role.dispose();
  email.dispose();
}
