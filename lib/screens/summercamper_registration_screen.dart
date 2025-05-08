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
  final _ageFieldController = TextEditingController();

  bool _processing = false;
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameFieldController.dispose();
    _apellidoFieldController.dispose();
    _edadFieldController.dispose();
    super.dispose(); // Assuming _edadFieldController exists and needs disposing
  }

  Future<void> _saveCamper() async {
    final nombre = _nameFieldController.text.trim();
    final edadStr = _ageFieldController.text.trim();
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

    setState(() => _processing = true);

    try {
      await SummerCamperManager.createSummerCamper(
        nombre,
        edad,
      );

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
        title: const Text("Registrar alumno"),
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
              controller: _ageFieldController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Edad"),
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
