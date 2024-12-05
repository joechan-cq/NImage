import 'package:flutter/material.dart';
import 'package:nimage/nimage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: NImage(
              'https://images.pexels.com/photos/18876270/pexels-photo-18876270.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
              width: 400,
              height: 400,
              placeHolder: Container(color: Colors.blue),
              errorBuilder: (_, __, ___) {
                return Container(color: Colors.red);
              },
            ),
          ),
        ),
      ),
    );
  }
}
