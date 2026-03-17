import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          centerTitle: true,
          title: const Text("Flutter Lab 1"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "Ayema",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.favorite, size: 40, color: Colors.red),
                  SizedBox(width: 20),
                  Icon(Icons.thumb_up, size: 40, color: Colors.blue),
                  SizedBox(width: 20),
                  Icon(Icons.share, size: 40, color: Colors.green),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  "assets/flutter_logo.png",
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: 200,
                height: 200,
                child: Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png",
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
