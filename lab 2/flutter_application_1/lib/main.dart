import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blueGrey[50],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Task 1
                Container(
                  width: 250,
                  height: 250,
                  margin: EdgeInsets.all(25),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  color: Colors.orange,
                  child: Center(
                    child: Text(
                      'Task 1: Safe Container',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),

                Divider(thickness: 3, color: Colors.black26),

                // Task 2
                Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.favorite, size: 50, color: Colors.red),
                      SizedBox(height: 60),
                      Icon(Icons.thumb_up, size: 50, color: Colors.blue),
                      Icon(Icons.share, size: 50, color: Colors.green),
                    ],
                  ),
                ),

                Divider(thickness: 3, color: Colors.black26),

                // Task 3
                Container(
                  height: 100,
                  color: Colors.grey[300],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.volume_up, size: 50, color: Colors.red),
                      Icon(Icons.bluetooth, size: 50, color: Colors.blue),
                      Icon(Icons.wifi, size: 50, color: Colors.green),
                    ],
                  ),
                ),

                Divider(thickness: 3, color: Colors.black26),

                // Task 4
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            'Task 4: Header',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 100,
                            height: 50,
                            color: Colors.red,
                            child: Center(
                              child: Text(
                                'Red',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 50,
                            color: Colors.green,
                            child: Center(
                              child: Text(
                                'Green',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
