import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DriverTrackingTab extends StatefulWidget {
  final dynamic busId;

  const DriverTrackingTab({super.key, required this.busId});

  @override
  State<DriverTrackingTab> createState() => _DriverTrackingTabState();
}

class _DriverTrackingTabState extends State<DriverTrackingTab> {
  final db = FirebaseDatabase.instance.ref();

  StreamSubscription<Position>? positionStream;

  LatLng currentLocation = LatLng(24.8607, 67.0011);

  bool loading = true;

  bool trackingStarted = false;

  String speed = "0";

  @override
  void initState() {
    super.initState();
  }

  // ================= START TRACKING =================
  Future<void> startTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ================= CHECK GPS =================
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please Enable GPS")));

      return;
    }

    // ================= CHECK PERMISSION =================
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location Permission Permanently Denied")),
      );

      return;
    }

    setState(() {
      trackingStarted = true;
    });

    // ================= LIVE LOCATION =================
    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) async {
          final lat = position.latitude;
          final lng = position.longitude;

          setState(() {
            currentLocation = LatLng(lat, lng);

            loading = false;

            speed = position.speed.toStringAsFixed(1);
          });

          // ================= SAVE TO FIREBASE =================
          await db.child("bus_locations").child(widget.busId.toString()).set({
            "bus_id": widget.busId,

            "latitude": lat,

            "longitude": lng,

            "speed": position.speed,

            "status": "online",

            "updated_at": DateTime.now().millisecondsSinceEpoch,
          });
        });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Tracking Started")));
  }

  // ================= STOP TRACKING =================
  Future<void> stopTracking() async {
    await positionStream?.cancel();

    setState(() {
      trackingStarted = false;
      speed = "0";
    });

    // ================= UPDATE STATUS =================
    await db.child("bus_locations").child(widget.busId.toString()).update({
      "status": "offline",
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Tracking Stopped")));
  }

  @override
  void dispose() {
    positionStream?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ================= NO BUS =================
    if (widget.busId == 0) {
      return const Center(
        child: Text("No Bus Assigned", style: TextStyle(fontSize: 18)),
      );
    }

    // ================= BEFORE START =================
    if (!trackingStarted) {
      return Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          ),

          onPressed: startTracking,

          icon: const Icon(Icons.play_arrow),

          label: const Text("Start Tracking", style: TextStyle(fontSize: 16)),
        ),
      );
    }

    // ================= LOADING =================
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ================= UI =================
    return Stack(
      children: [
        // ================= MAP =================
        FlutterMap(
          options: MapOptions(initialCenter: currentLocation, initialZoom: 15),

          children: [
            // ================= MAP TILE =================
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: "com.example.bus_management_system",

              maxZoom: 19,
            ),

            // ================= BUS MARKER =================
            MarkerLayer(
              markers: [
                Marker(
                  point: currentLocation,

                  width: 100,

                  height: 100,

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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Icon(
                        Icons.directions_bus,
                        size: 45,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // ================= TOP CARD =================
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

                  blurRadius: 12,
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

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,

                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Speed: $speed m/s",

                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                // ================= STOP BUTTON =================
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                  onPressed: stopTracking,

                  icon: const Icon(Icons.stop),

                  label: const Text("Stop"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
