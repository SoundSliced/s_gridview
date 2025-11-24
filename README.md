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

class Example extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      12,
      (i) => Container(
        width: 100,
        height: 80,
        color: Colors.primaries[i % Colors.primaries.length],
        child: Center(child: Text('Item ${i + 1}')),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('s_gridview example')),
      body: MyGridView(
        crossAxisItemCount: 3,
        children: items,
        itemPadding: const EdgeInsets.all(6),
        showScrollIndicators: true,
      ),
    );
  }
}
```

## Features

- Index-based scrolling with `IndexedScrollController` (via `indexscroll_listview_builder`).
- Built-in scroll indicators for long lists.
- Inject your own controller for precise scroll control.
- Custom cross-axis item counts and padding control.

## Example App

The `example/` directory contains a minimal Flutter app demonstrating basic usage. Run it by opening the `example` folder and using `flutter run`.

## License

This package is licensed under the MIT License — see the `LICENSE` file for details.

## Repository

https://github.com/SoundSliced/s_gridview
