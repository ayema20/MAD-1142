import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StudentTrackingTab extends StatefulWidget {
  final dynamic busId;

  const StudentTrackingTab({super.key, required this.busId});

  @override
  State<StudentTrackingTab> createState() => _StudentTrackingTabState();
}

class _StudentTrackingTabState extends State<StudentTrackingTab> {
  final db = FirebaseDatabase.instance.ref();

  LatLng busLocation = LatLng(24.8607, 67.0011);

  bool loading = true;

  String speed = "0";
  String status = "offline";

  StreamSubscription? listener;

  @override
  void initState() {
    super.initState();
    listenBus();
  }

  // ================= LISTEN BUS LOCATION =================
  void listenBus() {
    if (widget.busId == 0 || widget.busId == null) {
      return;
    }

    listener = db
        .child("bus_locations")
        .child(widget.busId.toString())
        .onValue
        .listen((event) {
          if (event.snapshot.value != null) {
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);

            final lat = (data["latitude"] ?? 0).toDouble();

            final lng = (data["longitude"] ?? 0).toDouble();

            setState(() {
              busLocation = LatLng(lat, lng);

              speed = data["speed"]?.toString() ?? "0";

              status = data["status"] ?? "offline";

              loading = false;
            });
          }
        });
  }

  @override
  void dispose() {
    listener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ================= NO BUS =================
    if (widget.busId == 0) {
      return const Center(
        child: Text("No Bus Assigned", style: TextStyle(fontSize: 16)),
      );
    }

    // ================= LOADING =================
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // ================= MAP =================
        FlutterMap(
          options: MapOptions(initialCenter: busLocation, initialZoom: 15),

          children: [
            // ================= MAP TILE =================
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",

              // FIX FOR 403 ERROR
              userAgentPackageName: "com.example.bus_management_system",

              maxZoom: 19,
            ),

            // ================= BUS MARKER =================
            MarkerLayer(
              markers: [
                Marker(
                  point: busLocation,
                  width: 80,
                  height: 80,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Bus ${widget.busId}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.directions_bus,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // ================= TOP INFO CARD =================
        Positioned(
          top: 15,
          left: 15,
          right: 15,

          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                ),
              ],
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bus ID: ${widget.busId}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Speed: $speed km/h",
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Status: $status",
                      style: TextStyle(
                        color: status == "online" ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: status == "online"
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.gps_fixed,
                    color: status == "online" ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
