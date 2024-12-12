import 'package:flutter/material.dart';
import 'package:nimage/nimage.dart';

class SinglePicturePage extends StatefulWidget {
  const SinglePicturePage({super.key});

  @override
  SinglePicturePageState createState() => SinglePicturePageState();
}

class SinglePicturePageState extends State<SinglePicturePage> {
  double size = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text('Single Picture')],
        ),
      ),
      body: Column(
        children: [
          const Text('select to change the size of picture'),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RadioListTile<double>(
                    title: const Text('100'),
                    value: 100,
                    groupValue: size,
                    onChanged: (double? v) {
                      setState(() {
                        size = v!;
                      });
                    }),
              ),
              Expanded(
                child: RadioListTile<double>(
                    title: const Text('200'),
                    value: 200,
                    groupValue: size,
                    onChanged: (double? v) {
                      setState(() {
                        size = v!;
                      });
                    }),
              ),
              Expanded(
                child: RadioListTile<double>(
                    title: const Text('300'),
                    value: 300,
                    groupValue: size,
                    onChanged: (double? v) {
                      setState(() {
                        size = v!;
                      });
                    }),
              ),
            ],
          ),
          NImage(
            'https://images.pexels.com/photos/26146996/pexels-photo-26146996.jpeg?auto=compress&cs=tinysrgb&w=800&lazy=load',
            width: size,
            height: size,
          ),
        ],
      ),
    );
  }
}
