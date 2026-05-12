import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMT Cuisine',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const OrderScreen(),
    );
  }
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String? errorMessage;
  String selectedSize = "Medium";
  List<String> pizzaSizes = ["Small", "Medium", "Large", "Party Size"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SMT Cuisine Order"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= TASK 1 =================
            const Text(
              "Customer Name",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person),
                hintText: "Enter customer name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= TASK 2 =================
            const Text(
              "Promo Code",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextFormField(
              onChanged: (value) {
                setState(() {
                  if (value.contains(" ")) {
                    errorMessage = "Don't use blank spaces";
                  } else {
                    errorMessage = null;
                  }
                });
              },

              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.discount),
                hintText: "Enter promo code",
                errorText: errorMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= TASK 3 =================
            const Text(
              "Select Pizza Size",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),

              child: DropdownButton<String>(
                value: selectedSize,
                isExpanded: true,
                underline: const SizedBox(),

                items: pizzaSizes.map((String size) {
                  return DropdownMenuItem(value: size, child: Text(size));
                }).toList(),

                onChanged: (String? newValue) {
                  setState(() {
                    selectedSize = newValue!;
                  });
                },
              ),
            ),

            const SizedBox(height: 30),
            Text(
              "Selected Size: $selectedSize",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
