# s_gridview

A lightweight, customizable grid-like Flutter widget with index-based scrolling and optional scroll indicators.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  s_gridview: ^1.0.0
```

For local development, point to the package path:

```yaml
dependencies:
  s_gridview:
    path: ../
```

## Usage example

```dart
import 'package:flutter/material.dart';
import 'package:s_gridview/s_gridview.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final IndexedScrollController _controller = IndexedScrollController();
  int _crossAxisItemCount = 3;
  bool _showScrollIndicators = true;
  Axis _direction = Axis.vertical;
  Color? _indicatorColor;
  int? _autoScrollToIndex;

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      30,
      (i) => Container(
        width: 100,
        height: 80,
        color: Colors.primaries[i % Colors.primaries.length],
        child: Center(child: Text('Item ${i + 1}')),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('s_gridview example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _crossAxisItemCount = (_crossAxisItemCount % 5) + 1),
                  child: Text('Columns: $_crossAxisItemCount'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => setState(() => _direction = _direction == Axis.vertical ? Axis.horizontal : Axis.vertical),
                  child: Text(_direction == Axis.vertical ? 'Vertical' : 'Horizontal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => setState(() => _showScrollIndicators = !_showScrollIndicators),
                  child: Text(_showScrollIndicators ? 'Hide Indicators' : 'Show Indicators'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    // Programmatic scroll via controller
                    await _controller.scrollToIndex(20, alignmentOverride: 0.3);
                  },
                  child: const Text('Scroll to #21'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SGridView(
              controller: _controller,
              crossAxisItemCount: _crossAxisItemCount,
              mainAxisDirection: _direction,
              itemPadding: const EdgeInsets.all(6),
              autoScrollToIndex: _autoScrollToIndex,
              showScrollIndicators: _showScrollIndicators,
              indicatorColor: _indicatorColor,
              children: items,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            // Example auto-scroll: set to an index that demonstrates clamping
            _autoScrollToIndex = 50; // will clamp to max index
          });
        },
        label: const Text('Auto scroll out of bounds'),
        icon: const Icon(Icons.arrow_downward),
      ),
    );
  }
}
```

## Features

- Index-based scrolling with `IndexedScrollController` (via `indexscroll_listview_builder`). You can call `controller.scrollToIndex(target, alignmentOverride: 0.0..1.0)` to jump/animate programmatically.
- Built-in top and bottom (or left/right for horizontal lists) scroll indicators. They appear only when the list is long enough (more than `crossAxisItemCount * 3` children) and when the content is scrollable in that direction.
- Inject your own `IndexedScrollController` for programmatic control, or let `SGridView` own its controller automatically.
- `autoScrollToIndex` lets you set an auto-scroll target when the widget first builds — it will be clamped to the valid range automatically.
- Configure layout with `crossAxisItemCount`, `mainAxisDirection` (vertical/horizontal), and `itemPadding` to control item spacing.
- Customize indicator color with `indicatorColor` and show/hide with `showScrollIndicators`.

## Example App

The `example/` directory contains an interactive Flutter app showcasing all features, including programmatic scrolling, auto-scroll clamping, controller injection, layout configuration, and indicator customization. Open the `example` folder and run `flutter run`.

## Quick Code Snippets

Programmatic scrolling with an external controller:

```dart
final controller = IndexedScrollController();

SGridView(
  controller: controller,
  crossAxisItemCount: 3,
  children: items,
);

// Later (e.g. button press):
await controller.scrollToIndex(75, alignmentOverride: 0.3);
```

Horizontal layout example:

```dart
SGridView(
  mainAxisDirection: Axis.horizontal,
  crossAxisItemCount: 2,
  children: items,
);
```

## License

This package is licensed under the MIT License — see the `LICENSE` file for details.

## Repository

https://github.com/SoundSliced/s_gridview
