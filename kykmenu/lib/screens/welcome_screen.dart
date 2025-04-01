import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  DateTime selectedDate = DateTime.now();
  bool isBreakfast = false;
  final ScrollController _scrollController = ScrollController();

  final Map<int, Map<String, List<Map<String, dynamic>>>> menuData = {
    1: {
      'breakfast': [
        {'name': 'Peynir', 'icon': FontAwesomeIcons.cheese},
        {'name': 'Zeytin', 'icon': FontAwesomeIcons.seedling},
        {'name': 'Ekmek', 'icon': FontAwesomeIcons.breadSlice},
        {'name': 'Çay', 'icon': FontAwesomeIcons.mugHot},
      ],
      'dinner': [
        {'name': 'Tavuk Fajita', 'icon': FontAwesomeIcons.drumstickBite},
        {'name': 'Domates Çorbası', 'icon': FontAwesomeIcons.bowlFood},
        {'name': 'Salçalı Spagetti', 'icon': FontAwesomeIcons.pizzaSlice},
        {'name': 'Yoğurt', 'icon': FontAwesomeIcons.bowlRice},
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
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

  @override
  Widget build(BuildContext context) {
    int daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
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
                        _scrollToSelectedDate();
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
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('d MMMM yyyy', 'tr_TR').format(selectedDate),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.thumb_up),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.thumb_down),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                  ...(menuData[selectedDate.day] != null &&
                              menuData[selectedDate.day]![isBreakfast
                                      ? 'breakfast'
                                      : 'dinner'] !=
                                  null
                          ? menuData[selectedDate.day]![isBreakfast
                              ? 'breakfast'
                              : 'dinner']!
                          : [])
                      .map(
                        (item) => ListTile(
                          leading: Icon(item['icon'], color: Colors.green),
                          title: Text(
                            item['name'],
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                      ),
                  Divider(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: Icon(Icons.comment),
                      onPressed: () {},
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
