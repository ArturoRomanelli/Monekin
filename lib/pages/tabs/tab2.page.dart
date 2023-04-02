import 'package:finlytics/pages/tabs/animations/fadeScaleAtStart.dart';
import 'package:flutter/material.dart';

class Tab2Page extends StatefulWidget {
  const Tab2Page({Key? key}) : super(key: key);

  @override
  State<Tab2Page> createState() => _Tab2PageState();
}

class _Tab2PageState extends State<Tab2Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Hello Tab 2"),
          elevation: 3,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Do something
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Do something
              },
            ),
          ]),
      body: FadeScaleAtStart(
        child: Center(
          child: ListView.builder(
            itemCount: 40,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text('Title $index'),
                subtitle: Text('Subtitle $index'),
                leading: Icon(Icons.join_full_rounded),
                onTap: () {
                  print('Final value $index');
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
