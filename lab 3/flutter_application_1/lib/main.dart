import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LabPlan(),
    );
  }
}

class LabPlan extends StatelessWidget {
  const LabPlan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Plan 3"),
        backgroundColor: Colors.purple,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CircleAvatar(
              backgroundImage: const AssetImage("assets/profile.jpg"),
              onBackgroundImageError: (_, __) {},
              child: const Text("A"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Card(
              color: Colors.blue[100],
              elevation: 5,
              margin: const EdgeInsets.all(10),
              child: const Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.star, size: 30, color: Colors.blue),
                    Icon(Icons.favorite, size: 40, color: Colors.red),
                    Icon(Icons.thumb_up, size: 35, color: Colors.green),
                  ],
                ),
              ),
            ),

            Card(
              color: Colors.orange[100],
              elevation: 10,
              margin: const EdgeInsets.all(10),
              child: const Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Icon(Icons.home, size: 30, color: Colors.orange),
                    Icon(Icons.settings, size: 40, color: Colors.black),
                    Icon(Icons.person, size: 35, color: Colors.purple),
                  ],
                ),
              ),
            ),

            Card(
              color: Colors.green[100],
              elevation: 15,
              margin: const EdgeInsets.all(10),
              child: const Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.phone, size: 30, color: Colors.teal),
                    Icon(Icons.email, size: 40, color: Colors.deepPurple),
                    Icon(Icons.map, size: 35, color: Colors.brown),
                  ],
                ),
              ),
            ),

            const Divider(thickness: 3),

            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 50.0,
                horizontal: 10.0,
              ),
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                color: Colors.pink[100],
                child: const Text(
                  "This Container shows Padding and Margin",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const Divider(thickness: 3),

            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3"),
              child: Text("U"),
            ),

            const SizedBox(height: 20),

            const Divider(thickness: 3),

            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.all(15),
              child: const ListTile(
                leading: Icon(Icons.person, color: Colors.blue),
                title: Text("Ayema Khalid"),
                subtitle: Text("Registration No: 1142"),
              ),
            ),

            Card(
              color: Colors.purple[100],
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.all(15),
              child: const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Text("A"),
                ),
                title: Text("Esha Khan"),
                subtitle: Text("Registration No: 1151"),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
