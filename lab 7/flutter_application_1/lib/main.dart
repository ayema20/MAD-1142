import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture & Slider Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GestureSliderPage(),
    );
  }
}

class GestureSliderPage extends StatefulWidget {
  const GestureSliderPage({super.key});

  @override
  State<GestureSliderPage> createState() => _GestureSliderPageState();
}

class _GestureSliderPageState extends State<GestureSliderPage> {
  // ===== Phase 1 =====

  Color _boxColor = Colors.orange;
  double _borderRadius = 0.0;
  final double _originalSize = 200.0;

  // ===== Phase 2 =====

  double _sliderValue = 50.0;

  // ===== Phase 3 =====

  double red = 100;
  double green = 100;
  double blue = 200;

  double previewSize = 200;

  Color get previewColor =>
      Color.fromRGBO(red.toInt(), green.toInt(), blue.toInt(), 1);

  String get hexCode {
    return '#'
            '${red.toInt().toRadixString(16).padLeft(2, '0')}'
            '${green.toInt().toRadixString(16).padLeft(2, '0')}'
            '${blue.toInt().toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  // Random Color Generator
  Color getRandomColor() {
    final Random random = Random();

    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  // Reset Box
  void resetBox() {
    setState(() {
      _boxColor = Colors.orange;
      _borderRadius = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gesture, Slider & Color Mixer')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ===== Phase 1 =====
            const Text(
              "Phase 1: GestureDetector",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                setState(() {
                  _boxColor = getRandomColor();
                });
              },

              onDoubleTap: () {
                setState(() {
                  _borderRadius = _borderRadius == 0 ? 100 : 0;
                });
              },

              onLongPress: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Resetting...')));

                resetBox();
              },

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),

                width: _originalSize,
                height: _originalSize,

                decoration: BoxDecoration(
                  color: _boxColor,
                  borderRadius: BorderRadius.circular(_borderRadius),
                ),
              ),
            ),

            const SizedBox(height: 50),

            // ===== Phase 2 =====
            const Text(
              "Phase 2: Sliders",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text(
              'Value: ${_sliderValue.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            // Material Slider
            Slider(
              value: _sliderValue,
              min: 0.0,
              max: 100.0,
              divisions: 10,
              label: _sliderValue.toStringAsFixed(1),

              onChanged: (double value) {
                setState(() {
                  _sliderValue = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // Cupertino Slider
            CupertinoSlider(
              value: _sliderValue,
              min: 0.0,
              max: 100.0,
              divisions: 10,

              onChanged: (double value) {
                setState(() {
                  _sliderValue = value;
                });
              },
            ),

            const SizedBox(height: 50),

            // ===== Phase 3 =====
            const Text(
              "Phase 3: Mood & Color Mixer",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),
            GestureDetector(
              onLongPress: () {
                print("Copied Hex Code: $hexCode");

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hex Code Copied: $hexCode')),
                );
              },
              onHorizontalDragUpdate: (details) {
                setState(() {
                  previewSize += details.delta.dx;

                  if (previewSize < 100) {
                    previewSize = 100;
                  }

                  if (previewSize > 350) {
                    previewSize = 350;
                  }
                });
              },

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),

                width: previewSize,
                height: previewSize,

                decoration: BoxDecoration(
                  color: previewColor,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Center(
                  child: Text(
                    hexCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text("Red", style: TextStyle(fontSize: 18)),

            Slider(
              value: red,
              min: 0,
              max: 255,

              onChanged: (value) {
                setState(() {
                  red = value;
                });
              },
            ),
            const Text("Green", style: TextStyle(fontSize: 18)),

            Slider(
              value: green,
              min: 0,
              max: 255,

              onChanged: (value) {
                setState(() {
                  green = value;
                });
              },
            ),
            const Text("Blue", style: TextStyle(fontSize: 18)),

            Slider(
              value: blue,
              min: 0,
              max: 255,

              onChanged: (value) {
                setState(() {
                  blue = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
