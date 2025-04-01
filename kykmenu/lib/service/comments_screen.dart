import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CommentsScreen extends StatefulWidget {
  final String city;
  final String date;

  const CommentsScreen({Key? key, required this.city, required this.date})
    : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();

  Future<void> _addComment(String commentText) async {
    if (commentText.isEmpty) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;
    String userName = user.displayName ?? "Anonim";

    await FirebaseFirestore.instance
        .collection('menus')
        .doc(widget.city)
        .collection(widget.date.substring(0, 7))
        .doc(widget.date)
        .collection('comments')
        .add({
          'comment': commentText,
          'timestamp': FieldValue.serverTimestamp(), // 🕒 Timestamp ekleniyor
          'userid': userId,
          'username': userName,
        });

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16),
        height:
            MediaQuery.of(context).size.height * 0.75, // Ekranın %75'ini kaplar
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Text(
              "Yorumlar",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('menus')
                        .doc(widget.city)
                        .collection(widget.date.substring(0, 7))
                        .doc(widget.date)
                        .collection('comments')
                        .orderBy(
                          'timestamp',
                          descending: true,
                        ) // 📌 Tarihe göre sıralama
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var comments = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      var commentData =
                          comments[index].data() as Map<String, dynamic>;

                      String commentText = commentData['comment'] ?? "";
                      String username =
                          commentData['username'] ?? "Bilinmeyen Kullanıcı";
                      DateTime timestamp =
                          (commentData['timestamp'] as Timestamp?)?.toDate() ??
                          DateTime.now();

                      return ListTile(
                        title: Text(commentText),
                        subtitle: Text(
                          "$username • ${DateFormat('dd MMM yyyy HH:mm', 'tr_TR').format(timestamp)}",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: "Yorumunuzu yazın...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.green),
                    onPressed: () => _addComment(_commentController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
