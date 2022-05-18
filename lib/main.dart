import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:drawer/item.dart';
import 'package:drawer/model_item.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late double tempWidth;
  OverlayEntry? entry;

  late bool _isCollapsed;
  late double _currWidth, _delta, _delta1By4, _delta3by4;

  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late CurvedAnimation _curvedAnimation;

  double minWidth = 66;
  double maxWidth = 270;
  double height = double.infinity;

  @override
  void initState() {
    super.initState();

    tempWidth = maxWidth > 270 ? 270 : maxWidth;

    _currWidth = minWidth;

    _delta = tempWidth - minWidth;
    _delta1By4 = _delta * 0.2;
    _delta3by4 = _delta * 0.75;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastLinearToSlowEaseIn,
    );

    _controller.addListener(() {
      _currWidth = _widthAnimation.value;
      if (_controller.isCompleted) _isCollapsed = _currWidth == minWidth;
      setState(() {});
    });

    _isCollapsed = true;
    var endWidth = _isCollapsed ? minWidth : tempWidth;
    _animateTo(endWidth);

    data.forEach((element) {
      expandableControllerList.add(ExpandableController());
      globalKeyList.add(GlobalKey());
    });
    globalKeySelected = globalKeyList[indexSelected];
  }

  double get _fraction => (_currWidth - minWidth) / _delta;

  double get _offsetX => 48 * _fraction;

  List data = [
    ModelItem(
      title: 'Home',
      iconData: Icons.home,
      onClick: () => log('Home'),
    ),
    ModelItem(
      title: 'Music',
      iconData: Icons.music_note,
      onClick: () => log('Music'),
    ),
    ModelItem(
      title: 'Setting',
      iconData: Icons.settings,
      onClick: () => log('Setting'),
    ),
    ModelItem(
        title: 'Wifi',
        iconData: Icons.wifi,
        onClick: () => log('Wifi'),
        listSubMenu: [
          ModelItem(
            title: 'Wifi 1',
            iconData: Icons.wifi_lock,
            onClick: () => log('Wifi 1'),
          ),
          ModelItem(
            title: 'Wifi 2',
            iconData: Icons.wifi_find,
            onClick: () => log('Wifi 2'),
          ),
        ]),
    ModelItem(
      title: 'Account',
      iconData: Icons.account_box,
      onClick: () => log('Account'),
    ),
  ];
  int indexSelected = 0;
  late GlobalKey globalKeySelected;
  late RenderBox box;
  late Offset position;

  double heightSelected = 24;
  double offSetY = 0;

  List<ExpandableController> expandableControllerList = [];
  List<GlobalKey> globalKeyList = [];

  Widget get drawer => Container(
        height: height,
        width: _currWidth,
        color: Colors.black54,
        child: Stack(
          children: [
            // Selected(
            //     height: heightSelected,
            //     offsetY: offSetY,
            //     color: Colors.black,
            //     duration: const Duration(milliseconds: 300),
            //     curve: Curves.fastLinearToSlowEaseIn),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data
                  .mapIndexed(
                    (i, e) => item(i, e),
                  )
                  .toList(),
            ),
          ],
        ),
      );

  Widget item(int index, ModelItem element) {
    return Item(
      isCollapsed: _isCollapsed,
      fraction: _fraction,
      offsetX: _offsetX,
      expandableController: expandableControllerList[index],
      //globalKey: globalKeyList[index],
      isSelected: indexSelected == index,
      iconData: element.iconData,
      title: element.title,
      subMenuList: element.listSubMenu,
      onPress: () => element.onClick.call(),
      onHover: () {
        setState(() {
          indexSelected = index;
        });
      },
    );
  }

  void setPositionSelected(int index) {
    // indexSelected = index;
    // globalKeySelected = globalKeyList[index];
    // box =
    // globalKeySelected.currentContext?.findRenderObject() as RenderBox;
    // position = box.localToGlobal(Offset.zero);
    // heightSelected = box.size.height;
    // offSetY = position.dy - 12;
  }

  void _animateTo(double endWidth) {
    _widthAnimation = Tween<double>(
      begin: _currWidth,
      end: endWidth,
    ).animate(_curvedAnimation);
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          drawer,
          Expanded(
              child: Container(
            child: Center(
              child: TextButton(
                child: Text("CLOSE"),
                onPressed: () {
                  _isCollapsed = !_isCollapsed;
                  var endWidth = _isCollapsed ? minWidth : tempWidth;
                  for (var element in expandableControllerList) {
                    element.expanded = false;
                  }
                  _animateTo(endWidth);
                },
              ),
            ),
          ))
        ],
      ),
    );
  }
}
