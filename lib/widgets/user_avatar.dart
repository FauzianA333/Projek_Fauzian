import 'package:flutter/material.dart';

import '../models/user_model.dart';

/// Widget avatar yang bisa dipakai ulang di daftar maupun halaman profil.
/// - Menampilkan foto dari URL avatar
/// - Menampilkan indikator loading saat gambar dimuat
/// - Jika URL kosong atau gagal dimuat, menampilkan inisial nama
class UserAvatar extends StatelessWidget {
  final UserModel user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 20});

  String get _initials {
    final first = user.firstName.isNotEmpty ? user.firstName[0] : '';
    final last = user.lastName.isNotEmpty ? user.lastName[0] : '';
    final text = '$first$last'.toUpperCase();
    return text.isEmpty ? '?' : text;
  }

  Widget _buildFallback(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: user.avatar.isEmpty
            ? _buildFallback(context)
            : Image.network(
                user.avatar,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallback(context),
              ),
      ),
    );
  }
}
