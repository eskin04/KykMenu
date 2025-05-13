import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CommentModerationScreen extends StatefulWidget {
  const CommentModerationScreen({super.key});

  @override
  State<CommentModerationScreen> createState() =>
      _CommentModerationScreenState();
}

class _CommentModerationScreenState extends State<CommentModerationScreen> {
  DateTime selectedDate = DateTime.now();
  String selectedCity = 'Dokuz Eylül';
  List<Map<String, dynamic>> comments = [];
  bool isLoading = false;

  Future<void> _fetchComments() async {
    setState(() {
      isLoading = true;
      comments.clear();
    });

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String monthPath = formattedDate.substring(0, 7);

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('menus')
              .doc(selectedCity)
              .collection(monthPath)
              .doc(formattedDate)
              .collection('comments')
              .get();

      setState(() {
        comments =
            snapshot.docs
                .map(
                  (doc) => {
                    'id': doc.id,
                    'text': doc['comment'],
                    'user': doc['username'] ?? 'Bilinmeyen',
                  },
                )
                .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        comments = [];
      });
    }
  }

  Future<void> _deleteComment(String commentId) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String monthPath = formattedDate.substring(0, 7);

    await FirebaseFirestore.instance
        .collection('menus')
        .doc(selectedCity)
        .collection(monthPath)
        .doc(formattedDate)
        .collection('comments')
        .doc(commentId)
        .delete();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Yorum silindi")));

    _fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yorumları Yönet"),
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
          children: [
            // Tarih
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Tarih:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: InkWell(
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat(
                              'dd MMMM yyyy',
                              'tr_TR',
                            ).format(selectedDate),
                          ),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Şehir
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Üniversite:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedCity,
                    items:
                        ['Dokuz Eylül', 'Ege', 'Bakırçay', 'Demokrasi']
                            .map(
                              (city) => DropdownMenuItem(
                                child: Text(city),
                                value: city,
                              ),
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
                ),
              ],
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _fetchComments,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(
                "Yorumları Getir",
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
            else if (comments.isEmpty)
              Text("Yorum bulunamadı", style: TextStyle(color: Colors.red))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(comment['text']),
                        subtitle: Text("Kullanıcı: ${comment['user']}"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteComment(comment['id']),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
