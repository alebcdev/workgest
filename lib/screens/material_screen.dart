import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:workgest/model/material_item.dart';
import '../managers/material_manager.dart';
import '../managers/user_manager.dart';

class MaterialScreen extends StatefulWidget {
  final User user;
  const MaterialScreen(this.user, {super.key});

  @override
  MaterialScreenState createState() => MaterialScreenState();
}

class MaterialScreenState extends State<MaterialScreen> {
  final Stream<QuerySnapshot> _materialStream = MaterialManager.getMaterialStream();
  String userRol = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await UserManager.getUserRole(widget.user);
    if (role != null) {
      setState(() {
        userRol = role;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showMaterialForm({MaterialItem? materialToEdit}) async {
    final nameController = TextEditingController(text: materialToEdit?.name ?? '');
    final quantityController = TextEditingController(text: materialToEdit?.quantity.toString() ?? '');
    final descriptionController = TextEditingController(text: materialToEdit?.description ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(materialToEdit == null ? 'Add New Material' : 'Edit Material'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Material Name'),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  quantityController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                final quantity = int.tryParse(quantityController.text) ?? 0;
                await MaterialManager.addOrUpdateMaterial(
                  materialToEdit?.id,
                  nameController.text,
                  descriptionController.text,
                  quantity,
                );
                Navigator.pop(context);
              }
            },
            child: Text(materialToEdit == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _incrementQuantity(String id, int currentQuantity) {
    MaterialManager.updateMaterialAvailability(id, currentQuantity + 1);
  }

  void _decrementQuantity(String id, int currentQuantity) {
    if (currentQuantity > 0) {
      MaterialManager.updateMaterialAvailability(id, currentQuantity - 1);
    }
  }

  Future<void> _confirmDelete(String id) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this material?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm) {
      MaterialManager.deleteMaterial(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final pad = sw * 0.02;

    final bool isAdmin = userRol == 'Administrador';
    final fLarge = Theme.of(context).textTheme.titleLarge?.fontSize ?? 18.0;
    final fMedium = Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14.0;
    final imgH = sh * 0.15;

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Text('Materiales', style: TextStyle(fontSize: fLarge)),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _materialStream,
        builder: (ctx, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Error de conexión'));
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('No hay material.'));
          }

          final materials = snap.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            final quantity = data?['quantity'] as int?;
            final name = data?['name'] as String? ?? 'Sin nombre';
            final description = data?['description'] as String? ?? '';
            return MaterialItem(id: doc.id, name: name, quantity: quantity ?? 0, description: description);
          }).toList();

          materials.sort((a, b) => a.name.compareTo(b.name));

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8.0),
            children: materials.map((material) {
              final imagePath = 'assets/images/${material.name.toLowerCase().replaceAll(' ', '_')}.png';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(material.name,
                                style: TextStyle(fontSize: fLarge, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0),
                            Text('Available: ${material.quantity}', style: TextStyle(fontSize: fMedium)),
                            const SizedBox(height: 4.0),
                            Text(material.description, style: TextStyle(fontSize: fMedium, fontStyle: FontStyle.italic)),
                            const SizedBox(height: 16.0),
                            if (isAdmin)
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showMaterialForm(materialToEdit: material),
                                    tooltip: 'Edit Material',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _confirmDelete(material.id),
                                    tooltip: 'Delete Material',
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Image.asset(
                        imagePath,
                        height: imgH,
                        width: imgH,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.error, size: imgH, color: Colors.red,),
                      ),
                      if (isAdmin)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _incrementQuantity(material.id, material.quantity),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _decrementQuantity(material.id, material.quantity),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Add New Material',
            onTap: _showMaterialForm,
          ),
        ],
      )
          : null,
    );
  }
}
