import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get user => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  //register
  Future<void> creatUser({
    required String email,
    required String password,
    required String username,
    required String city,
  }) async {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);

    User? newUser = userCredential.user;

    if (newUser != null) {
      // Firebase Authentication'da kullanıcı adı güncelleme
      await newUser.updateDisplayName(username);
      await newUser.reload();

      // Firestore'a kullanıcı bilgilerini ekleme
      await _firestore.collection('users').doc(newUser.uid).set({
        'username': username,
        'email': email,
        'city': city,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  //login
  Future<void> login({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<void> addComment({
    required String userId,
    required String commentText,
  }) async {
    await _firestore.collection('users').doc(userId).collection('comments').add(
      {'text': commentText, 'timestamp': FieldValue.serverTimestamp()},
    );
  }

  Future<List<Map<String, dynamic>>> getComments(String userId) async {
    QuerySnapshot snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('comments')
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> deleteComment(String userId, String commentId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }
}
