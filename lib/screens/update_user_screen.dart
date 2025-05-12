import 'package:flutter/material.dart';
import 'package:workgest/model/user_item.dart';
import 'package:workgest/managers/user_manager.dart';

class UpdateUserScreen extends StatefulWidget {
  final UserItem userItem;

  UpdateUserScreen({
    Key? key,
    required this.userItem,
  }) : super(key: key);

  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _typeController;
  final UserManager _userManager = UserManager();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userItem.name);
    _emailController = TextEditingController(text: widget.userItem.email);
    _typeController = TextEditingController(text: widget.userItem.type);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    final updatedUser = UserItem(
      id: widget.userItem.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      type: _typeController.text.trim(),
    );

    try {
      await _userManager.updateUser(
        updatedUser,
        oldMonitorName: widget.userItem.name,
        newMonitorName: _nameController.text.trim(),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update User'),
        actions: [
          TextButton(
            onPressed: _updateUser,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _updateUser,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
