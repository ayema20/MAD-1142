import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AddDriverTab extends StatefulWidget {
  const AddDriverTab({super.key});

  @override
  State<AddDriverTab> createState() => _AddDriverTabState();
}

class _AddDriverTabState extends State<AddDriverTab> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final regCtrl = TextEditingController();

  bool showPassword = false;
  bool loading = false;

  String routeCode = "";
  String shift = "morning";
  String searchText = "";

  List<String> routeList = [];

  @override
  void initState() {
    super.initState();
    loadRoutes();
  }

  Future<void> loadRoutes() async {
    final snap = await FirebaseFirestore.instance.collection("routes").get();

    setState(() {
      routeList = snap.docs.map((d) => d["route_code"].toString()).toList();
      if (routeList.isNotEmpty) {
        routeCode = routeList.first;
      }
    });
  }

  Future<void> addDriver() async {
    if (nameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passCtrl.text.length < 6 ||
        routeCode.isEmpty)
      return;

    setState(() => loading = true);

    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailCtrl.text.trim(),
            password: passCtrl.text.trim(),
          );

      final driverData = {
        "name": nameCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "password": passCtrl.text.trim(),
        "registration_number": regCtrl.text.trim(),
        "route_code": routeCode,
        "shift": shift,
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "role": "driver",
        "is_active": true,
        "bus_id": "",
      };

      await FirebaseFirestore.instance
          .collection("drivers")
          .doc(user.user!.uid)
          .set(driverData);

      await FirebaseDatabase.instance
          .ref("drivers/${user.user!.uid}")
          .set(driverData);

      clearFields();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Driver Added")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  Future<void> deleteDriver(String id) async {
    await FirebaseFirestore.instance.collection("drivers").doc(id).delete();
    await FirebaseDatabase.instance.ref("drivers/$id").remove();
  }

  Future<void> updateDriver(String id, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection("drivers").doc(id).update(data);

    await FirebaseDatabase.instance.ref("drivers/$id").update(data);
  }

  void clearFields() {
    nameCtrl.clear();
    emailCtrl.clear();
    passCtrl.clear();
    regCtrl.clear();

    if (routeList.isNotEmpty) routeCode = routeList.first;
    shift = "morning";
    setState(() {});
  }

  void showEditDialog(String id, Map<String, dynamic> data) {
    final name = TextEditingController(text: data["name"]);
    final email = TextEditingController(text: data["email"]);
    final reg = TextEditingController(text: data["registration_number"]);

    String editRoute = data["route_code"] ?? routeCode;
    String editShift = data["shift"] ?? "morning";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Driver"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: name),
                TextField(controller: email),
                TextField(controller: reg),

                const SizedBox(height: 10),

                DropdownButtonFormField(
                  value: editRoute,
                  items: routeList
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => editRoute = v.toString(),
                  decoration: const InputDecoration(labelText: "Route"),
                ),

                DropdownButtonFormField(
                  value: editShift,
                  items: const [
                    DropdownMenuItem(value: "morning", child: Text("Morning")),
                    DropdownMenuItem(value: "evening", child: Text("Evening")),
                    DropdownMenuItem(value: "night", child: Text("Night")),
                  ],
                  onChanged: (v) => editShift = v.toString(),
                  decoration: const InputDecoration(labelText: "Shift"),
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
                await updateDriver(id, {
                  "name": name.text.trim(),
                  "email": email.text.trim(),
                  "registration_number": reg.text.trim(),
                  "route_code": editRoute,
                  "shift": editShift,
                });

                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  Widget searchBox() {
    return TextField(
      onChanged: (v) => setState(() => searchText = v.toLowerCase()),
      decoration: const InputDecoration(
        labelText: "Search Driver",
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              /// FORM
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: "Name"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: "Email"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passCtrl,
                        obscureText: !showPassword,
                        decoration: const InputDecoration(
                          labelText: "Password",
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: regCtrl,
                        decoration: const InputDecoration(
                          labelText: "Reg Number",
                        ),
                      ),
                      const SizedBox(height: 10),

                      DropdownButtonFormField(
                        value: routeCode.isEmpty ? null : routeCode,
                        items: routeList
                            .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => routeCode = v.toString()),
                        decoration: const InputDecoration(labelText: "Route"),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField(
                        value: shift,
                        items: const [
                          DropdownMenuItem(
                            value: "morning",
                            child: Text("Morning"),
                          ),
                          DropdownMenuItem(
                            value: "evening",
                            child: Text("Evening"),
                          ),
                          DropdownMenuItem(
                            value: "night",
                            child: Text("Night"),
                          ),
                        ],
                        onChanged: (v) => setState(() => shift = v.toString()),
                        decoration: const InputDecoration(labelText: "Shift"),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: loading ? null : addDriver,
                        child: loading
                            ? const CircularProgressIndicator()
                            : const Text("Add Driver"),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
              searchBox(),
              const SizedBox(height: 10),

              /// LIST
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("drivers")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  var filtered = snapshot.data!.docs.where((d) {
                    var data = d.data() as Map<String, dynamic>;
                    return (data["name"] ?? "")
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

                      return Card(
                        child: ListTile(
                          title: Text(d["name"] ?? "No Name"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Email: ${d["email"] ?? ""}"),
                              Text("Reg: ${d["registration_number"] ?? ""}"),
                              Text("Route: ${d["route_code"] ?? ""}"),
                              Text("Shift: ${d["shift"] ?? ""}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>
                                    showEditDialog(filtered[i].id, d),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => deleteDriver(filtered[i].id),
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
