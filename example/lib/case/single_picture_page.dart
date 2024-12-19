import 'package:flutter/material.dart';
import 'package:nimage/nimage.dart';

class SinglePicturePage extends StatefulWidget {
  const SinglePicturePage({super.key});

  @override
  SinglePicturePageState createState() => SinglePicturePageState();
}

class SinglePicturePageState extends State<SinglePicturePage> {
  double size = 100;
  bool backgroundColor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text('Single Picture')],
        ),
      ),
      body: LayoutBuilder(builder: (context, cs) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _sizeControl(),
              _backgroundColorControl(),
              NImage(
                // 'https://images.pexels.com/photos/26146996/pexels-photo-26146996.jpeg?auto=compress&cs=tinysrgb&w=800&lazy=load',
                'https://preview.qiantucdn.com/58pic/27/31/97/69y58PIC8I1qke0dydyVe_PIC2018.png!w1024_new_small_1',
                width: size,
                height: size,
                backgroundColor: backgroundColor ? Colors.red : null,
                placeHolder: Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                  ),
                ),
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'Error',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _sizeControl() {
    return Row(
      children: [
        const Text('size:', style: TextStyle(fontSize: 18)),
        Expanded(
          child: RadioListTile<double>(
              title: const Text('100'),
              value: 100,
              contentPadding: EdgeInsets.zero,
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
              contentPadding: EdgeInsets.zero,
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
              contentPadding: EdgeInsets.zero,
              groupValue: size,
              onChanged: (double? v) {
                setState(() {
                  size = v!;
                });
              }),
        ),
      ],
    );
  }

  Widget _backgroundColorControl() {
    return CheckboxListTile(
      title: const Text('backgroundColor:', style: TextStyle(fontSize: 18)),
      contentPadding: EdgeInsets.zero,
      value: backgroundColor,
      onChanged: (v) {
        setState(() {
          backgroundColor = v!;
        });
      },
    );
  }
}
