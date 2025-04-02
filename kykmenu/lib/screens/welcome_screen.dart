import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  List<String> icons = [
    'utensils',
    'coffee',
    'apple-alt',
    'carrot',
    'fish',
    'hamburger',
    'bread-slice',
    'egg',
  ];

  Map<String, IconData> iconMap = {
    'utensils': FontAwesomeIcons.utensils,
    'coffee': FontAwesomeIcons.mugHot,
    'apple-alt': FontAwesomeIcons.appleAlt,
    'carrot': FontAwesomeIcons.carrot,
    'fish': FontAwesomeIcons.fish,
    'hamburger': FontAwesomeIcons.hamburger,
    'bread-slice': FontAwesomeIcons.breadSlice,
    'egg': FontAwesomeIcons.egg,
  };

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
  }

  // Firestore'dan beğeni sayısını çekme fonksiyonu
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
      setState(() {
        likedUsers = (menuDoc['likedUsers'] ?? []) as List<dynamic>;
        dislikedUsers = (menuDoc['dislikedUsers'] ?? []) as List<dynamic>;
        userLiked =
            likedUsers.contains(user.uid)
                ? true
                : dislikedUsers.contains(user.uid)
                ? false
                : null;
      });
    }
  }

  // Kullanıcı beğeni veya beğenilmeme durumunu güncelleme fonksiyonu
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

    if (isLike) {
      if (userLiked == true) {
        likedUsers.remove(user.uid);
      } else {
        dislikedUsers.remove(user.uid);
        likedUsers.add(user.uid);
      }
    } else {
      if (userLiked == false) {
        dislikedUsers.remove(user.uid);
      } else {
        likedUsers.remove(user.uid);
        dislikedUsers.add(user.uid);
      }
    }

    await menuDocRef.update({
      'likedUsers': likedUsers,
      'dislikedUsers': dislikedUsers,
    });

    setState(() {
      userLiked = isLike;
    });
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

  IconData getMealIcon(int index, bool isBreakfast) {
    int iconIndex = isBreakfast ? (index % 4) + 4 : index % 4;
    return iconMap[icons[iconIndex]] ?? FontAwesomeIcons.utensils;
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
              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 129, 184, 199),
                    const Color.fromARGB(255, 67, 155, 160),
                  ],
                ),
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
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  selectedDate.day == day.day
                                      ? Colors.green
                                      : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
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
                                    fontWeight: FontWeight.bold,
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
                      color: Colors.white,
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
                      color: Colors.white,
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
                                  leading: Icon(
                                    getMealIcon(entry.key, isBreakfast),
                                    color: Colors.green,
                                  ),
                                  title: Text(
                                    entry.value.trim(),
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                ),
                              ))
                        else
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
                                      icon: Icon(
                                        Icons.thumb_up,
                                        color:
                                            userLiked == true
                                                ? Colors.green
                                                : Colors.grey,
                                      ),
                                      onPressed: () => _updateLikes(true),
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
                                      icon: Icon(
                                        Icons.thumb_down,
                                        color:
                                            userLiked == false
                                                ? Colors.red
                                                : Colors.grey,
                                      ),
                                      onPressed: () => _updateLikes(false),
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

                            //Firebase'den beğeni sayısını çekme

                            // Çıkış yapma butonu LoginScreen'e yönlendirme LoginScreen()
                            IconButton(
                              icon: Icon(Icons.comment, color: Colors.blue),
                              onPressed: _showComments,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // sayfanın en altına sabitlenmesi için
                    margin: EdgeInsets.only(top: 150),
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

            // bir boxın içinde şehir ismi
          ],
        ),
      ),
    );
  }
}
