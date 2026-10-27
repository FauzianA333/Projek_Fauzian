import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../widgets/user_avatar.dart';

/// Menampilkan detail profil satu user.
class UserProfilePage extends StatelessWidget {
  final UserModel user;

  const UserProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            UserAvatar(user: user, radius: 64),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.badge_outlined,
                    label: 'ID',
                    value: user.id.toString(),
                  ),
                  const Divider(height: 1),
                  _InfoTile(
                    icon: Icons.person_outline,
                    label: 'Nama Depan',
                    value: user.firstName,
                  ),
                  const Divider(height: 1),
                  _InfoTile(
                    icon: Icons.person_outline,
                    label: 'Nama Belakang',
                    value: user.lastName,
                  ),
                  const Divider(height: 1),
                  _InfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(
        value.isEmpty ? '-' : value,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
