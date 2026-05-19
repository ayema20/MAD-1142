import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class AddBusTab extends StatefulWidget {
  const AddBusTab({super.key});

  @override
  State<AddBusTab> createState() => _AddBusTabState();
}

class _AddBusTabState extends State<AddBusTab> {
  final busIdCtrl = TextEditingController();
  final numberCtrl = TextEditingController();
  final capacityCtrl = TextEditingController();
  final searchCtrl = TextEditingController();

  String searchText = "";
  String? selectedRoute;
  String? selectedStatus;

  /// ================= ADD BUS =================
  Future<void> addBus() async {
    if (numberCtrl.text.isEmpty) return;

    String id = FirebaseFirestore.instance.collection("buses").doc().id;

    Map<String, dynamic> busData = {
      "id": id,
      "bus_id": int.tryParse(busIdCtrl.text) ?? 0,
      "number": numberCtrl.text.trim(),
      "capacity": capacityCtrl.text.trim(),
      "route_code": selectedRoute ?? "",
      "status": selectedStatus ?? "",
      "createdAt": DateTime.now().toIso8601String(),
    };

    await FirebaseFirestore.instance.collection("buses").doc(id).set({
      ...busData,
      "createdAt": FieldValue.serverTimestamp(),
    });

    await FirebaseDatabase.instance.ref("buses/$id").set(busData);

    clearFields();
  }

  /// ================= DELETE =================
  Future<void> deleteBus(String id) async {
    await FirebaseFirestore.instance.collection("buses").doc(id).delete();
    await FirebaseDatabase.instance.ref("buses/$id").remove();
  }

  /// ================= UPDATE =================
  Future<void> updateBus(
    String id,
    String busId,
    String number,
    String capacity,
    String route,
    String status,
  ) async {
    Map<String, dynamic> updated = {
      "bus_id": int.tryParse(busId) ?? 0,
      "number": number,
      "capacity": capacity,
      "route_code": route,
      "status": status,
    };

    await FirebaseFirestore.instance
        .collection("buses")
        .doc(id)
        .update(updated);

    await FirebaseDatabase.instance.ref("buses/$id").update(updated);
  }

  /// ================= CLEAR =================
  void clearFields() {
    busIdCtrl.clear();
    numberCtrl.clear();
    capacityCtrl.clear();

    setState(() {
      selectedRoute = null;
      selectedStatus = null;
    });
  }

  /// ================= EDIT POPUP =================
  void showEditDialog(String id, Map<String, dynamic> data) {
    final busIdEdit = TextEditingController(text: data["bus_id"].toString());
    final numberEdit = TextEditingController(text: data["number"] ?? "");
    final capacityEdit = TextEditingController(text: data["capacity"] ?? "");

    String routeEdit = data["route_code"] ?? "";
    String statusEdit = data["status"] ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Edit Bus"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: busIdEdit,
                      decoration: const InputDecoration(labelText: "Bus ID"),
                    ),
                    TextField(
                      controller: numberEdit,
                      decoration: const InputDecoration(
                        labelText: "Bus Number",
                      ),
                    ),
                    TextField(
                      controller: capacityEdit,
                      decoration: const InputDecoration(labelText: "Capacity"),
                    ),

                    const SizedBox(height: 10),

                    /// ROUTE (simple dropdown fallback)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("routes")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        var docs = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          value: routeEdit.isEmpty ? null : routeEdit,
                          items: docs.map((doc) {
                            var d = doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem(
                              value: d["route_code"].toString(),
                              child: Text(d["route_code"].toString()),
                            );
                          }).toList(),
                          onChanged: (v) {
                            setStateDialog(() {
                              routeEdit = v ?? "";
                            });
                          },
                          decoration: const InputDecoration(labelText: "Route"),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    /// STATUS
                    DropdownButtonFormField<String>(
                      value: statusEdit.isEmpty ? null : statusEdit,
                      items: const [
                        DropdownMenuItem(
                          value: "active",
                          child: Text("active"),
                        ),
                        DropdownMenuItem(value: "delay", child: Text("delay")),
                        DropdownMenuItem(
                          value: "maintenance",
                          child: Text("maintenance"),
                        ),
                      ],
                      onChanged: (v) {
                        setStateDialog(() {
                          statusEdit = v ?? "";
                        });
                      },
                      decoration: const InputDecoration(labelText: "Status"),
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
                    await updateBus(
                      id,
                      busIdEdit.text,
                      numberEdit.text,
                      capacityEdit.text,
                      routeEdit,
                      statusEdit,
                    );

                    Navigator.pop(context);
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ================= SEARCH =================
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
        hintText: "Search Bus",
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              /// ================= FORM =================
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: busIdCtrl,
                        decoration: const InputDecoration(labelText: "Bus ID"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: numberCtrl,
                        decoration: const InputDecoration(
                          labelText: "Bus Number",
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: capacityCtrl,
                        decoration: const InputDecoration(
                          labelText: "Capacity",
                        ),
                      ),
                      const SizedBox(height: 10),

                      /// ROUTE
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("routes")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          var docs = snapshot.data!.docs;

                          return DropdownButtonFormField<String>(
                            value: selectedRoute,
                            items: docs.map((doc) {
                              var d = doc.data() as Map<String, dynamic>;
                              return DropdownMenuItem(
                                value: d["route_code"].toString(),
                                child: Text(d["route_code"].toString()),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => selectedRoute = v),
                            decoration: const InputDecoration(
                              labelText: "Route",
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      /// STATUS
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        items: const [
                          DropdownMenuItem(
                            value: "active",
                            child: Text("active"),
                          ),
                          DropdownMenuItem(
                            value: "delay",
                            child: Text("delay"),
                          ),
                          DropdownMenuItem(
                            value: "maintenance",
                            child: Text("maintenance"),
                          ),
                        ],
                        onChanged: (v) => setState(() => selectedStatus = v),
                        decoration: const InputDecoration(labelText: "Status"),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed: addBus,
                        child: const Text("Add Bus"),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
              searchBox(),
              const SizedBox(height: 10),

              /// ================= LIST =================
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("buses")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  var docs = snapshot.data!.docs;

                  var filtered = docs.where((doc) {
                    var d = doc.data() as Map<String, dynamic>;
                    return (d["number"] ?? "")
                        .toString()
                        .toLowerCase()
                        .contains(searchText);
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      var d = filtered[i].data() as Map<String, dynamic>;
                      var id = filtered[i].id;

                      return Card(
                        child: ListTile(
                          title: Text(d["number"] ?? ""),
                          subtitle: Text(
                            "Bus ID: ${d["bus_id"]}\n"
                            "Capacity: ${d["capacity"]}\n"
                            "Route: ${d["route_code"]}\n"
                            "Status: ${d["status"]}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  showEditDialog(id, d);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => deleteBus(id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
