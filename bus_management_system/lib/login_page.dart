import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'admin_dashboard.dart';
import 'student_dashboard.dart';
import 'driver_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordHidden = true;
  bool isLoading = false;

  String? selectedRole;
  String? errorMessage;

  // ---------------- EMAIL LOGIN ----------------
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedRole == null) {
      setState(() => errorMessage = "Please select a role");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final uid = userCredential.user!.uid;

      DocumentSnapshot userDoc;

      if (selectedRole == "admin") {
        userDoc = await FirebaseFirestore.instance
            .collection("admins")
            .doc(uid)
            .get();
      } else if (selectedRole == "student") {
        userDoc = await FirebaseFirestore.instance
            .collection("students")
            .doc(uid)
            .get();
      } else {
        userDoc = await FirebaseFirestore.instance
            .collection("drivers")
            .doc(uid)
            .get();
      }

      if (!userDoc.exists) {
        setState(() {
          errorMessage = "No $selectedRole data found in Firestore";
          isLoading = false;
        });
        return;
      }

      if (!mounted) return;

      if (selectedRole == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else if (selectedRole == "student") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DriverDashboard()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = "Login failed";
        isLoading = false;
      });
    }
  }

  // ---------------- GOOGLE LOGIN ----------------
  Future<void> signInWithGoogle() async {
    if (selectedRole == null) {
      setState(() {
        errorMessage = "Please select role";
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // FORCE ACCOUNT PICKER
      final GoogleSignIn googleSignIn = GoogleSignIn();

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      print("Selected Email: ${googleUser.email}");

      // ---------------- CHECK FIRESTORE ----------------

      String collectionName = "";

      if (selectedRole == "admin") {
        collectionName = "admins";
      } else if (selectedRole == "student") {
        collectionName = "students";
      } else {
        collectionName = "drivers";
      }

      // FIND USER BY EMAIL
      final querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where("email", isEqualTo: googleUser.email)
          .get();

      // USER NOT FOUND
      if (querySnapshot.docs.isEmpty) {
        setState(() {
          errorMessage =
              "No $selectedRole account found with this Google email";
          isLoading = false;
        });

        return;
      }

      // ---------------- GOOGLE AUTH ----------------

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception("User is null");
      }

      print("Firebase Login Success");

      // ---------------- NAVIGATION ----------------

      if (!mounted) return;

      if (selectedRole == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else if (selectedRole == "student") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DriverDashboard()),
        );
      }
    } catch (e) {
      print(e);

      setState(() {
        errorMessage = "Google Login Failed";
        isLoading = false;
      });
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a2f55), Color(0xFF2c5364)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth;
                  bool isMobile = width < 600;

                  double cardWidth = isMobile
                      ? width * 0.92
                      : width < 1000
                      ? 380
                      : 420;

                  double titleSize;
                  double fieldHeight;

                  if (width < 600) {
                    titleSize = 20.0;
                    fieldHeight = 45.0;
                  } else {
                    titleSize = 24.0;
                    fieldHeight = 52.0;
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "🚌 Bus Portal Login",
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 15),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  roleCard(
                                    "admin",
                                    Icons.admin_panel_settings,
                                    "Admin",
                                  ),
                                  roleCard("student", Icons.school, "Student"),
                                  roleCard("driver", Icons.person, "Driver"),
                                ],
                              ),

                              const SizedBox(height: 15),

                              SizedBox(
                                height: fieldHeight,
                                child: TextFormField(
                                  controller: emailController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: inputDecoration("Email"),
                                ),
                              ),

                              const SizedBox(height: 10),

                              SizedBox(
                                height: fieldHeight,
                                child: TextFormField(
                                  controller: passwordController,
                                  obscureText: isPasswordHidden,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: inputDecoration("Password")
                                      .copyWith(
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            isPasswordHidden
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              isPasswordHidden =
                                                  !isPasswordHidden;
                                            });
                                          },
                                        ),
                                      ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              if (errorMessage != null)
                                Text(
                                  errorMessage!,
                                  style: const TextStyle(color: Colors.orange),
                                ),

                              const SizedBox(height: 15),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : login,
                                  child: isLoading
                                      ? const CircularProgressIndicator()
                                      : const Text("Sign in"),
                                ),
                              ),

                              const SizedBox(height: 10),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.login,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Continue with Google ",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : signInWithGoogle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget roleCard(String role, IconData icon, String label) {
    bool isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white,
              size: 20,
            ),
            Text(
              label,
              style: TextStyle(color: isSelected ? Colors.black : Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white24,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
