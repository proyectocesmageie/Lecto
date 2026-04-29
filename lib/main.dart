import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vsaqzajgcsyhcldydixe.supabase.co', // 🔥 pega tu URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZzYXF6YWpnY3N5aGNsZHlkaXhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2ODcwNTcsImV4cCI6MjA5MTI2MzA1N30.0D31QCLyTPuRsURZIK_nx9le-mtz_GX8yyWf6jAtAwg', // 🔥 pega tu KEY
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
