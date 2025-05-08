import 'package:flutter/material.dart';
import 'package:workgest/managers/summer_camper_manager.dart';

import '../model/summercamper_item.dart';

class SummerCamperRegistrationScreen extends StatefulWidget {
  final SummerCamper? camperToEdit;

  const SummerCamperRegistrationScreen({super.key, this.camperToEdit});

  @override
  _SummerCamperRegistrationScreenState createState() =>
      _SummerCamperRegistrationScreenState();
}

class _SummerCamperRegistrationScreenState
    extends State<SummerCamperRegistrationScreen> {
  final _nameFieldController = TextEditingController();
  final _apellidoFieldController = TextEditingController();
  final _edadFieldController = TextEditingController();

  String? _selectedMonitor;
  bool _processing = false;
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    if (widget.camperToEdit != null) {
      _nameFieldController.text = widget.camperToEdit!.nombre;
      _apellidoFieldController.text = widget.camperToEdit!.apellido;
      _edadFieldController.text = widget.camperToEdit!.edad.toString();
      _selectedMonitor = widget.camperToEdit!.monitor;
    }
  }

  @override
  void dispose() {
    _nameFieldController.dispose();
    _apellidoFieldController.dispose();
    _edadFieldController.dispose();
    super.dispose();
  }

  Future<void> _saveCamper() async {
    final nombre = _nameFieldController.text.trim();
    final apellido = _apellidoFieldController.text.trim();
    final edadStr = _edadFieldController.text.trim();

    if (nombre.isEmpty ||
        apellido.isEmpty ||
        edadStr.isEmpty ||
        _selectedMonitor == null) {
      setState(() => _statusMessage = "Por favor completa todos los campos.");
      return;
    }

    int? edad = int.tryParse(edadStr);
    if (edad == null || edad <= 0) {
      setState(() => _statusMessage = "Edad inválida.");
      return;
    }

    setState(() {
      _processing = true;
      _statusMessage = "";
    });

    try {
      if (widget.camperToEdit == null) {
        // Nuevo camper
        await SummerCamperManager.addSummerCamper(
            nombre, apellido, edad, _selectedMonitor!);
      } else {
        // Actualización
        await SummerCamperManager.updateSummerCamper(
          widget.camperToEdit!.id,
          nombre,
          apellido,
          edad,
          _selectedMonitor!,
        );
      }

      setState(() => _statusMessage = "Guardado correctamente.");
      Navigator.pop(context);
    } catch (e) {
      setState(() => _statusMessage = "Error: $e");
    } finally {
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.camperToEdit == null ? "Registrar alumno" : "Editar alumno"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameFieldController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: _apellidoFieldController,
              decoration: const InputDecoration(labelText: "Apellido"),
            ),
            TextField(
              controller: _edadFieldController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Edad"),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<String>>(
              stream: SummerCamperManager.getMonitorsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final monitors = snapshot.data!;
                return DropdownButtonFormField<String>(
                  value: _selectedMonitor,
                  items: monitors.map((monitor) {
                    return DropdownMenuItem(
                      value: monitor,
                      child: Text(monitor),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedMonitor = value);
                  },
                  decoration:
                      const InputDecoration(labelText: "Selecciona un monitor"),
                );
              },
            ),
            const SizedBox(height: 24),
            if (_statusMessage.isNotEmpty)
              Text(_statusMessage, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _processing ? null : _saveCamper,
              child: Text(_processing ? "Guardando..." : "Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
