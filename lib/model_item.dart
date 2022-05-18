import 'package:flutter/cupertino.dart';

class ModelItem {
  String? title;
  String? iconCustom;
  IconData? iconData;
  List<Widget>? listSubMenu;
  bool? isChecked;

  ModelItem({
    this.title,
    this.iconCustom,
    this.iconData,
    this.listSubMenu,
    this.isChecked,
  });
}
