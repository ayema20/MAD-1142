import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class AddNotificationTab extends StatefulWidget {
  const AddNotificationTab({super.key});

  @override
  State<AddNotificationTab> createState() => _AddNotificationTabState();
}

class _AddNotificationTabState extends State<AddNotificationTab> {
  final messageCtrl = TextEditingController();

  String role = "all";
  List<String> selectedDays = [];

  /// ================= ADD NOTIFICATION (FIRESTORE + RTDB) =================
  Future<void> addNotification() async {
    if (messageCtrl.text.isEmpty) return;

    String id = FirebaseFirestore.instance.collection("notifications").doc().id;

    Map<String, dynamic> data = {
      "id": id,
      "message": messageCtrl.text.trim(),
      "role": role,
      "days": selectedDays,
      "created_at": DateTime.now().millisecondsSinceEpoch,
    };

    /// FIRESTORE
    await FirebaseFirestore.instance
        .collection("notifications")
        .doc(id)
        .set(data);

    /// REALTIME DATABASE
    await FirebaseDatabase.instance.ref("notifications/$id").set(data);

    messageCtrl.clear();
    selectedDays.clear();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification Sent (Firestore + RTDB)")),
    );
  }

  /// ================= DELETE (SYNC BOTH) =================
  Future<void> deleteNotification(String id) async {
    await FirebaseFirestore.instance
        .collection("notifications")
        .doc(id)
        .delete();

    await FirebaseDatabase.instance.ref("notifications/$id").remove();
  }

  /// ================= SAFE DAYS =================
  List safeDays(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is String) return [data];
    return [];
  }

  /// ================= RTDB STREAM =================
  Stream<List<Map<String, dynamic>>> rtdbStream() {
    return FirebaseDatabase.instance.ref("notifications").onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return [];

      return data.entries.map((e) {
        final value = Map<String, dynamic>.from(e.value);
        return value;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                /// ================= FORM =================
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: messageCtrl,
                        decoration: const InputDecoration(labelText: "Message"),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: role,
                        items: const [
                          DropdownMenuItem(value: "all", child: Text("All")),
                          DropdownMenuItem(
                            value: "student",
                            child: Text("Student"),
                          ),
                          DropdownMenuItem(
                            value: "driver",
                            child: Text("Driver"),
                          ),
                        ],
                        onChanged: (val) => setState(() => role = val!),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        children:
                            [
                              "Monday",
                              "Tuesday",
                              "Wednesday",
                              "Thursday",
                              "Friday",
                              "Saturday",
                              "Sunday",
                            ].map((day) {
                              final selected = selectedDays.contains(day);

                              return ChoiceChip(
                                label: Text(day),
                                selected: selected,
                                onSelected: (val) {
                                  setState(() {
                                    if (val) {
                                      selectedDays.add(day);
                                    } else {
                                      selectedDays.remove(day);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: addNotification,
                          child: const Text("Send Notification"),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// ================= REALTIME LIST (RTDB) =================
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: rtdbStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final docs = snapshot.data!;

                    docs.sort(
                      (a, b) => (b["created_at"] ?? 0).compareTo(
                        a["created_at"] ?? 0,
                      ),
                    );

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        var d = docs[i];
                        List daysList = safeDays(d["days"]);

                        return Card(
                          child: ListTile(
                            title: Text(
                              (d["message"] ?? "").toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Role: ${d["role"]}\nDays: ${daysList.join(", ")}",
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteNotification(d["id"]),
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
      ),
    );
  }
}
