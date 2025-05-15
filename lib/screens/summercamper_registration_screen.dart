import 'package:flutter/material.dart';
import 'package:workgest/managers/summer_camper_manager.dart';
import '../model/summercamper_item.dart';

class SummerCamperRegistrationScreen extends StatefulWidget {
  final SummerCamper? camperToEdit;

  const SummerCamperRegistrationScreen({super.key, this.camperToEdit});

  @override
  SummerCamperRegistrationScreenState createState() =>
      SummerCamperRegistrationScreenState();
}

class SummerCamperRegistrationScreenState
    extends State<SummerCamperRegistrationScreen> {
  final _nameFieldController = TextEditingController();
  final _apellidoFieldController = TextEditingController();
  final _ageFieldController = TextEditingController();
  final _monitorFieldController = TextEditingController();
  final _groupFieldController = TextEditingController();

  bool _processing = false;
  String _statusMessage = "";

  final SummerCamperManager _manager = SummerCamperManager();

  @override
  void initState() {
    super.initState();
    // If editing, prefill
    if (widget.camperToEdit != null) {
      final c = widget.camperToEdit!;
      _nameFieldController.text = c.nombre;
      _apellidoFieldController.text = c.apellido;
      _ageFieldController.text = c.edad.toString();
      _monitorFieldController.text = c.monitor;
      _groupFieldController.text = c.group;
    }
  }

  @override
  void dispose() {
    _nameFieldController.dispose();
    _apellidoFieldController.dispose();
    _ageFieldController.dispose();
    _monitorFieldController.dispose();
    _groupFieldController.dispose();
    super.dispose();
  }

  Future<void> _saveCamper() async {
    final nombre = _nameFieldController.text.trim();
    final apellido = _apellidoFieldController.text.trim();
    final edadStr = _ageFieldController.text.trim();
    final monitor = _monitorFieldController.text.trim();
    final group = _groupFieldController.text.trim();

    if ([nombre, apellido, edadStr, monitor, group].any((s) => s.isEmpty)) {
      setState(() => _statusMessage = "Por favor completa todos los campos.");
      return;
    }

    final edad = int.tryParse(edadStr);
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
        // Create new
        await _manager.createSummerCamper(
          nombre,
          apellido,
          edad,
          monitor,
        );
      } else {
        // Update existing
        await _manager.updateSummerCamper(
          widget.camperToEdit!.id,
          nombre,
          apellido,
          edad,
          monitor,
        );
      }
      Navigator.pop(context);
    } catch (e) {
      setState(() => _statusMessage = "Error: $e");
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.camperToEdit == null ? "Registrar alumno" : "Editar alumno",
        ),
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
              controller: _ageFieldController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Edad"),
            ),
            TextField(
              controller: _monitorFieldController,
              decoration: const InputDecoration(labelText: "Monitor"),
            ),
            TextField(
              controller: _groupFieldController,
              decoration: const InputDecoration(labelText: "Grupo"),
            ),
            const SizedBox(height: 24),
            if (_statusMessage.isNotEmpty)
              Text(_statusMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
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
