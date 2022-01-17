import 'dart:convert';
import 'dart:io';

import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fresh_new_one/constants.dart';
import 'package:fresh_new_one/screens/Desingation/models/designation_model.dart';
import 'package:fresh_new_one/screens/bussiness/body.dart';
import 'package:fresh_new_one/screens/tax/model/taxmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class TaxProvider with ChangeNotifier {
  bool loading = false;
  bool update = false;
  List<TaxModel> businessList = [];
  List<TaxModel> tempList = [];

  String token = "";
  TaxProvider() {
    if (token == "") {
      getToken();
    }
  }
  void initTemp() {
    if (tempList.isEmpty) {
      tempList = businessList;
      debugPrint(businessList.length.toString());
      notifyListeners();
    }
  }

  void retainList() {
    businessList.clear();
    businessList = tempList;
    debugPrint(businessList.length.toString());
    notifyListeners();
  }

  void searchBusiness(String s) {
    initTemp();
    List<TaxModel> searchList = [];
    for (int i = 0; i < tempList.length; i++) {
      TaxModel m = tempList[i];
      if (m.shortName.contains(s)) {
        searchList.add(m);
      }
    }
    businessList.clear();
    businessList = searchList;
    notifyListeners();
  }

  Future<TaxModel?> getTaxModelWIthId(int id) async {
    if (token == "") {
      await getToken();
    }

    debugPrint("======================================================");
    var header = {
      "Authorization": "Token $token",
      HttpHeaders.contentTypeHeader: 'application/json'
    };

    final uri = Uri.parse('https://$baseUrl/api/v1/tax/$id/');
    debugPrint(token);
    final response = await http.get(uri, headers: header);
    debugPrint(response.body);
    if (response.statusCode == HttpStatus.ok) {
      Map<String, dynamic> data = json.decode(response.body);
      return TaxModel.fromJson(data);
    }
  }

  void getBusinessList(BuildContext context) async {
    loading = true;
    notifyListeners();
    if (token == "") {
      await getToken();
    }
    businessList.clear();
    debugPrint("======================================================");
    var header = {
      "Authorization": "Token $token",
      HttpHeaders.contentTypeHeader: 'application/json'
    };

    final uri = Uri.parse('https://$baseUrl/api/v1/tax/');
    debugPrint(token);
    final response = await http.get(uri, headers: header);
    debugPrint(response.body);
    if (response.statusCode == HttpStatus.ok) {
      loading = false;
      notifyListeners();
      Map<String, dynamic> data = json.decode(response.body);
      businessList =
          List<TaxModel>.from(data["tax"].map((x) => TaxModel.fromJson(x)));
      notifyListeners();
    } else if (response.statusCode == HttpStatus.badRequest) {
      loading = false;
      notifyListeners();
      Map<String, dynamic> data = json.decode(response.body);
      try {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('Failed'),
                content: Text(data['error']),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            });
      } catch (e) {
        loading = false;
        notifyListeners();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('Failed'),
                content: const Text(something),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            });
      }
    }
    //notifyListeners();
  }

  Future<void> getToken() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();

    token = _prefs.getString("token")!;
  }

  void addBusiness(
    TaxModel model,
    BuildContext context,
  ) async {
    if (token == "") {
      await getToken();
    }
    loading = true;
    notifyListeners();
    var header = {
      "Authorization": "Token $token",
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    var body = model.toJson();
    print(body);
    final uri = Uri.parse('https://$baseUrl/api/v1/tax/');
    print(uri);
    final response =
        await http.post(uri, headers: header, body: jsonEncode(body));
    loading = false;
    print(response.body);
    notifyListeners();
    if (response.statusCode == HttpStatus.created) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Added'),
              content: const Text('Tax added successfully'),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    getBusinessList(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    // Navigator.pop(context);
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          });
    } else if (response.statusCode == HttpStatus.badRequest) {
      Map<String, dynamic> data = json.decode(response.body);

      try {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('Failed'),
                content: Text(jsonEncode(data)),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            });
      } catch (e) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('Faild'),
                content: const Text(something),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            });
      }
    }
  }

  void deletBusines(TaxModel model, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Delete'),
            content: const Text('This will delete this tax'),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () async {
                  loading = true;
                  notifyListeners();
                  if (token == "") {
                    await getToken();
                  }
                  businessList.clear();
                  debugPrint(
                      "======================================================");
                  var header = {
                    "Authorization": "Token $token",
                    HttpHeaders.contentTypeHeader: 'application/json'
                  };

                  final uri = Uri.parse('https://$baseUrl/api/v1/tax/');
                  debugPrint(token);
                  final response = await http.delete(uri, headers: header);
                  debugPrint(response.body);
                  getBusinessList(context);
                  //notifyListeners();

                  Navigator.pop(context);
                },
                child: const Text('delete'),
              ),
            ],
          );
        });
  }

  TaxModel? selectedBusiness;

  void setDropDownValue(TaxModel? value) {
    selectedBusiness = value;
    notifyListeners();
  }

  void setDropDownValueForUpdate(int value) {
    selectedBusiness =
        businessList.firstWhereOrNull((element) => element.id == value);
    print("setting value $selectedBusiness");
    notifyListeners();
  }

  List<DesingationModel> selectedBussinessList = [];

  TaxModel? updateModel;
  void updateNavigate(BuildContext context, TaxModel model) {
    update = true;
    updateModel = model;
    debugPrint(updateModel!.toJson().toString());
    notifyListeners();
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const Bussiness()));
  }

  void updateBusiness(BuildContext context, TaxModel model) async {
    loading = true;
    notifyListeners();
    if (token == "") {
      await getToken();
    }
    var header = {
      "Authorization": "Token $token",
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    var body = model.toJson();
    print(body);
    final uri = Uri.parse('https://$baseUrl/api/v1/tax/${updateModel!.id}/');
    print(uri);
    final response =
        await http.put(uri, headers: header, body: jsonEncode(body));

    if (response.statusCode == HttpStatus.ok) {
      loading = false;
      notifyListeners();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Updated'),
              content: const Text('Tax updated successfully'),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    getBusinessList(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          });
    } else if (response.statusCode == HttpStatus.badRequest) {
      loading = false;
      notifyListeners();
      Map<String, dynamic> data = json.decode(response.body);
      try {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('Failed'),
                content: Text(data['error']),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigator.pushReplacementNamed(context, business);
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            });
      } catch (e) {
        loading = false;
        notifyListeners();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('Failed'),
                content: const Text('Can not delete tax'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            });
      }
    }
  }

  void setUnUpdate() {
    update = false;
    updateModel = null;
    notifyListeners();
  }
}
