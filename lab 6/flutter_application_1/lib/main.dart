import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false; // Theme toggle

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? darkTheme : lightTheme, // toggle theme

      home: Scaffold(
        appBar: AppBar(
          title: Text("All Tasks"),
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
          // prevents overflow errors
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Paragraphs
                Text(
                  "This is the first paragraph using large style.",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "This is the second paragraph using medium style.",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black,
                  ),
                ),
                SizedBox(height: 20),

                // Card
                Card(
                  color: isDark ? Color(0xFF212121) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "This is a themed Card.",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.tealAccent : Colors.blue,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.teal : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {},
                  child: Text("Themed Button"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
);

// Dark theme (only AppBar)
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),
);
