import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
