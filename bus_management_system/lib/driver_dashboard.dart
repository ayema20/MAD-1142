import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';
import 'driver_tracking_tab.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  bool loading = true;

  Map<String, dynamic>? driver;
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
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() => loading = false);
        return;
      }

      final uid = currentUser.uid;

      final driverSnap = await FirebaseFirestore.instance
          .collection("drivers")
          .doc(uid)
          .get();

      driver = driverSnap.data();

      final routeCode = (driver?["route_code"] ?? "").toString().trim();

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
          .where("role", whereIn: ["driver", "all"])
          .get();

      notifications = notifSnap.docs.map((e) => e.data()).toList();

      setState(() => loading = false);
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() => loading = false);
    }
  }

  Widget buildCard(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 400;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),

        appBar: AppBar(
          title: const Text("Driver Dashboard"),
          centerTitle: true,
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: "Dashboard"),
              Tab(icon: Icon(Icons.location_on), text: "Tracking"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => logout(),
            ),
          ],
        ),

        body: loading
            ? const Center(child: CircularProgressIndicator())
            : driver == null
            ? const Center(child: Text("No Driver Found"))
            : TabBarView(
                children: [
                  // ================= DASHBOARD =================
                  SingleChildScrollView(
                    padding: EdgeInsets.all(isSmall ? 10 : 16),
                    child: Column(
                      children: [
                        buildCard("Driver Info", Icons.person, [
                          Text("Name: ${driver?['name'] ?? ''}"),
                          Text("Email: ${driver?['email'] ?? ''}"),
                          Text(
                            "Registration: ${driver?['registration_number'] ?? ''}",
                          ),
                          Text("Shift: ${driver?['shift'] ?? ''}"),
                          Text("Route Code: ${driver?['route_code'] ?? ''}"),
                        ]),

                        buildCard("Route Info", Icons.route, [
                          Text("Start: ${route?['start_point'] ?? 'N/A'}"),
                          Text("End: ${route?['end_point'] ?? 'N/A'}"),
                        ]),

                        buildCard("Bus Info", Icons.directions_bus, [
                          Text("Bus ID: ${bus?['bus_id'] ?? 'Not Found'}"),
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
                            ...notifications.map(
                              (n) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.notifications,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n["message"] ?? "",
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),

                                          const SizedBox(height: 3),

                                          Text(
                                            "Role: ${n["role"] ?? ''}",
                                            style: const TextStyle(
                                              fontSize: 11,
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
                              ),
                            ),
                        ]),
                      ],
                    ),
                  ),

                  // ================= TRACKING =================
                  DriverTrackingTab(busId: bus?['bus_id'] ?? 0),
                ],
              ),
      ),
    );
  }
}
