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
        titleTextStyle: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        toolbarHeight: 80,
        //change back button color to white
        iconTheme: IconThemeData(color: Colors.white),
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

            Text("Üniversite:", style: TextStyle(fontWeight: FontWeight.bold)),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(
                "Menü Ara",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: 20),

            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (foundMenu != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // get in two cards, one for breakfast and one for dinner
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Kahvaltı",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(foundMenu!['breakfast'] ?? "Veri yok"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Akşam Yemeği",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(foundMenu!['dinner'] ?? "Veri yok"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _deleteMenu,
                    icon: Icon(Icons.delete, color: Colors.white),
                    label: Text(
                      "Sil",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              )
            else if (foundMenu == null)
              Center(
                child: Text(
                  "Menü bulunamadı.",
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
