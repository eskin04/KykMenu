import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MenuDeleteScreen extends StatefulWidget {
  const MenuDeleteScreen({super.key});

  @override
  State<MenuDeleteScreen> createState() => _MenuDeleteScreenState();
}

class _MenuDeleteScreenState extends State<MenuDeleteScreen> {
  DateTime selectedDate = DateTime.now();
  String selectedCity = 'Ankara';
  Map<String, dynamic>? foundMenu;
  bool isLoading = false;

  Future<void> _fetchMenu() async {
    setState(() {
      isLoading = true;
      foundMenu = null;
    });

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String monthPath = formattedDate.substring(0, 7);

    DocumentSnapshot doc =
        await FirebaseFirestore.instance
            .collection('menus')
            .doc(selectedCity)
            .collection(monthPath)
            .doc(formattedDate)
            .get();

    setState(() {
      isLoading = false;
      if (doc.exists) {
        foundMenu = doc.data() as Map<String, dynamic>;
      } else {
        foundMenu = null;
      }
    });
  }

  Future<void> _deleteMenu() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String monthPath = formattedDate.substring(0, 7);

    await FirebaseFirestore.instance
        .collection('menus')
        .doc(selectedCity)
        .collection(monthPath)
        .doc(formattedDate)
        .delete();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Menü başarıyla silindi.")));

    setState(() {
      foundMenu = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menü Sil"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
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

            ElevatedButton(
              onPressed: _fetchMenu,
              child: Text("Menüyü Getir"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),

            SizedBox(height: 20),

            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (foundMenu != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Kahvaltı: ${foundMenu!['breakfast'] ?? '-'}"),
                  SizedBox(height: 8),
                  Text("Akşam Yemeği: ${foundMenu!['dinner'] ?? '-'}"),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _deleteMenu,
                    icon: Icon(Icons.delete),
                    label: Text("Menüyü Sil"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              )
            else
              Text(
                "Bu tarihte menü bulunamadı.",
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
