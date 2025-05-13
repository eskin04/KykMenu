import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kykmenu/screens/settings_screen.dart';
import 'package:kykmenu/service/menu.dart';
import 'package:kykmenu/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kykmenu/service/comments_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  DateTime selectedDate = DateTime.now();
  bool isBreakfast = false;
  final ScrollController _scrollController = ScrollController();
  final MenuService _menuService = MenuService();
  Map<String, dynamic>? dailyMenu;
  String? userName;
  String selectedCity = '';
  List<dynamic> likedUsers = [];
  List<dynamic> dislikedUsers = [];
  bool? userLiked;
  bool menuExists = true; // Menü var mı, yok mu bilgisini saklayacak

  List<String> icons = [
    'utensils',
    'soup',
    'pasta',
    'dessert',
    'egg',
    'cheese',
    'bread',
    'honey',
  ];

  String getMealIcon(int index, bool isBreakfast) {
    int iconIndex = isBreakfast ? (index % 4) + 4 : index % 4;
    return icons[iconIndex]; // varsayılan ikon
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
      _fetchUserName();
      _fetchUserCity();
    });
  }

  // Firestore'dan kullanıcı adını çekme fonksiyonu
  void _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        userName = userDoc['username'] ?? 'Kullanıcı';
      });
    } else {
      setState(() {
        userName = 'Misafir';
      });
    }
  }

  void _fetchUserCity() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        selectedCity = userDoc['city'] ?? 'Ankara';
        _fetchMenu();
        _fetchLikesAndDislikes();

        print("Seçilen şehir: $selectedCity");
      });
    }
    // Eğer kullanıcı yoksa varsayılan bir şehir ayarla
    else {
      setState(() {
        selectedCity = 'Ankara';
      });
      _fetchMenu();
      _fetchLikesAndDislikes();
    }
  }

  void _fetchLikesAndDislikes() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String city = selectedCity;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot menuDoc =
        await FirebaseFirestore.instance
            .collection('menus')
            .doc(city)
            .collection(formattedDate.substring(0, 7))
            .doc(formattedDate)
            .get();

    if (menuDoc.exists) {
      List<dynamic> fetchedLikedUsers =
          (menuDoc.data() as Map<String, dynamic>?)?.containsKey(
                    'likedUsers',
                  ) ==
                  true
              ? List.from(menuDoc['likedUsers'])
              : [];

      List<dynamic> fetchedDislikedUsers =
          (menuDoc.data() as Map<String, dynamic>?)?.containsKey(
                    'dislikedUsers',
                  ) ==
                  true
              ? List.from(menuDoc['dislikedUsers'])
              : [];

      bool? newUserLiked;
      if (fetchedLikedUsers.contains(user.uid)) {
        newUserLiked = true;
      } else if (fetchedDislikedUsers.contains(user.uid)) {
        newUserLiked = false;
      } else {
        newUserLiked = null;
      }

      if (mounted) {
        setState(() {
          likedUsers = fetchedLikedUsers;
          dislikedUsers = fetchedDislikedUsers;
          userLiked = newUserLiked;
          menuExists = true; // Menü bulundu
        });
      }
    } else {
      if (mounted) {
        setState(() {
          likedUsers = [];
          dislikedUsers = [];
          userLiked = null;
          menuExists = false; // Menü bulunamadı
        });
      }
    }
  }

  void _updateLikes(bool isLike) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String city = selectedCity;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentReference menuDocRef = FirebaseFirestore.instance
        .collection('menus')
        .doc(city)
        .collection(formattedDate.substring(0, 7))
        .doc(formattedDate);

    // Mevcut veriyi Firestore'dan çek
    DocumentSnapshot menuDoc = await menuDocRef.get();
    List<dynamic> likedUsers = [];
    List<dynamic> dislikedUsers = [];

    if (menuDoc.exists) {
      Map<String, dynamic>? data = menuDoc.data() as Map<String, dynamic>?;

      likedUsers =
          data?['likedUsers'] != null ? List.from(data!['likedUsers']) : [];
      dislikedUsers =
          data?['dislikedUsers'] != null
              ? List.from(data!['dislikedUsers'])
              : [];
    }

    // Eğer kullanıcı zaten aynı şekilde oy verdiyse uyarı ver
    if ((isLike && likedUsers.contains(user.uid)) ||
        (!isLike && dislikedUsers.contains(user.uid))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isLike ? "Zaten beğendiniz!" : "Zaten beğenmediniz!"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Beğeni durumunu güncelle
    if (isLike) {
      dislikedUsers.remove(user.uid);
      likedUsers.add(user.uid);
    } else {
      likedUsers.remove(user.uid);
      dislikedUsers.add(user.uid);
    }

    // Firestore'a güncellenmiş veriyi yaz
    await menuDocRef.set({
      'likedUsers': likedUsers,
      'dislikedUsers': dislikedUsers,
    }, SetOptions(merge: true)); // Mevcut veriyi silmeden günceller

    // UI'yi güncelle
    _fetchLikesAndDislikes();
  }

  void _showComments() {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CommentsScreen(city: selectedCity, date: formattedDate);
      },
    );
  }

  void _scrollToSelectedDate() {
    int index = selectedDate.day - 1;
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = 60.0;
    double offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _fetchMenu() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String city = selectedCity;
    var menu = await _menuService.getDailyMenu(city: city, date: formattedDate);
    setState(() {
      dailyMenu = menu;
    });
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(
          children: [
            // **Kullanıcı Adını rounded box içinde gösterme**
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Text(
                'Hoşgeldin $userName',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),

            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    child: Row(
                      children: List.generate(daysInMonth, (index) {
                        DateTime day = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          index + 1,
                        );
                        String dayName = DateFormat(
                          'E',
                          'tr_TR',
                        ).format(day).substring(0, 3);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = day;
                              _fetchMenu();
                              _fetchLikesAndDislikes();
                            });
                          },
                          child: Container(
                            width: 60,
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  selectedDate.day == day.day
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color:
                                        selectedDate.day == day.day
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color:
                                        selectedDate.day == day.day
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Akşam Yemeği",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isBreakfast ? Colors.grey : Colors.green,
                        ),
                      ),
                      Switch(
                        value: isBreakfast,
                        onChanged: (bool value) {
                          setState(() {
                            isBreakfast = value;
                          });
                        },
                      ),
                      Text(
                        "Kahvaltı",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isBreakfast ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    child: Text(
                      selectedCity,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,

                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(
                            'd MMMM yyyy',
                            'tr_TR',
                          ).format(selectedDate),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        Divider(),
                        if (dailyMenu != null)
                          ...((isBreakfast
                                  ? dailyMenu!['breakfast']
                                  : dailyMenu!['dinner'])
                              .toString()
                              .split(',')
                              .asMap()
                              .entries
                              .map(
                                (entry) => ListTile(
                                  leading: Container(
                                    padding: EdgeInsets.all(8),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green.shade100.withOpacity(
                                        0.8,
                                      ),
                                    ),
                                    child: Image.asset(
                                      'assets/icons/${getMealIcon(entry.key, isBreakfast)}.png',
                                    ),
                                  ),
                                  title: Text(
                                    entry.value.trim(),
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                ),
                              ))
                        else
                          //menuNo
                          Center(
                            heightFactor: 9.75,
                            child: Text(
                              "Menü bulunamadı ",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed:
                                          menuExists
                                              ? () => _updateLikes(true)
                                              : null, // Menü yoksa buton devre dışı
                                      icon: Icon(Icons.thumb_up),
                                      color:
                                          userLiked == true
                                              ? Colors.green
                                              : Colors.grey,
                                    ),
                                    Text(
                                      likedUsers.length.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed:
                                          menuExists
                                              ? () => _updateLikes(false)
                                              : null, // Menü yoksa buton devre dışı
                                      icon: Icon(Icons.thumb_down),
                                      color:
                                          userLiked == false
                                              ? Colors.red
                                              : Colors.grey,
                                    ),
                                    Text(
                                      dislikedUsers.length.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            IconButton(
                              icon: Icon(
                                Icons.comment,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed:
                                  menuExists
                                      ? _showComments
                                      : null, // Menü yoksa buton devre dışı
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // sayfanın en altına sabitlenmesi için
                    margin: EdgeInsets.only(top: 130),
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [Colors.green.shade300, Colors.green.shade600],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsScreen(),
                              ),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.restaurant_menu,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Menü",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),

                        IconButton(
                          icon: Icon(Icons.exit_to_app, color: Colors.white),
                          onPressed: () {
                            FirebaseAuth.instance.signOut().then((_) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    ),
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
