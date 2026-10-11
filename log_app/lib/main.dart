import 'package:flutter/material.dart';
import 'app.dart';
import 'data/database/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database (runs on mobile & web)
  try {
    await DatabaseService().database;
  } catch (e) {
    debugPrint('Database initialization notice: $e');
  }

  runApp(const LogApp());
}
