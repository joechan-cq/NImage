import 'package:flutter/material.dart';
import 'package:nimage/nimage.dart';

class ListViewPage extends StatefulWidget {
  const ListViewPage({super.key});

  @override
  ListViewPageState createState() => ListViewPageState();
}

class ListViewPageState extends State<ListViewPage> {
  List<String> uriList = [
    'https://images.pexels.com/photos/3048526/pexels-photo-3048526.jpeg?auto=compress&cs=tinysrgb&w=800&lazy=load',
    'https://images.pexels.com/photos/1724376/pexels-photo-1724376.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/26571159/pexels-photo-26571159.jpeg?auto=compress&cs=tinysrgb&w=800&lazy=load',
    'https://images.pexels.com/photos/29656482/pexels-photo-29656482.jpeg?auto=compress&cs=tinysrgb&w=800&lazy=load',
    'https://images.pexels.com/photos/29527636/pexels-photo-29527636.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/29498899/pexels-photo-29498899.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/29053320/pexels-photo-29053320.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/5802153/pexels-photo-5802153.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/16491141/pexels-photo-16491141.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/29070157/pexels-photo-29070157.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/18721416/pexels-photo-18721416.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/29633889/pexels-photo-29633889.jpeg?auto=compress&cs=tinysrgb&w=800&lazy=load',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ListView Page'),
      ),
      body: ListView.separated(
        itemCount: 100,
        itemBuilder: (context, index) {
          String uri = uriList[index % uriList.length];
          return Container(
            height: 200,
            alignment: Alignment.center,
            child: NImage(
              uri,
              height: 200,
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
