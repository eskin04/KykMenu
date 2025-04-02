import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kykmenu/screens/welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedCity = 'Ankara';
  bool notificationsEnabled = false;

  final List<String> cities = [
    'Antalya',
    'İstanbul',
    'Ankara',
    'İzmir',
    'Bursa',
    'Adana',
  ];

  void _saveCity() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'city': selectedCity,
    }, SetOptions(merge: true));
  }

  void _loadCity() async {
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

  @override
  void initState() {
    super.initState();
    _loadCity();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _saveCity();
            //loginscreen'e yönlendir
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
          SwitchListTile(
            title: Text('Günlük Bildirim Al'),
            value: notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
