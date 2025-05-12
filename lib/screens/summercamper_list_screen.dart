import 'package:flutter/material.dart';
import 'package:workgest/managers/summer_camper_manager.dart';
import 'package:workgest/model/summercamper_item.dart';
import 'package:workgest/screens/summercamper_registration_screen.dart';

class SummerCamperListScreen extends StatefulWidget {
  const SummerCamperListScreen({super.key});

  @override
  _SummerCamperListScreenState createState() => _SummerCamperListScreenState();
}

class _SummerCamperListScreenState extends State<SummerCamperListScreen> {
  final SummerCamperManager _summerCamperManager = SummerCamperManager();
  List<SummerCamper> _summerCampers = [];

  @override
  void initState() {
    super.initState();
    _loadSummerCampers();
  }

  Future<void> _loadSummerCampers() async {
    // Llamada a método de instancia, no estático
    final campers = await _summerCamperManager.getAllSummerCampers();
    setState(() {
      _summerCampers = campers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summer Campers'),
      ),
      body: ListView.builder(
        itemCount: _summerCampers.length,
        itemBuilder: (context, index) {
          final camper = _summerCampers[index];
          // Usar los campos correctos: nombre y edad
          return ListTile(
            title: Text(camper.nombre),
            subtitle: Text('Age: ${camper.edad}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SummerCamperRegistrationScreen(),
            ),
          ).then((_) => _loadSummerCampers());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
