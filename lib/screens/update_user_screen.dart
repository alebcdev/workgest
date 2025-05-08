import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workgest/model/user_item.dart';
import 'package:workgest/managers/user_manager.dart';

class UpdateUserScreen extends StatefulWidget {
  final UserItem userItem;
  final UserManager userManager = UserManager();

  const UpdateUserScreen({
    Key? key,
    required this.userItem,
  });

  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _typeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userItem.name);
    _emailController = TextEditingController(text: widget.userItem.email);
    _typeController = TextEditingController(text: widget.userItem.type);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _rolController.dispose();
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
      await widget.userManager.updateUser(updatedUser);
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
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: _updateUser,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
