import 'dart:convert';

import 'package:flutter/material.dart';

class DashBoardProvider with ChangeNotifier {
  bool isOpen = false;

  get popupOpen => isOpen;

  void setPopupOpen() {
    isOpen = !isOpen;
    notifyListeners();
  }
  Future<void> getdata(BuildContext context) async {
    String data = await DefaultAssetBundle.of(context).loadString("assets/files/countrylist.json.json");
    final jsonResult = jsonDecode(data);

  }
}
