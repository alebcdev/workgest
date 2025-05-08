import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workgest/model/user_item.dart';

class UpdateMyUserDialog extends StatefulWidget {
  final UserItem userItem;
  final User user;
  final DocumentSnapshot snapshot;
  final int classID;

  const UpdateMyUserDialog(
      this.userItem, this.user, {
        required this.snapshot,
        required this.classID,
        super.key,
      });

  @override
  _UpdateMyUserDialogState createState() => _UpdateMyUserDialogState();
}

class _UpdateMyUserDialogState extends State<UpdateMyUserDialog> {
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.userItem.nombre);
    _apellidoController = TextEditingController(text: widget.userItem.apellido);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    try {
      await widget.snapshot.reference.update({
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
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
      title: const Text('Editar Perfil'),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _updateUser,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
