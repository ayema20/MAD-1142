import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AddStudentTab extends StatefulWidget {
  const AddStudentTab({super.key});

  @override
  State<AddStudentTab> createState() => _AddStudentTabState();
}

class _AddStudentTabState extends State<AddStudentTab> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final regCtrl = TextEditingController();
  final searchCtrl = TextEditingController();

  String searchText = "";
  String feeStatus = "unpaid";
  String? selectedRoute;
  bool showPassword = false;

  List<String> routes = [];

  @override
  void initState() {
    super.initState();
    fetchRoutes();
  }

  /// ================= FETCH ROUTES =================
  Future<void> fetchRoutes() async {
    final snap = await FirebaseFirestore.instance.collection("routes").get();

    setState(() {
      routes = snap.docs.map((e) => e["route_code"].toString()).toList();
    });
  }

  /// ================= ADD STUDENT (FIRESTORE + RTDB) =================
  Future<void> saveStudent() async {
    if (nameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passCtrl.text.isEmpty)
      return;

    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailCtrl.text.trim(),
            password: passCtrl.text.trim(),
          );

      String uid = user.user!.uid;

      Map<String, dynamic> studentData = {
        "uid": uid,
        "name": nameCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "registration_number": regCtrl.text.trim(),
        "route_code": selectedRoute ?? "",
        "role": "student",
        "fee_status": feeStatus,
        "createdAt": DateTime.now().toIso8601String(),
      };

      /// FIRESTORE
      await FirebaseFirestore.instance.collection("students").doc(uid).set({
        ...studentData,
        "createdAt": FieldValue.serverTimestamp(),
      });

      /// REALTIME DATABASE
      await FirebaseDatabase.instance.ref("students/$uid").set(studentData);

      clearFields();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student Added Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  /// ================= EDIT STUDENT (SYNC BOTH) =================
  void editStudentDialog(String id, Map<String, dynamic> d) {
    final nameCtrl = TextEditingController(text: d["name"] ?? "");
    final regCtrl = TextEditingController(text: d["registration_number"] ?? "");

    String selected = d["route_code"] ?? "";
    String fee = d["fee_status"] ?? "unpaid";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("⭐ Edit Student"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: regCtrl,
                    decoration: const InputDecoration(
                      labelText: "Registration Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: routes.contains(selected) ? selected : null,
                    items: routes
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) {
                      setDialog(() {
                        selected = v ?? "";
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Route",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: fee,
                    items: const [
                      DropdownMenuItem(value: "paid", child: Text("Paid")),
                      DropdownMenuItem(value: "unpaid", child: Text("Unpaid")),
                    ],
                    onChanged: (v) {
                      setDialog(() {
                        fee = v ?? "unpaid";
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Fee Status",
                      border: OutlineInputBorder(),
                    ),
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
                  Map<String, dynamic> updatedData = {
                    "name": nameCtrl.text.trim(),
                    "registration_number": regCtrl.text.trim(),
                    "route_code": selected,
                    "fee_status": fee,
                  };

                  /// FIRESTORE UPDATE
                  await FirebaseFirestore.instance
                      .collection("students")
                      .doc(id)
                      .update(updatedData);

                  /// RTDB UPDATE
                  await FirebaseDatabase.instance
                      .ref("students/$id")
                      .update(updatedData);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Student Updated")),
                  );
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ================= DELETE (SYNC BOTH) =================
  Future<void> deleteStudent(String id) async {
    await FirebaseFirestore.instance.collection("students").doc(id).delete();

    await FirebaseDatabase.instance.ref("students/$id").remove();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Student Deleted")));
  }

  /// ================= CLEAR =================
  void clearFields() {
    nameCtrl.clear();
    emailCtrl.clear();
    passCtrl.clear();
    regCtrl.clear();
    selectedRoute = null;
    setState(() {});
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
        hintText: "Search Student",
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
              /// ================= ADD FORM =================
              Card(
                elevation: 4,
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
                        decoration: InputDecoration(
                          labelText: "Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: regCtrl,
                        decoration: const InputDecoration(
                          labelText: "Registration Number",
                        ),
                      ),
                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: selectedRoute,
                        items: routes
                            .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            selectedRoute = v;
                          });
                        },
                        decoration: const InputDecoration(labelText: "Route"),
                      ),
                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: feeStatus,
                        items: const [
                          DropdownMenuItem(value: "paid", child: Text("Paid")),
                          DropdownMenuItem(
                            value: "unpaid",
                            child: Text("Unpaid"),
                          ),
                        ],
                        onChanged: (v) {
                          setState(() {
                            feeStatus = v ?? "unpaid";
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Fee Status",
                        ),
                      ),
                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: saveStudent,
                          child: const Text("Add Student"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              searchBox(),

              const SizedBox(height: 15),

              /// ================= LIST =================
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("students")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var docs = snapshot.data!.docs;

                  var filtered = docs.where((doc) {
                    var d = doc.data() as Map<String, dynamic>;
                    return (d["name"] ?? "").toString().toLowerCase().contains(
                      searchText,
                    );
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
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(d["name"] ?? ""),
                          subtitle: Text(
                            "Email: ${d["email"]}\n"
                            "Reg: ${d["registration_number"]}\n"
                            "Route: ${d["route_code"]}\n"
                            "Fee: ${d["fee_status"]}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => editStudentDialog(id, d),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => deleteStudent(id),
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
