import 'package:flutter/material.dart';
import 'package:test/widgets/custom_button.dart';

import '../core/repository/shared_prefs_user_repository.dart';
import '../core/repository/user_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserRepository _repo = SharedPrefsUserRepository();
  final TextEditingController _emailController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = await _repo.getUser();
    if (user != null) {
      setState(() {
        _emailController.text = user['email'] ?? '';
      });
    }
  }

  void _saveChanges() async {
    await _repo.saveUser(_emailController.text, (await _repo.getUser())?['password'] ?? '');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved')),
    );
    setState(() => _isEditing = false);
  }

  void _deleteUser() async {
    await _repo.clearUser();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User deleted')),
    );
    setState(() {
      _emailController.clear();
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            if (_isEditing) ...[
              CustomButton(text: 'Save Changes', onPressed: _saveChanges),
              const SizedBox(height: 10),
              CustomButton(text: 'Delete User', onPressed: _deleteUser),
            ],
          ],
        ),
      ),
    );
  }
}