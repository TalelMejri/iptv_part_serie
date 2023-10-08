import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../resources/color_manager.dart';
import '../resources/font_manager.dart';
import '../resources/styles_manager.dart';

class FilterWidget extends StatefulWidget {
  final double marginVertical;
  final double marginHorizontal;
  final void Function()? toggleMenu;

  // FocusNode filterBtnNode;
  final bool isFocused;

  const FilterWidget({
    required this.marginVertical,
    required this.marginHorizontal,
    this.toggleMenu,
    // required this.filterBtnNode,
    this.isFocused = false,
    Key? key,
  }) : super(key: key);

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late int _selectedItemIndex;

  @override
  void initState() {
    _selectedItemIndex = -1;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // focusNode: widget.filterBtnNode,
      onTap: widget.toggleMenu,
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          width: Get.width * .17,
          height: Get.height * .1,
          margin: EdgeInsets.only(
            top: widget.marginVertical,
            right: widget.marginHorizontal,
          ),
         
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "FILTER",
                style: getMediumStyle(
                  color: widget.isFocused
                      ? ColorManager.selectedNavBarItem
                      : ColorManager.white,
                  fontSize: widget.isFocused ? FontSize.s22 : FontSize.s18,
                  isUnderline: widget.isFocused,
                ),
              ),
              Icon(
                Icons.filter_list_rounded,
                color: widget.isFocused
                    ? ColorManager.selectedNavBarItem
                    : ColorManager.white,
                size: widget.isFocused ? FontSize.s45 : FontSize.s40,
                shadows: widget.isFocused
                    ? [
                        BoxShadow(
                          color: ColorManager.selectedNavBarItem,
                          spreadRadius: 10,
                          blurRadius: 20,
                          offset: const Offset(0, 0),
                        ),
                      ]
                    : null,
              )
            ],
          ),
        ),
      ),
    );
  }
}
