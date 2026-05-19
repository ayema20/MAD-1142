import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class AddRouteTab extends StatefulWidget {
  const AddRouteTab({super.key});

  @override
  State<AddRouteTab> createState() => _AddRouteTabState();
}

class _AddRouteTabState extends State<AddRouteTab> {
  final routeCtrl = TextEditingController();
  final startCtrl = TextEditingController();
  final endCtrl = TextEditingController();
  final stopsCtrl = TextEditingController();
  final fareCtrl = TextEditingController();
  final searchCtrl = TextEditingController();

  String searchText = "";

  // ================= ADD ROUTE =================
  Future<void> addRoute() async {
    if (routeCtrl.text.isEmpty) return;

    final routeCode = routeCtrl.text.trim();

    final routeRef = FirebaseDatabase.instance.ref("routes/$routeCode");

    Map<String, dynamic> routeData = {
      "route_code": routeCode,
      "start_point": startCtrl.text.trim(),
      "end_point": endCtrl.text.trim(),
      "stops": stopsCtrl.text.trim(),
      "fare": fareCtrl.text.trim(),
      "createdAt": DateTime.now().toIso8601String(),
    };

    // ================= FIRESTORE =================
    await FirebaseFirestore.instance
        .collection("routes")
        .doc(routeCode)
        .set(routeData);

    // ================= REALTIME DB =================
    await routeRef.set(routeData);

    routeCtrl.clear();
    startCtrl.clear();
    endCtrl.clear();
    stopsCtrl.clear();
    fareCtrl.clear();
  }

  // ================= DELETE =================
  Future<void> deleteRoute(String routeCode) async {
    await FirebaseFirestore.instance
        .collection("routes")
        .doc(routeCode)
        .delete();

    await FirebaseDatabase.instance.ref("routes/$routeCode").remove();
  }

  // ================= UPDATE =================
  Future<void> updateRoute(
    String routeCode,
    String start,
    String end,
    String stops,
    String fare,
  ) async {
    Map<String, dynamic> updated = {
      "route_code": routeCode,
      "start_point": start,
      "end_point": end,
      "stops": stops,
      "fare": fare,
    };

    await FirebaseFirestore.instance
        .collection("routes")
        .doc(routeCode)
        .update(updated);

    await FirebaseDatabase.instance.ref("routes/$routeCode").update(updated);
  }

  // ================= EDIT DIALOG =================
  void editDialog(
    String routeCode,
    String start,
    String end,
    String stops,
    String fare,
  ) {
    final c2 = TextEditingController(text: start);
    final c3 = TextEditingController(text: end);
    final c4 = TextEditingController(text: stops);
    final c5 = TextEditingController(text: fare);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Route"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: c2,
                decoration: const InputDecoration(labelText: "Start"),
              ),
              TextField(
                controller: c3,
                decoration: const InputDecoration(labelText: "End"),
              ),
              TextField(
                controller: c4,
                decoration: const InputDecoration(labelText: "Stops"),
              ),
              TextField(
                controller: c5,
                decoration: const InputDecoration(labelText: "Fare"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await updateRoute(routeCode, c2.text, c3.text, c4.text, c5.text);

              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================
  Widget searchBox() {
    return TextField(
      controller: searchCtrl,
      onChanged: (v) {
        setState(() {
          searchText = v.toLowerCase();
        });
      },
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: "Search Route",
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // ================= FORM =================
              TextField(
                controller: routeCtrl,
                decoration: const InputDecoration(labelText: "Route Code"),
              ),

              TextField(
                controller: startCtrl,
                decoration: const InputDecoration(labelText: "Start"),
              ),

              TextField(
                controller: endCtrl,
                decoration: const InputDecoration(labelText: "End"),
              ),

              TextField(
                controller: stopsCtrl,
                decoration: const InputDecoration(labelText: "Stops"),
              ),

              TextField(
                controller: fareCtrl,
                decoration: const InputDecoration(labelText: "Fare"),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: addRoute,
                child: const Text("Add RouteS"),
              ),

              const SizedBox(height: 10),

              // ================= SEARCH =================
              searchBox(),

              const SizedBox(height: 10),

              // ================= LIST =================
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: FirebaseDatabase.instance.ref("routes").onValue,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.data!.snapshot.value == null) {
                      return const Center(child: Text("No Routes"));
                    }

                    final data = Map<String, dynamic>.from(
                      snapshot.data!.snapshot.value as Map,
                    );

                    final routes = data.entries.where((e) {
                      final r = Map<String, dynamic>.from(e.value);

                      return (r["route_code"] ?? "")
                          .toString()
                          .toLowerCase()
                          .contains(searchText);
                    }).toList();

                    return ListView.builder(
                      itemCount: routes.length,
                      itemBuilder: (context, i) {
                        final routeCode = routes[i].key;

                        final d = Map<String, dynamic>.from(routes[i].value);

                        return Card(
                          child: ListTile(
                            title: Text(d["route_code"] ?? ""),

                            subtitle: Text(
                              "${d["start_point"]} → ${d["end_point"]}\n"
                              "Stops: ${d["stops"]}\n"
                              "Fare: ${d["fare"]}",
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ================= EDIT =================
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => editDialog(
                                    routeCode,
                                    d["start_point"] ?? "",
                                    d["end_point"] ?? "",
                                    d["stops"] ?? "",
                                    d["fare"] ?? "",
                                  ),
                                ),

                                // ================= DELETE =================
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => deleteRoute(routeCode),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
