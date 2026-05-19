import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'tabs/overview_tab.dart';
import 'tabs/add_student_tab.dart';
import 'tabs/add_route_tab.dart';
import 'tabs/add_driver_tab.dart';
import 'tabs/add_bus_tab.dart';
import 'tabs/add_notification_tab.dart';
import 'login_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentIndex = 0;

  final pages = const [
    OverviewTab(),
    AddStudentTab(),
    AddRouteTab(),
    AddDriverTab(),
    AddBusTab(),
    AddNotificationTab(),
  ];

  final titles = [
    "Overview",
    "Students",
    "Routes",
    "Drivers",
    "Buses",
    "Notifications",
  ];

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      // ⭐ Modern AppBar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF162447),

        // ⭐ TITLE WHITE + BOLD
        title: Text(
          titles[currentIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
        ],
      ),

      // ⭐ BODY
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(currentIndex),
          padding: const EdgeInsets.all(16),
          child: pages[currentIndex],
        ),
      ),

      // ⭐ MOBILE BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF162447),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Overview",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Students"),
          BottomNavigationBarItem(icon: Icon(Icons.route), label: "Routes"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Drivers"),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: "Buses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Alerts",
          ),
        ],
      ),
    );
  }
}
