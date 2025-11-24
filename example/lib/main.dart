import 'package:flutter/material.dart';
import 'package:s_gridview/s_gridview.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 's_gridview Example',
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatelessWidget {
  const ExampleHome({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = List.generate(
      12,
      (i) => Container(
        width: 100,
        height: 80,
        color: Colors.primaries[i % Colors.primaries.length],
        child: Center(
          child: Text('Item ${i + 1}'),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('s_gridview Example')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MyGridView(
          crossAxisItemCount: 3,
          itemPadding: const EdgeInsets.all(6),
          autoScrollToIndex: 2,
          children: items,
        ),
      ),
    );
  }
}
