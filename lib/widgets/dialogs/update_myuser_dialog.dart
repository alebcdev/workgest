import 'package:flutter/material.dart';
import 'package:workgest/managers/user_manager.dart';
import 'package:workgest/model/user_item.dart';

class UpdateMyUserDialog extends StatefulWidget {
  final UserItem userItem;

  const UpdateMyUserDialog(this.userItem, {super.key});

  @override
  _UpdateMyUserDialogState createState() => _UpdateMyUserDialogState();
}

class _UpdateMyUserDialogState extends State<UpdateMyUserDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _typeController;

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
    try {
      await widget.snapshot.reference.update({
        'nombre': _nombreController.text.trim(),
        'email': _emailController.text.trim(),
        'type': _typeController.text.trim(),
      });
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Placeholder for name TextField
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            // Placeholder for email TextField
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            // Placeholder for type TextField
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _updateUser,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
