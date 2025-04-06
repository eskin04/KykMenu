import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kykmenu/screens/welcome_screen.dart';
import 'package:app_settings/app_settings.dart';
import 'package:provider/provider.dart'; // Bunu ekle!
import 'package:kykmenu/components/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedCity = 'Ankara';

  final List<String> cities = [
    'Antalya',
    'İstanbul',
    'Ankara',
    'İzmir',
    'Bursa',
    'Adana',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  void _openAppSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  // Kullanıcının şehir ve bildirim ayarlarını Firestore'dan çek
  void _loadUserSettings() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (doc.exists) {
      setState(() {
        selectedCity = doc['city'] ?? 'Ankara';
      });
    }
  }

  // Kullanıcının şehir ayarını Firestore'a kaydet
  void _saveCity() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'city': selectedCity,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _saveCity();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            );
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.location_city),
            title: Text('Şehir Seçiniz'),
            trailing: DropdownButton<String>(
              value: selectedCity,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCity = newValue!;
                  _saveCity();
                });
              },
              items:
                  cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
            ),
          ),
          Divider(),
          SizedBox(height: 20),
          // dark mode switch
          SwitchListTile(
            title: Text("Karanlık Mod"),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
            secondary: Icon(Icons.brightness_6),
          ),
          SizedBox(height: 20),
          // bildirim ayarları
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                ),
                onPressed: _openAppSettings,
                child: Text(
                  'Bildirim Ayarlarını Aç',
                  style: TextStyle(color: const Color.fromARGB(255, 3, 45, 80)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
