import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workgest/model/user_item.dart';

class UpdateUserScreen extends StatefulWidget {
  final UserItem userItem;
  final User user;
  final DocumentSnapshot snapshot;

  const UpdateUserScreen({
    super.key,
    required this.userItem,
    required this.user,
    required this.snapshot,
  });

  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _rolController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.userItem.nombre);
    _apellidoController = TextEditingController(text: widget.userItem.apellido);
    _rolController = TextEditingController(text: widget.userItem.rol);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _rolController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    try {
      await widget.snapshot.reference.update({
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'rol': _rolController.text.trim(),
      });
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar usuario'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _apellidoController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: _rolController,
              decoration: const InputDecoration(labelText: 'Rol'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: _updateUser,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
