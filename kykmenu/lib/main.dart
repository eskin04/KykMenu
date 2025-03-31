import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Yeni dosyanı ekledik
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart'; // Bunu ekle!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('tr_TR', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // Burada ayrı bir dosyaya taşıdık
    );
  }
}
