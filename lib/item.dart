import 'dart:developer';

import 'package:drawer/model_item.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class Item extends StatefulWidget {
  final bool isCollapsed;
  final bool isSelected;
  final Color colorIcon;
  final Color colorIconSelected;
  final double fraction;
  final double offsetX;
  final double? sizeIcon;
  final ExpandableController expandableController;
  final List<ModelItem>? subMenuList;
  final Function onPress;
  final Function onHover;
  final String title;
  final IconData iconData;
  final TextStyle? textStyle;

  //final GlobalKey? globalKey;

  const Item({
    Key? key,
    required this.isCollapsed,
    required this.fraction,
    required this.offsetX,
    required this.expandableController,
    required this.onPress,
    required this.iconData,
    required this.title,
    required this.isSelected,
    required this.onHover,
    this.sizeIcon,
    this.colorIcon = Colors.grey,
    this.subMenuList,
    this.colorIconSelected = Colors.blue,
    this.textStyle,
    //this.globalKey,
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
  GlobalKey globalKey = GlobalKey();
  Widget? submenu;
  bool isUnderLineTex = false;
  bool isHoverExpanl=true;

  @override
  void initState() {
    super.initState();
    if (widget.subMenuList != null) {
      submenu = Column(
        children: widget.subMenuList!.mapIndexed((i, e) {
          return itemSubMenu(i, e);
        }).toList(),
      );
    }
    textButtonFocusNode.addListener(() {
      if (textButtonFocusNode.hasFocus) {
        _showOverlay(context, 0);
      } else {
        removeOverlay();
      }
    });
  }

  Widget itemSubMenu(int index, ModelItem element) {
    return Column(
      children: [
        SizedBox(
          height: index == 0 ? 8 : 0,
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: ButtonStyle(
              splashFactory: NoSplash.splashFactory,
              overlayColor:
                  MaterialStateColor.resolveWith((states) => Colors.black12),
            ),
            onPressed: () => element.onClick.call(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(
                      width:
                          widget.sizeIcon != null ? widget.sizeIcon! + 56 : 56),
                  Icon(
                    element.iconData,
                    color: isHoverExpanl
                        ? widget.colorIconSelected
                        : widget.colorIcon,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    element.title,
                    style: widget.textStyle ??
                        TextStyle(
                            color: isHoverExpanl
                                ? widget.colorIconSelected
                                : widget.colorIcon,
                            decoration:
                            isHoverExpanl ? TextDecoration.underline : null),
                  ),
                ],
              ),
            ),
            onHover: (value){
              setState(() {
                isHoverExpanl = value;
              });

              log('Hover');
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showOverlay(BuildContext context, int index) async {
    overlayState = Overlay.of(context)!;
    RenderBox box = globalKey.currentContext?.findRenderObject() as RenderBox;

    overlayEntry = OverlayEntry(
        maintainState: true,
        builder: (context) {
          return Positioned(
            height: box.size.height,
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 0),
              child: TextButton(
                style: ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: MaterialStateColor.resolveWith(
                      (states) => Colors.black12),
                ),
                onPressed: () => widget.onPress.call(),
                onHover: (value) => onHoverOverlay(value),
                child:
                    Container(height: 40, width: 60, color: Colors.transparent),
              ),
            ),
          );
        });

    overlayEntry2 = OverlayEntry(
        maintainState: true,
        builder: (context) {
          return Positioned(
            top: 0,
            left: 0,
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: Offset(box.size.width - 8, 0),
              child: TextButton(
                style: ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: MaterialStateColor.resolveWith(
                      (states) => Colors.black12),
                ),
                onPressed: () {},
                onHover: (value) => onHoverOverlay(value),
                child: submenu != null
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.red,
                        child: submenu,
                      )
                    : Container(),
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
    return Padding(
      padding: const EdgeInsets.only(top: 28.0),
      child: CompositedTransformTarget(
        key: globalKey,
        link: layerLink,
        child: ExpandablePanel(
          controller: widget.expandableController,
          header: TextButton(
            style: ButtonStyle(
              splashFactory: NoSplash.splashFactory,
              overlayColor:
                  MaterialStateColor.resolveWith((states) => Colors.black12),
            ),
            focusNode: textButtonFocusNode,
            onPressed: onPress,
            onHover: onHover,
            child: Container(
              decoration: BoxDecoration(
                  // color: Colors.black,
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
              child: Stack(
                children: [
                  Icon(
                    widget.iconData,
                    color: widget.isSelected
                        ? widget.colorIconSelected
                        : widget.colorIcon,
                    size: 24,
                  ),
                  _title
                ],
              ),
            ),
          ),
          expanded: submenu ?? Container(),
          collapsed: Container(),
          theme: const ExpandableThemeData(
            animationDuration: Duration(milliseconds: 500),
            hasIcon: false,
          ),
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
                widget.title,
                style: widget.textStyle ??
                    TextStyle(
                        color: widget.isSelected
                            ? widget.colorIconSelected
                            : widget.colorIcon,
                        decoration:
                            isUnderLineTex ? TextDecoration.underline : null),
              ),
            ),
          ),
        ),
      );

  void onHover(value) {
    if (widget.isCollapsed) {
      if (value) {
        textButtonFocusNode.requestFocus();
        showOverlay = true;
      }
    }
    isUnderLineTex = value;
    widget.onHover.call();
  }

  void onPress() {
    widget.onPress.call();
    setState(() {
      if (!widget.isCollapsed) {
        widget.expandableController.expanded =
            !widget.expandableController.expanded;
      }
    });
  }

  void onHoverOverlay(value) {
    if (widget.isCollapsed) {
      if (value && showOverlay) {
        textButtonFocusNode.requestFocus();
      } else {
        textButtonFocusNode.unfocus();
      }
    }
  }
}
