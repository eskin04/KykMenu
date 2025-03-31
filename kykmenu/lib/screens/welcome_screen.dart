import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  DateTime selectedDate = DateTime.now();
  bool isBreakfast = false;

  final Map<int, Map<String, List<Map<String, dynamic>>>> menuData = {
    31: {
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

  void changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                DateTime day = selectedDate.add(Duration(days: index - 2));
                String dayName = DateFormat(
                  'E',
                  'tr_TR',
                ).format(day).substring(0, 3);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = day;
                    });
                  },
                  onLongPress: () {
                    changeDate(index - 2);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, size: 30, color: Colors.green),
                  onPressed: () => changeDate(-1),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 30,
                    color: Colors.green,
                  ),
                  onPressed: () => changeDate(1),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
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
                  Text(
                    isBreakfast ? "Kahvaltı" : "Akşam Yemeği",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children:
                    menuData[selectedDate.day] != null
                        ? (menuData[selectedDate.day]![isBreakfast
                                    ? 'breakfast'
                                    : 'dinner'] ??
                                [])
                            .map(
                              (item) => Card(
                                elevation: 3,
                                margin: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 10,
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    item['icon'],
                                    color: Colors.green,
                                  ),
                                  title: Text(
                                    item['name'],
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                ),
                              ),
                            )
                            .toList()
                        : [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                "Menü bulunamadı",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
