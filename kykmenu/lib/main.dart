import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Yeni dosyanı ekledik

void main() {
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
