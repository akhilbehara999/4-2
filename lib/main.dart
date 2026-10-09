import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/env.dart';
import 'data/local_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Initialize LocalDb (seeds demo items in debug mode)
  try {
    await LocalDb.instance.initDb();
  } catch (e) {
    debugPrint('LocalDb initialization error: $e');
  }

  // Initialize Supabase inside try/catch so the app still launches with no keys or no internet
  try {
    await Supabase.initialize(
      url: SUPABASE_URL,
      // ignore: deprecated_member_use
      anonKey: SUPABASE_ANON_KEY,
    );
  } catch (e) {
    debugPrint('Supabase initialization bypassed or offline: $e');
  }

  runApp(const LogApp());
}
