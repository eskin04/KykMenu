import 'package:cloud_firestore/cloud_firestore.dart';

class MenuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Günlük yemek menüsü ekleme veya güncelleme
  Future<void> addDailyMenu({
    required String city,
    required String date, // YYYY-MM-DD formatında tarih
    required String breakfast,
    required String dinner,
  }) async {
    String month = date.substring(0, 7); // YYYY-MM formatını çıkar

    await _firestore
        .collection('menus')
        .doc(city)
        .collection(month)
        .doc(date)
        .set({
          'breakfast': breakfast,
          'dinner': dinner,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  /// Belirli bir günün yemek menüsünü getir
  Future<Map<String, dynamic>?> getDailyMenu({
    required String city,
    required String date,
  }) async {
    String month = date.substring(0, 7); // YYYY-MM formatını al

    DocumentSnapshot menuDoc =
        await _firestore
            .collection('menus')
            .doc(city)
            .collection(month)
            .doc(date)
            .get();

    if (menuDoc.exists) {
      return menuDoc.data() as Map<String, dynamic>;
    } else {
      return null; // Menü bulunamazsa
    }
  }

  /// Bir ayın tüm yemek menülerini getir
  Future<List<Map<String, dynamic>>> getMonthlyMenu({
    required String city,
    required String month, // YYYY-MM formatında ay
  }) async {
    QuerySnapshot menuSnapshot =
        await _firestore
            .collection('menus')
            .doc(city)
            .collection(month)
            .orderBy(
              'createdAt',
              descending: false,
            ) // Tarih sırasına göre getir
            .get();

    return menuSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  /// Belirli bir günün menüsünü gerçek zamanlı takip et
  Stream<Map<String, dynamic>?> streamDailyMenu({
    required String city,
    required String date,
  }) {
    String month = date.substring(0, 7); // YYYY-MM formatını al

    return _firestore
        .collection('menus')
        .doc(city)
        .collection(month)
        .doc(date)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return snapshot.data() as Map<String, dynamic>;
          }
          return null;
        });
  }
}
