import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "active":
        return Colors.green;
      case "maintenance":
        return Colors.red;
      case "delayed":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// ================= SMALL STAT CARD =================
  Widget statCard(
    BuildContext context,
    String collection,
    String title,
    IconData icon,
    Color color,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Expanded(
          child: Container(
            height: 70,
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF243B6B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$count",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ================= BUS CARD =================
  Widget busCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      height: 105,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B3D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data["number"] ?? "Bus",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: getStatusColor(
                    data["status"] ?? "active",
                  ).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (data["status"] ?? "active").toUpperCase(),
                  style: TextStyle(
                    color: getStatusColor(data["status"] ?? "active"),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          Text(
            "Route: ${data["route_code"] ?? "N/A"}",
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),

          Text(
            "Driver: ${data["driver"] ?? "N/A"}",
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= STATS =================
          Row(
            children: [
              statCard(
                context,
                "buses",
                "Bus",
                Icons.directions_bus,
                Colors.blue,
              ),
              statCard(context, "students", "Std", Icons.school, Colors.green),
            ],
          ),
          Row(
            children: [
              statCard(context, "routes", "Route", Icons.route, Colors.orange),
              statCard(context, "drivers", "Drv", Icons.person, Colors.purple),
            ],
          ),

          const SizedBox(height: 15),

          /// ================= ACTIVE BUSES TITLE (DARK BLUE) =================
          const Text(
            "Active Buses",
            style: TextStyle(
              color: Color(0xFF0D1B3D), // 🔵 dark blue
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          /// ================= BUS LIST =================
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("buses").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return busCard(data);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
