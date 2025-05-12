import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../managers/material_manager.dart';
import '../managers/user_manager.dart';

class MaterialScreen extends StatefulWidget {
  final User user;
  const MaterialScreen(this.user, {super.key});

  @override
  _MaterialScreenState createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final Stream<QuerySnapshot> _materialStream = MaterialManager.getMaterialStream();
  String userRol = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await UserManager.getUserRole(widget.user);
    if (role != null) {
      setState(() => userRol = role);
    }
  }

  void _actualizarDisponibilidad(String id, int disponible, int cambio) {
    final nuevo = disponible + cambio;
    if (nuevo >= 0) {
      MaterialManager.updateMaterialAvailability(id, nuevo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final pad = sw * 0.02;
    final fLarge = sh * 0.025;
    final fMedium = sh * 0.02;
    final iconSz = sh * 0.04;
    final imgH = sh * 0.15;

    return Scaffold(
      appBar: AppBar(
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

          // Aquí usamos "materials" tanto al poblar como al iterar
          final Map<String, int> materials = {};
          for (var doc in snap.data!.docs) {
            materials[doc.id] = (doc['quantity'] as int? ?? 0);
          }

          return ListView(
            children: materials.entries.map((entry) {
              final id = entry.key;
              final available = entry.value;
              // Buscamos el documento concreto para extraer el nombre
              final doc = snap.data!.docs.firstWhere((d) => d.id == id);
              final name = (doc['name'] as String? ?? 'Sin nombre');
              final imagePath = 'assets/images/${name.toLowerCase().replaceAll(' ', '_')}.png';

              return Padding(
                padding: EdgeInsets.all(pad),
                child: Card(
                  child: Column(
                    children: [
                      Text(name, style: TextStyle(fontSize: fLarge, fontWeight: FontWeight.bold)),
                      Text(
                        available > 0 ? 'Disponible: $available' : 'No disponible',
                        style: TextStyle(
                          fontSize: fMedium,
                          color: available > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (userRol == 'Administrador')
                            IconButton(
                              onPressed: available > 0
                                  ? () => _actualizarDisponibilidad(id, available, -1)
                                  : null,
                              icon: Icon(Icons.remove, size: iconSz),
                            ),
                          Expanded(
                            child: Image.asset(imagePath, height: imgH, fit: BoxFit.contain),
                          ),
                          if (userRol == 'Administrador')
                            IconButton(
                              onPressed: () => _actualizarDisponibilidad(id, available, 1),
                              icon: Icon(Icons.add, size: iconSz),
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
    );
  }
}
