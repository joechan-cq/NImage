import 'package:flutter/material.dart';
import 'package:nimage/nimage.dart';

class SinglePicturePage extends StatefulWidget {
  const SinglePicturePage({super.key});

  @override
  SinglePicturePageState createState() => SinglePicturePageState();
}

class SinglePicturePageState extends State<SinglePicturePage> {
  //https://preview.qiantucdn.com/58pic/27/31/97/69y58PIC8I1qke0dydyVe_PIC2018.png!w1024_new_small_1
  String jpgUrl =
      'https://images.pexels.com/photos/26146996/pexels-photo-26146996.jpeg?auto=compress&cs=tinysrgb&w=800&lazy=load';
  String gifUrl =
      'https://gd-hbimg.huaban.com/e0a25a7cab0d7c2431978726971d61720732728a315ae-57EskW_fw1200';

  int type = 0;
  double size = 100;
  bool backgroundColor = false;
  BoxFit fit = BoxFit.fill;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Single Picture'),
      ),
      body: LayoutBuilder(builder: (context, cs) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _imageTypeSet(),
                _sizeSet(),
                _backgroundColorControl(),
                _fitSet(),
                const SizedBox(height: 30),
                NImage(
                  type == 0 ? jpgUrl : gifUrl,
                  width: size,
                  height: size,
                  fit: fit,
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
          ),
        );
      }),
    );
  }

  Widget _imageTypeSet() {
    return Row(
      children: [
        const Text('loadImage:', style: TextStyle(fontSize: 18)),
        Expanded(
          child: RadioListTile<int>(
              title: const Text('jpg'),
              value: 0,
              contentPadding: EdgeInsets.zero,
              groupValue: type,
              onChanged: (int? v) {
                setState(() {
                  type = v!;
                });
              }),
        ),
        Expanded(
          child: RadioListTile<int>(
              title: const Text('gif'),
              value: 1,
              contentPadding: EdgeInsets.zero,
              groupValue: type,
              onChanged: (int? v) {
                setState(() {
                  type = v!;
                });
              }),
        ),
      ],
    );
  }

  Widget _sizeSet() {
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

  Widget _fitSet() {
    var data = [
      BoxFit.none,
      BoxFit.fill,
      BoxFit.contain,
      BoxFit.cover,
      BoxFit.fitWidth,
      BoxFit.fitHeight,
      BoxFit.scaleDown
    ];
    return Row(
      children: [
        const Text('BoxFit:', style: TextStyle(fontSize: 18)),
        Expanded(child: Container()),
        DropdownMenu<BoxFit>(
          initialSelection: fit,
          onSelected: (v) {
            setState(() {
              fit = v!;
            });
          },
          dropdownMenuEntries: data.map((BoxFit value) {
            return DropdownMenuEntry<BoxFit>(value: value, label: value.name);
          }).toList(),
        ),
      ],
    );
  }
}
