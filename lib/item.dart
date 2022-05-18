import 'dart:developer';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class Item extends StatefulWidget {
  final bool isCollapsed;
  final double fraction;
  final double offsetX;
  final ExpandableController expandableController;
  final Function onPress;
  final double? sizeIcon;
  final String? title;
  final Color? colorIcon;
  final IconData? iconData;
  final GlobalKey? globalKey;


  const Item({
    Key? key,
    required this.isCollapsed,
    required this.fraction,
    required this.offsetX,
    required this.expandableController,
    required this.onPress,
    this.sizeIcon,
    this.title,
    this.colorIcon,
    this.iconData, this.globalKey,
  }) : super(key: key);

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  final layerLink = LayerLink();
  final textButtonFocusNode = FocusNode();
  OverlayState? overlayState;
  OverlayEntry? overlayEntry;
  OverlayEntry? overlayEntry2;
  bool showOverlay = false;

  List<Widget> widgets = [
    Container(height: 40, width: 60, color: Colors.transparent),
    Container(
      height: 300,
      width: 300,
      color: Colors.green,
      child: TextButton(
        child: Text('Click Me'),
        onPressed: () {
          print('Clicked');
        },
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    textButtonFocusNode.addListener(() {
      if (textButtonFocusNode.hasFocus) {
        _showOverlay(context, 0);
      } else {
        removeOverlay();
      }
    });
  }

  void _showOverlay(BuildContext context, int index) async {
    overlayState = Overlay.of(context)!;
    RenderBox box = widget.globalKey?.currentContext?.findRenderObject() as RenderBox;

    overlayEntry = OverlayEntry(
        maintainState: true,
        builder: (context) {
          return Positioned(
            height: box.size.height,
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, 0),
              child: TextButton(
                onPressed: () {widget.onPress.call();},
                onHover: (val) {
                  if (widget.isCollapsed) {
                    if (val && showOverlay) {
                      textButtonFocusNode.requestFocus();
                    } else {
                      textButtonFocusNode.unfocus();
                    }
                  }
                },
                child: widgets[index],
              ),
            ),
          );
        });

    overlayEntry2 = OverlayEntry(
        maintainState: true,
        builder: (context) {
          return Positioned(
            height: box.size.height,
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: Offset(box.size.width, 0),
              child: TextButton(
                onPressed: () {},
                onHover: (val) {
                  if (val && showOverlay) {
                    textButtonFocusNode.requestFocus();
                  } else {
                    textButtonFocusNode.unfocus();
                  }
                },
                child: widgets[index + 1],
              ),
            ),
          );
        });

    // overlayState!.insert(overlayEntry!);
    overlayState!.insertAll([overlayEntry!, overlayEntry2!]);
  }

  void removeOverlay() {
    overlayEntry!.remove();
    overlayEntry2!.remove();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      key: widget.globalKey,
      link: layerLink,
      child: ExpandablePanel(
        controller: widget.expandableController,
        header: TextButton(
          focusNode: textButtonFocusNode,
          onPressed: () {
            widget.onPress.call();
            setState(() {
              if (!widget.isCollapsed) {
                widget.expandableController.expanded =
                    !widget.expandableController.expanded;
              }
            });
          },
          onHover: (value) {
            if (widget.isCollapsed) {
              if (value) {
                textButtonFocusNode.requestFocus();
                showOverlay = true;
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
             // color: Colors.black,
              borderRadius: BorderRadius.circular(10)
            ),
            padding: const EdgeInsets.only(left: 12,top: 12,bottom: 12),
            child: Stack(
              children: [
                Icon(
                  Icons.home,
                  size: 24,
                ),
                _title
              ],
            ),
          ),
        ),
        expanded: Container(width: 100, height: 50, color: Colors.red),
        collapsed: Container(),
        theme: const ExpandableThemeData(
          animationDuration: Duration(milliseconds: 500),
          hasIcon: false,
          bodyAlignment: ExpandablePanelBodyAlignment.right,
        ),
      ),
    );
  }

  Widget get _title => Opacity(
        opacity: widget.fraction,
        child: Transform.translate(
          offset: Offset(widget.offsetX, 4),
          child: Transform.scale(
            scale: widget.fraction,
            child: SizedBox(
              width: double.infinity,
              child: Text(
                "HElllo",
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        ),
      );
}
