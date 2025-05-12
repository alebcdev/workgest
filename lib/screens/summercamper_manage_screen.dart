import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workgest/model/summercamper_item.dart';
import 'package:workgest/managers/user_manager.dart';
import 'package:workgest/managers/summer_camper_manager.dart';
import 'package:workgest/screens/summercamper_registration_screen.dart';

class SummerCamperManage extends StatefulWidget {
  final User user;
  const SummerCamperManage(this.user, {super.key});

  @override
  _SummerCamperManageState createState() => _SummerCamperManageState();
}

class _SummerCamperManageState extends State<SummerCamperManage> {
  final SummerCamperManager _manager = SummerCamperManager();
  late Stream<List<SummerCamper>> _campersStream;
  String _selectedMonitor = 'Todos';
  String userRol = '';

  @override
  void initState() {
    super.initState();
    _campersStream = _manager.getSummerCampersStream();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await UserManager.getUserRole(widget.user);
    if (mounted) {
      setState(() => userRol = role ?? '');
    }
  }

  Color _colorTile(int index) => index.isEven ? Colors.black12 : Colors.white;

  void _showManageDialog({SummerCamper? camper}) {
    final nameCtrl    = TextEditingController(text: camper?.nombre ?? '');
    final lastCtrl    = TextEditingController(text: camper?.apellido ?? '');
    final ageCtrl     = TextEditingController(text: camper?.edad.toString() ?? '');
    final monitorCtrl = TextEditingController(text: camper?.monitor ?? '');
    final groupCtrl   = TextEditingController(text: camper?.group ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(camper == null ? 'Registrar Alumno' : 'Editar Alumno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl,    decoration: const InputDecoration(hintText: 'Nombre')),
            TextField(controller: lastCtrl,    decoration: const InputDecoration(hintText: 'Apellido')),
            TextField(controller: ageCtrl,     decoration: const InputDecoration(hintText: 'Edad'), keyboardType: TextInputType.number),
            TextField(controller: monitorCtrl, decoration: const InputDecoration(hintText: 'Monitor')),
            TextField(controller: groupCtrl,   decoration: const InputDecoration(hintText: 'Grupo')),
          ],
        ),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: Text(camper == null ? 'Registrar' : 'Guardar'),
            onPressed: () async {
              final name    = nameCtrl.text.trim();
              final last    = lastCtrl.text.trim();
              final age     = int.tryParse(ageCtrl.text.trim()) ?? 0;
              final monitor = monitorCtrl.text.trim();
              final group   = groupCtrl.text.trim();

              if ([name, last, monitor, group].any((s) => s.isEmpty) || age <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Completa todos los campos correctamente.')),
                );
                return;
              }

              if (camper == null) {
                // create
                await _manager.createSummerCamper(name, last, age, monitor);
              } else {
                // update
                await _manager.updateSummerCamper(
                  camper.id, name, last, age, monitor,
                );
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(SummerCamper camper) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Alumno'),
        content: Text('¿Eliminar a ${camper.nombre} ${camper.apellido}?'),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () async {
              await _manager.deleteSummerCamper(camper.id, context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final pad = sw * 0.03;
    final fLarge = sh * 0.025;
    final fSmall = sh * 0.02;
    final iconSz = sh * 0.04;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Gestión de alumnos', style: TextStyle(fontSize: fLarge)),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(pad),
            child: StreamBuilder<List<String>>(
              stream: _manager.getMonitorsStream(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const SizedBox.shrink();
                final monitors = ['Todos', ...snap.data!];
                return DropdownButton<String>(
                  value: _selectedMonitor,
                  onChanged: (v) => setState(() => _selectedMonitor = v!),
                  items: monitors.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<SummerCamper>>(
              stream: _campersStream,
              builder: (ctx, snap) {
                if (snap.hasError) return const Center(child: Text('Error'));
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final campers = _selectedMonitor == 'Todos'
                    ? snap.data!
                    : snap.data!.where((c) => c.monitor == _selectedMonitor).toList();
                if (campers.isEmpty) return const Center(child: Text('No hay alumnos.'));
                return ListView.builder(
                  itemCount: campers.length,
                  itemBuilder: (c, i) {
                    final camper = campers[i];
                    return ListTile(
                      leading: Icon(Icons.account_circle, size: iconSz),
                      title: Text('${camper.nombre} ${camper.apellido}', style: TextStyle(fontSize: fLarge)),
                      subtitle: Text(camper.monitor, style: TextStyle(fontSize: fSmall)),
                      tileColor: _colorTile(i),
                      trailing: userRol == 'Administrador'
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: Icon(Icons.edit, size: iconSz), onPressed: () => _showManageDialog(camper: camper)),
                          IconButton(icon: Icon(Icons.delete, size: iconSz), onPressed: () => _showDeleteDialog(camper)),
                        ],
                      )
                          : Text('Edad: ${camper.edad}', style: TextStyle(fontSize: fSmall)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: userRol == 'Administrador'
          ? FloatingActionButton(
        onPressed: () => _showManageDialog(),
        child: Icon(Icons.add, size: iconSz),
      )
          : null,
    );
  }
}
