import 'package:flutter/material.dart';
class DashBoardMenu {
  String key;
  String value;
  String image;

  DashBoardMenu({required this.key,required this.value,required this.image
    });

 factory DashBoardMenu.fromJson(Map<String, dynamic> json) {
    return DashBoardMenu(
      key :json['key'],
      value :json['value'], image: '',

    );
  }


}