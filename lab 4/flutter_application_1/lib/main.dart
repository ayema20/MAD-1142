import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isFollowed = false;
  int score = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              // Profile Image
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),

              const SizedBox(height: 15),

              // Name
              const Text(
                "Ayema",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              // Title
              const Text(
                "Flutter Developer",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 120,
                      color: Colors.blue,
                      child: const Center(
                        child: Text(
                          "Section 1",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 120,
                      color: Colors.green,
                      child: const Center(
                        child: Text(
                          "Section 2",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isFollowed = !isFollowed;
                  });
                },

                child: Text(isFollowed ? "Following" : "Follow"),
              ),

              const SizedBox(height: 10),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red, size: 30),

                onPressed: () {
                  setState(() {
                    score++;
                  });
                },
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 5,

                child: ListTile(
                  leading: const Icon(Icons.star),

                  title: const Text("Likes Score"),

                  subtitle: Text("$score Likes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
