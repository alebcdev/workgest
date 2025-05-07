import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workgest/viewmodel/summercamper_viewmodel.dart';

class DeleteSummerCamper extends StatefulWidget {
  final QueryDocumentSnapshot snapshot;

  DeleteSummerCamper({required this.snapshot});

  @override
  _DeleteSummerCamperState createState() => _DeleteSummerCamperState();
}

class _DeleteSummerCamperState extends State<DeleteSummerCamper> {
  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width * 0.04;
    double dialogPadding = MediaQuery.of(context).size.width * 0.05;

    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: dialogPadding, vertical: dialogPadding),
      title: Text(
        '¿Desea borrar el alumno?',
        style: TextStyle(fontSize: fontSize),
      ),
      actions: [
        TextButton(
          onPressed: () {
            SummerCamperViewModel.deleteStudent(widget.snapshot, context);
          },
          child: Text(
            'Borrar',
            style: TextStyle(fontSize: fontSize),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancelar',
            style: TextStyle(fontSize: fontSize),
          ),
        ),
      ],
    );
  }
}