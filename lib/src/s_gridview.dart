import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';

/// A grid-like, scrollable widget that lays out arbitrary child widgets in
/// rows (or columns when horizontal) with a configurable number of items per
/// cross-axis. The widget provides optional index-based auto-scrolling and
/// simple visual scroll indicators.
///
/// Typical usage:
///
/// ```dart
/// SGridView(
///   crossAxisItemCount: 3,
///   children: myTiles,
///   controller: myController,
/// )
/// ```
class SGridView extends StatefulWidget {
  /// Number of children to place on the cross axis (columns for a vertical
  /// layout, rows for a horizontal layout). Must be greater than zero.
  final int crossAxisItemCount;

  /// The list of widgets displayed by the grid. Widgets are placed in order
  /// and split into rows/columns according to [crossAxisItemCount]. This list
  /// must not be null.
  final List<Widget> children;

  /// The main scroll direction of the grid. Defaults to [Axis.vertical]. If
  /// set to [Axis.horizontal] the grid will scroll horizontally and the small
  /// visual indicators will appear on the left/right edges.
  final Axis mainAxisDirection;

  /// Padding to apply around each child element.
  final EdgeInsetsGeometry itemPadding;

  /// External controller used for programmatic index-based scrolling. If not
  /// provided, `SGridView` will create and manage a controller internally.
  final IndexedScrollController? controller;

  /// Whether to show the simple top/bottom (or left/right for horizontal)
  /// scroll indicators. Defaults to `true`.
  final bool showScrollIndicators;

  /// Color used for the gradient and icon of the scroll indicators. If null
  /// a sensible default (yellow) will be used.
  final Color? indicatorColor;

  /// Optional index to auto-scroll to when the widget first builds. The
  /// value will be clamped to the valid child range; the widget computes the
  /// corresponding row and instructs the inner list to scroll to that row.
  final int? autoScrollToIndex;

  /// Creates a [SGridView].
  const SGridView({
    super.key,
    this.crossAxisItemCount = 2,
    required this.children,
    this.mainAxisDirection = Axis.vertical,
    this.itemPadding = EdgeInsets.zero,
    this.controller,
    this.showScrollIndicators = true,
    this.indicatorColor,
    this.autoScrollToIndex,
  }) : assert(crossAxisItemCount > 0,
            'crossAxisItemCount must be greater than zero');

  @override
  State<SGridView> createState() => _SGridViewState();
}

class _SGridViewState extends State<SGridView> {
  late IndexedScrollController _scrollController;
  late bool _ownsController;
  bool _showTopIndicator = false;
  bool _showBottomIndicator = true;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? IndexedScrollController();
    _ownsController = widget.controller == null;
    _scrollController.controller.addListener(updateScrollIndicators);

    // Initial check for indicators
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateScrollIndicators();
    });
  }

  @override
  void didUpdateWidget(SGridView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller changes
    if (widget.controller != oldWidget.controller) {
      // Remove listener from old controller
      _scrollController.controller.removeListener(updateScrollIndicators);

      // Dispose previously owned controller when handing over to a new one
      if (_ownsController) {
        _scrollController.controller.dispose();
      }

      // Update to new controller instance
      _scrollController = widget.controller ?? IndexedScrollController();
      _ownsController = widget.controller == null;
      _scrollController.controller.addListener(updateScrollIndicators);

      // Update indicators for new controller
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateScrollIndicators();
      });
    } else if (oldWidget.children.length != widget.children.length ||
        oldWidget.crossAxisItemCount != widget.crossAxisItemCount) {
      // Schedule an indicator refresh when the grid content changes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateScrollIndicators();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.controller.removeListener(updateScrollIndicators);
    if (_ownsController) {
      _scrollController.controller.dispose();
    }
    super.dispose();
  }

  void updateScrollIndicators() {
    if (!mounted || !_scrollController.controller.hasClients) return;

    final bool showTop = _scrollController.controller.offset > 20;
    final bool showBottom = _scrollController.controller.offset <
        (_scrollController.controller.position.maxScrollExtent - 20);

    if (showTop != _showTopIndicator || showBottom != _showBottomIndicator) {
      setState(() {
        _showTopIndicator = showTop;
        _showBottomIndicator = showBottom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<List<Widget>> gridView = [];
    if (widget.children.isNotEmpty) {
      gridView = widget.children.splitInChunks(widget.crossAxisItemCount);
    }

    int? targetRowIndex;
    if (widget.autoScrollToIndex != null && gridView.isNotEmpty) {
      final int rawIndex = widget.autoScrollToIndex!;
      final int clampedIndex = rawIndex < 0
          ? 0
          : rawIndex >= widget.children.length
              ? widget.children.length - 1
              : rawIndex;
      final int derivedRow = clampedIndex ~/ widget.crossAxisItemCount;
      targetRowIndex =
          derivedRow >= gridView.length ? gridView.length - 1 : derivedRow;
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topLeft,
      children: [
        IndexScrollListViewBuilder(
          controller: _scrollController,
          scrollDirection: widget.mainAxisDirection,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: Pad.zero,
          indexToScrollTo: targetRowIndex,
          itemCount: gridView.length,
          itemBuilder: (context, i) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: _CrossAxisItems(
                axisDirection: widget.mainAxisDirection,
                padding: widget.itemPadding,
                children: gridView[i],
              ),
            );
          },
        ),

        // Scroll indicators
        if (widget.showScrollIndicators &&
            widget.children.length > widget.crossAxisItemCount * 3)
          ...buildScrollIndicators(),
      ],
    );
  }

  List<Widget> buildScrollIndicators() {
    final Color indicatorColor =
        widget.indicatorColor ?? Colors.yellow.shade600;
    final bool isVertical = widget.mainAxisDirection == Axis.vertical;
    return [
      // Top/left indicator
      if (_showTopIndicator)
        Positioned(
          top: isVertical ? -5 : 0,
          left: isVertical ? 0 : -5,
          right: isVertical ? 0 : null,
          bottom: isVertical ? null : 0,
          child: Container(
            height: isVertical ? 24 : null,
            width: isVertical ? null : 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin:
                    isVertical ? Alignment.bottomCenter : Alignment.centerRight,
                end: isVertical ? Alignment.topCenter : Alignment.centerLeft,
                colors: [
                  Colors.transparent,
                  indicatorColor.withAlpha(50),
                ],
              ),
            ),
            child: Icon(
              isVertical ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_left,
              color: indicatorColor,
              size: 24,
            ),
          ),
        ),

      // Bottom/right indicator
      if (_showBottomIndicator)
        Positioned(
          bottom: isVertical ? -5 : 0,
          left: isVertical ? 0 : null,
          right: isVertical ? 0 : -5,
          top: isVertical ? null : 0,
          child: Container(
            height: isVertical ? 24 : null,
            width: isVertical ? null : 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
                end:
                    isVertical ? Alignment.bottomCenter : Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  indicatorColor.withAlpha(50),
                ],
              ),
            ),
            child: Icon(
              isVertical
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_right,
              color: indicatorColor,
              size: 34,
            ),
          ),
        ),
    ];
  }
}

//********************************************* */

class _CrossAxisItems extends StatelessWidget {
  final Axis axisDirection;
  final EdgeInsetsGeometry padding;
  final List<Widget> children;

  const _CrossAxisItems({
    required this.children,
    this.axisDirection = Axis.vertical,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction:
          axisDirection == Axis.vertical ? Axis.horizontal : Axis.vertical,
      alignment: WrapAlignment.spaceEvenly,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < children.length; i++)
          Padding(
            padding: padding,
            child: children[i],
          ),
      ],
    );
  }
}

//************************************************ */
