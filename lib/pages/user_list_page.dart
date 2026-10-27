import 'package:flutter/material.dart';
 
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/user_avatar.dart';
import 'user_form_page.dart';
import 'user_profile_page.dart';
 
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});
 
  @override
  State<UserListPage> createState() => _UserListPageState();
}
 
class _UserListPageState extends State<UserListPage> {
  final _service = UserService();
 
  late Future<void> _loadFuture;
  List<UserModel> _users = [];
 
  @override
  void initState() {
    super.initState();
    _loadFuture = _loadUsers();
  }
 
  Future<void> _loadUsers() async {
    _users = await _service.getUsers();
  }
 
  void _reload() {
    setState(() => _loadFuture = _loadUsers());
  }
 
  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        ),
      );
  }
 
  // Buka form: user == null -> create (POST), user != null -> update (PUT)
  Future<void> _openForm({UserModel? user}) async {
    final result = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(builder: (_) => UserFormPage(user: user)),
    );
    if (result == null || !mounted) return;
 
    setState(() {
      if (user == null) {
        _users.insert(0, result);
      } else {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) _users[index] = result;
      }
    });
 
    _showSnack(user == null
        ? 'User "${result.fullName}" berhasil dibuat'
        : 'User "${result.fullName}" berhasil diperbarui');
  }
 
  // DELETE
  Future<void> _confirmDelete(UserModel user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Yakin ingin menghapus ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
 
    try {
      await _service.deleteUser(user.id);
      if (!mounted) return;
      setState(() => _users.removeWhere((u) => u.id == user.id));
      _showSnack('User "${user.fullName}" berhasil dihapus');
    } catch (e) {
      if (!mounted) return;
      _showSnack(errorMessage(e), isError: true);
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: _reload,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah'),
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
 
          // 2. Error
          if (snapshot.hasError) {
            return _ErrorView(
              message: errorMessage(snapshot.error!),
              onRetry: _reload,
            );
          }
 
          // 3. Kosong
          if (_users.isEmpty) {
            return const Center(child: Text('Belum ada data user.'));
          }
 
          // 4. Data
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: _users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = _users[index];
              return ListTile(
                leading: UserAvatar(user: user),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfilePage(user: user),
                  ),
                ),
                title: Text(user.fullName),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                      onPressed: () => _openForm(user: user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Hapus',
                      onPressed: () => _confirmDelete(user),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
 
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
 
  const _ErrorView({required this.message, required this.onRetry});
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
 