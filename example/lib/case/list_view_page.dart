import 'package:flutter/material.dart';
import 'package:nimage/nimage.dart';

class ListViewPage extends StatefulWidget {
  const ListViewPage({super.key});

  @override
  ListViewPageState createState() => ListViewPageState();
}

class ListViewPageState extends State<ListViewPage> {
  List<String> uriList = [
    'https://picsum.photos/id/237/200/300',
    'https://picsum.photos/id/238/200/300',
    'https://picsum.photos/id/239/200/300',
    'https://picsum.photos/id/240/200/300',
    'https://picsum.photos/id/241/200/300',
    'https://picsum.photos/id/242/200/300',
    'https://picsum.photos/id/243/200/300',
    'https://picsum.photos/id/244/200/300',
    'https://picsum.photos/id/245/200/300',
    'https://picsum.photos/id/246/200/300',
    'https://picsum.photos/id/247/200/300',
    'https://picsum.photos/id/248/200/300',
    'https://picsum.photos/id/249/200/300',
    'https://picsum.photos/id/250/200/300',
    'https://picsum.photos/id/251/200/300',
    'https://picsum.photos/id/252/200/300',
    'https://picsum.photos/id/253/200/300',
    'https://picsum.photos/id/254/200/300',
    'https://picsum.photos/id/255/200/300',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ListView Page'),
      ),
      body: ListView.separated(
        itemCount: 20,
        itemBuilder: (context, index) {
          String uri = uriList[index % uriList.length];
          return Container(
            height: 100,
            alignment: Alignment.center,
            child: NImage(
              uri,
              width: 100,
              height: 100,
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(height: 1, color: Colors.grey);
        },
      ),
    );
  }
}
