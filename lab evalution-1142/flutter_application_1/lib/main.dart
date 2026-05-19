import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;
  List<Map<String, dynamic>> classes = [
    {
      "time": "8:00 - 9:00 AM",
      "subject": "Flutter Development",
      "room": "Room 201",
    },
    {
      "time": "9:30 - 11:00 AM",
      "subject": "Software Engineering",
      "room": "Room 105",
    },
    {
      "time": "2:00 - 3:30 PM",
      "subject": "Artifical intelligence",
      "room": "210",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: Text("My Schedule"),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDark = !isDark;
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: classes.map((item) {
                return Column(
                  children: [
                    Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["time"]!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              item["subject"]!,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Text(item["room"]!, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
