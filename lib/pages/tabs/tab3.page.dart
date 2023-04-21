import 'package:flutter/material.dart';

class Tab3Page extends StatelessWidget {
  const Tab3Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hello Tab 2'), elevation: 3, actions: [
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
      body: const Text('Hello 2'),
    );
  }
}
