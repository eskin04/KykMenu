import 'package:flutter/material.dart';
import 'package:kykmenu/components/theme.dart';
import 'package:kykmenu/components/theme_provider.dart';
import 'package:kykmenu/service/messaging.dart';
import 'screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kykmenu/screens/welcome_screen.dart';
import 'package:provider/provider.dart'; // Bunu ekle!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('tr_TR', null);
  await FireBaseApi().initNotifications(); // Firebase Messaging'i başlat
  runApp(
    ChangeNotifierProvider(create: (_) => ThemeProvider(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu!'));
          } else if (snapshot.hasData) {
            return WelcomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
      theme: lightTheme,
      darkTheme: darkTheme,
      title: 'Yemek App',
      themeMode: themeProvider.themeMode,
    );
  }
}
