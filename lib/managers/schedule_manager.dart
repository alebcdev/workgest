import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workgest/services/firebase_service.dart';

class ScheduleManager {

  ScheduleManager();

  Future<String?> getUserRole(dynamic user) async {
    final uid = user.uid;
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    return doc.data()?['rol'];
  }

  Future<String?> pickAndUploadCsvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: false);

      if (result == null) return null;

      final filePath = result.files.first.path;
      if (filePath == null) return null;

      File file = File(filePath);
      String fileName = result.files.first.name;

      final downloadURL = await FirebaseService.uploadFileToStorage(await file.readAsBytes(), 'uploads/$fileName');

      return downloadURL;
    } catch (e) {
      _logError(e, StackTrace.current);
      return null;
    }
  }

  Future<void> saveCsvFileUrl(String url) async {
    try {
      await FirebaseService.saveCsvFileUrl(url);
    } catch (e) {
      _logError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<String?> getCsvFileUrl() async {
    try {
      final doc = await FirebaseService.getCsvFileUrl();
      if (doc.exists) {
        return doc['url'];
      }
      return null;
    } catch (e) {
      _logError(e, StackTrace.current);
      return null;
    }
  }

  Future<List<List<dynamic>>> downloadAndParseCsv(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final fields = const CsvToListConverter().convert(utf8.decode(response.bodyBytes));
        return fields;
      } else {
        _logError('Error downloading CSV: ${response.statusCode}', StackTrace.current);
        return [];
      }
    } catch (e) {
      _logError(e, StackTrace.current);
      return [];
    }
  }

  void _logError(dynamic e, StackTrace stackTrace) {
    if (kDebugMode) {
      print('Error: $e\nStackTrace: $stackTrace');
    }
  }

  final List<Color> colorPalette = [
    Colors.orange,
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.yellow,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.brown,
  ];
}
