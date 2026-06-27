library swipe_button_widget;

import 'package:flutter/material.dart';

class SwipeButtonWidget extends StatefulWidget {
  /// AcceptPointTransition from 0 to 1
  ///
  /// rightChildren & leftChildren is Stack
  const SwipeButtonWidget({
    Key? key,
    this.childBeforeSwipe = const Icon(Icons.arrow_forward_ios),
    this.childAfterSwiped = const Icon(Icons.arrow_back_ios),
    this.height,
    this.width,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.all(0),
    this.colorBeforeSwipe = Colors.green,
    this.colorAfterSwiped = Colors.red,
    this.boxShadow = const [
      BoxShadow(
        color: Colors.black54,
        blurRadius: 6,
        offset: Offset(0, 4),
      ),
    ],
    this.borderRadius,
    this.duration = const Duration(milliseconds: 50),
    this.constraints,
    this.rightChildren = const [],
    this.leftChildren = const [],
    required this.onHorizontalDragUpdate,
    required this.onHorizontalDragRight,
    required this.onHorizontalDragleft,
    this.acceptPoitTransition = 0.5,
  })  : assert(acceptPoitTransition <= 1 && acceptPoitTransition >= 0),
        super(key: key);
  final Widget childBeforeSwipe, childAfterSwiped;
  final double? height, width;
  final EdgeInsetsGeometry margin, padding;
  final Color? colorBeforeSwipe, colorAfterSwiped;
  final List<BoxShadow> boxShadow;
  final BorderRadiusGeometry? borderRadius;
  final Duration duration;
  final BoxConstraints? constraints;
  final List<Widget> rightChildren;
  final List<Widget> leftChildren;
  final double acceptPoitTransition;
  final void Function(DragUpdateDetails details) onHorizontalDragUpdate;
  final Future<bool> Function(DragEndDetails details) onHorizontalDragRight;
  final Future<bool> Function(DragEndDetails details) onHorizontalDragleft;
  @override
  _SwipeButtonWidgetStateful createState() => _SwipeButtonWidgetStateful();
}

class _SwipeButtonWidgetStateful extends State<SwipeButtonWidget> {
  double xOffset = 0;
  double fullWidth = 0;
  double get startPoint => 0;
  double get widthWithoutSwapButton =>
      fullWidth == 0 ? 1 : fullWidth - sizeSwapButton.value.width;
  bool get isLeftSide => precentage <= widget.acceptPoitTransition;
  bool get isRightSide => !isLeftSide;
  double perviousPosition = 0;

  /// From 0 to 1
  double get precentage => xOffset / widthWithoutSwapButton;
  ValueNotifier<Size> sizeSwapButton = ValueNotifier<Size>(const Size(0, 0));
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      height: widget.height,
      width: widget.width,
      constraints: widget.constraints,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: isLeftSide ? widget.colorBeforeSwipe : widget.colorAfterSwiped,
        borderRadius: widget.borderRadius,
        boxShadow: widget.boxShadow,
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        fullWidth = constraints.maxWidth;
        return Stack(
          children: [
            ...isLeftSide ? widget.leftChildren : widget.rightChildren,
            AnimatedContainer(
              duration: widget.duration,
              transform: Matrix4.translationValues(xOffset, 0, 0),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onHorizontalDragUpdate: (e) {
                  if (e.globalPosition.dx <= widthWithoutSwapButton) {
                    xOffset = e.globalPosition.dx;
                    widget.onHorizontalDragUpdate(e);
                    setState(() {});
                  }
                },
                onHorizontalDragEnd: (e) async {
                  bool isActive = false;
                  if (isLeftSide) {
                    if (perviousPosition != startPoint) {
                      isActive = await widget.onHorizontalDragleft(e);
                      isActive ? moveToLeft() : moveToright();
                    } else {
                      moveToLeft();
                    }
                  } else {
                    if (perviousPosition != widthWithoutSwapButton) {
                      isActive = await widget.onHorizontalDragRight(e);
                      isActive ? moveToright() : moveToLeft();
                    } else {
                      moveToright();
                    }
                  }
                  perviousPosition = xOffset;
                  setState(() {});
                },
                child: SizeTrackingWidget(
                  child: isLeftSide
                      ? widget.childBeforeSwipe
                      : widget.childAfterSwiped,
                  sizeValueNotifier: sizeSwapButton,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void moveToright() {
    xOffset = fullWidth - sizeSwapButton.value.width;
  }

  void moveToLeft() {
    xOffset = startPoint;
  }
}

class SizeTrackingWidget extends StatefulWidget {
  final Widget child;
  final ValueNotifier<Size> sizeValueNotifier;
  const SizeTrackingWidget(
      {Key? key, required this.sizeValueNotifier, required this.child})
      : super(key: key);
  @override
  _SizeTrackingWidgetState createState() => _SizeTrackingWidgetState();
}

class _SizeTrackingWidgetState extends State<SizeTrackingWidget> {
  late final RenderBox renderBox;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _getSize();
    });
  }

  _getSize() {
    renderBox = context.findRenderObject() as RenderBox;
    widget.sizeValueNotifier.value = renderBox.size;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      builder: (BuildContext context, Size value, Widget? child) {
        return widget.child;
      },
      valueListenable: widget.sizeValueNotifier,
    );
  }

  @override
  void dispose() {
    widget.sizeValueNotifier.dispose();
    super.dispose();
  }
}
