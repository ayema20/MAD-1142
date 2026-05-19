import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';
import 'student_tracking_tab.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool loading = true;

  Map<String, dynamic>? student;
  Map<String, dynamic>? route;
  Map<String, dynamic>? bus;

  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  String getTimeAgo(dynamic timestamp) {
    try {
      if (timestamp == null) return "";

      DateTime date;

      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is int) {
        date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        return "";
      }

      final diff = DateTime.now().difference(date);

      if (diff.inDays > 0) return "${diff.inDays} day(s) ago";
      if (diff.inHours > 0) return "${diff.inHours} hour(s) ago";
      if (diff.inMinutes > 0) return "${diff.inMinutes} min ago";
      return "just now";
    } catch (e) {
      return "";
    }
  }

  Future<void> loadAllData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final studentSnap = await FirebaseFirestore.instance
          .collection("students")
          .doc(uid)
          .get();

      student = studentSnap.data();

      final routeCode = (student?["route_code"] ?? "").toString().trim();

      if (routeCode.isNotEmpty) {
        final routeSnap = await FirebaseFirestore.instance
            .collection("routes")
            .doc(routeCode)
            .get();

        route = routeSnap.data();
      }

      if (routeCode.isNotEmpty) {
        final busSnap = await FirebaseFirestore.instance
            .collection("buses")
            .where("route_code", isEqualTo: routeCode)
            .limit(1)
            .get();

        bus = busSnap.docs.isNotEmpty ? busSnap.docs.first.data() : null;
      }

      final notifSnap = await FirebaseFirestore.instance
          .collection("notifications")
          .where("role", whereIn: ["student", "all"])
          .get();

      notifications = notifSnap.docs
          .map((e) => e.data())
          .whereType<Map<String, dynamic>>()
          .toList();

      setState(() => loading = false);
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() => loading = false);
    }
  }

  Widget buildCard(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14), // responsive tweak
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.lightBlueAccent],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16, // mobile optimized
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Student Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        logout();
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : student == null
          ? const Center(child: Text("No Student Found"))
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    color: Colors.blue,
                    child: const TabBar(
                      indicatorColor: Colors.white,
                      isScrollable: true, // RESPONSIVE FIX
                      tabs: [
                        Tab(icon: Icon(Icons.dashboard), text: "Dashboard"),
                        Tab(icon: Icon(Icons.location_on), text: "Track Bus"),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        // ================= DASHBOARD =================
                        SingleChildScrollView(
                          padding: EdgeInsets.all(screenWidth < 400 ? 10 : 16),
                          child: Column(
                            children: [
                              buildCard("Student Info", Icons.person, [
                                Text("Name: ${student?['name'] ?? ''}"),
                                Text("Email: ${student?['email'] ?? ''}"),
                                Text(
                                  "Reg No: ${student?['registration_number'] ?? ''}",
                                ),
                                Text(
                                  "Route Code: ${student?['route_code'] ?? ''}",
                                ),
                                Text(
                                  "Fee Status: ${student?['fee_status'] ?? ''}",
                                ),
                              ]),

                              buildCard("Route Info", Icons.route, [
                                Text(
                                  "Start Point: ${route?['start_point'] ?? 'Not Set'}",
                                ),
                                Text(
                                  "End Point: ${route?['end_point'] ?? 'Not Set'}",
                                ),
                              ]),

                              buildCard("Bus Info", Icons.directions_bus, [
                                Text(
                                  "Bus ID: ${bus?['bus_id'] ?? 'Not Found'}",
                                ),
                                Text(
                                  "Bus Number: ${bus?['number'] ?? 'Not Assigned'}",
                                ),
                                Text("Capacity: ${bus?['capacity'] ?? 'N/A'}"),
                                Text("Status: ${bus?['status'] ?? 'N/A'}"),
                              ]),

                              buildCard("Notifications", Icons.notifications, [
                                if (notifications.isEmpty)
                                  const Text("No Notifications")
                                else
                                  ...notifications.map((n) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.notifications,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(n["message"] ?? ""),
                                                Text(
                                                  "Role: ${n["role"] ?? ''}",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  getTimeAgo(n["created_at"]),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ]),
                            ],
                          ),
                        ),

                        // ================= TRACK TAB =================
                        StudentTrackingTab(busId: bus?['bus_id'] ?? 0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
