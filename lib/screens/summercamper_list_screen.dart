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
    final summerCampers = await SummerCamperManager.getAllSummerCampers();
    setState(() {
      _summerCampers = summerCampers;
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
          final summerCamper = _summerCampers[index];
          return ListTile(
            title: Text(summerCamper.name),
            subtitle: Text('Age: ${summerCamper.age}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SummerCamperRegistrationScreen()),
          ).then((_) => _loadSummerCampers()); // Refresh the list after returning
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
