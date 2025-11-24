import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_gridview/s_gridview.dart';

void main() {
  testWidgets('MyGridView builds and shows items', (WidgetTester tester) async {
    final items = List.generate(
      6,
      (i) => Container(
        width: 100,
        height: 80,
        color: Colors.blue,
        child: Center(child: Text('Item ${i + 1}')),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyGridView(
            crossAxisItemCount: 2,
            itemPadding: const EdgeInsets.all(4),
            children: items,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that at least one of the generated text widgets is present in the widget tree
    expect(find.text('Item 1'), findsOneWidget);
  });
}
