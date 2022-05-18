import 'package:flutter/cupertino.dart';

class ModelItem {
  String title;
  String? iconCustom;
  IconData iconData;
  List<ModelItem>? listSubMenu;
  bool? isChecked =false;
  Function onClick;

  ModelItem({
    required this.title,
    required this.onClick,
    required this.iconData,
    this.iconCustom,
    this.listSubMenu,
    this.isChecked,
  });
}
