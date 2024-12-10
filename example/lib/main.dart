import 'package:flutter/material.dart';
import 'package:nimage/nimage.dart';

import 'case/list_view_page.dart';
import 'case/single_picture_page.dart';

void main() {
  NImage.debug = true;
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
        body: Builder(builder: (context) {
          return Container(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    child: Text('Single', style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SinglePicturePage();
                      }));
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    child: Text('ListView', style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ListViewPage();
                      }));
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
