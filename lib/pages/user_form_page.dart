import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

/// Form untuk membuat user baru (POST) atau mengubah user (PUT).
/// Jika [user] diisi, form berjalan dalam mode edit.
class UserFormPage extends StatefulWidget {
  final UserModel? user;

  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = UserService();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;

  bool _isSubmitting = false;

  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.user?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: widget.user?.lastName ?? '');
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final firstName = _firstNameCtrl.text.trim();
      final lastName = _lastNameCtrl.text.trim();
      final email = _emailCtrl.text.trim();

      final UserModel result;
      if (_isEdit) {
        result = await _service.updateUser(
          widget.user!,
          firstName: firstName,
          lastName: lastName,
          email: email,
        );
      } else {
        result = await _service.createUser(
          firstName: firstName,
          lastName: lastName,
          email: email,
        );
      }

      if (!mounted) return;
      // Hasil dikirim balik ke halaman list yang menampilkan SnackBar sukses.
      Navigator.pop(context, result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage(e)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email wajib diisi';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(text)) return 'Format email tidak valid';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit User' : 'Tambah User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Depan',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) => _required(v, 'Nama depan'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Belakang',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) => _required(v, 'Nama belakang'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEdit ? 'Simpan Perubahan' : 'Buat User'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}