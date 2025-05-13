import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MenuEditScreen extends StatefulWidget {
  const MenuEditScreen({super.key});

  @override
  State<MenuEditScreen> createState() => _MenuEditScreenState();
}

class _MenuEditScreenState extends State<MenuEditScreen> {
  DateTime selectedDate = DateTime.now();
  String selectedCity = 'Ankara';
  final TextEditingController breakfastController = TextEditingController();
  final TextEditingController dinnerController = TextEditingController();

  Future<void> _saveMenu() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String monthPath = formattedDate.substring(0, 7);

    await FirebaseFirestore.instance
        .collection('menus')
        .doc(selectedCity)
        .collection(monthPath)
        .doc(formattedDate)
        .set({
          'breakfast': breakfastController.text.trim(),
          'dinner': dinnerController.text.trim(),
          'likedUsers': [],
          'dislikedUsers': [],
        });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Menü başarıyla kaydedildi.")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menü Ekle / Güncelle"),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tarih Seç:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd MMMM yyyy', 'tr_TR').format(selectedDate),
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            Text("Şehir Seç:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCity,
              items:
                  ['Ankara', 'İstanbul', 'İzmir', 'Bursa']
                      .map(
                        (city) =>
                            DropdownMenuItem(child: Text(city), value: city),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCity = value;
                  });
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.green.shade50,
              ),
            ),

            SizedBox(height: 20),

            Text("Kahvaltı:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: breakfastController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Yemekleri virgül ile ayır",
                filled: true,
                fillColor: Colors.green.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 20),

            Text(
              "Akşam Yemeği:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: dinnerController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Yemekleri virgül ile ayır",
                filled: true,
                fillColor: Colors.green.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveMenu,
                icon: Icon(Icons.save),
                label: Text("Menüyü Kaydet"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
