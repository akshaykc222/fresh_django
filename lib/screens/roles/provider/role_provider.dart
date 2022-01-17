import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fresh_new_one/screens/roles/componets/roles_list.dart';
import 'package:fresh_new_one/screens/roles/models/page_model.dart';
import 'package:fresh_new_one/screens/roles/models/page_permission.dart';
import 'package:fresh_new_one/screens/roles/models/role_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../constants.dart';
import '../../bussiness/models/bussinessmode.dart';
import 'package:collection/collection.dart';

class RoleProviderNew with ChangeNotifier {
  List<Roles> roleList = [];
  String token = "";
  bool loading = false;
  Roles? selectedDropdownvalue;
  List<PageModel> pageList = [];
  List<PagePermission> pagePermissions = [];
  String roleName = "";

  setRoleName(String name) {
    roleName = name;
    notifyListeners();
  }

  addPermissionList(PagePermission model) {
    PagePermission? p = pagePermissions
        .singleWhereOrNull((element) => element.pageName == model.pageName);
    if (p == null) {
      pagePermissions.add(model);
    } else {
      pagePermissions
          .removeWhere((element) => element.pageName == model.pageName);
      pagePermissions.add(model);
    }
    print(model.toJson());
  }

  Future<void> getToken() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();

    token = _prefs.getString("token")!;
  }

  Future<void> getPages() async {


    if(pageList.isEmpty) {
      loading = true;

      notifyListeners();
      if (token == "") {
        await getToken();
      }
      roleList.clear();
      debugPrint("======================================================");
      var header = {
        "Authorization": "Token $token",
        HttpHeaders.contentTypeHeader: 'application/json'
      };

      final uri = Uri.parse('https://$baseUrl/api/v1/pages/');

      final response = await http.get(uri, headers: header);
      debugPrint(response.body);
      Map<String, dynamic> data = json.decode(response.body);
      pageList =
      List<PageModel>.from(data["pages"].map((x) => PageModel.fromJson(x)));
      notifyListeners();
    }else{
      loading = false;
      loadingFOr=false;
      notifyListeners();
      log("not empty${roleList.length}");
    }
  }

  Future<PagePermission?> getPermissions(int id) async {
    loading = true;

    notifyListeners();
    if (token == "") {
      await getToken();
    }
    roleList.clear();
    debugPrint("======================================================");
    var header = {
      "Authorization": "Token $token",
      HttpHeaders.contentTypeHeader: 'application/json'
    };

    final uri = Uri.parse(
        'https://$baseUrl/api/v1/permisions/$id/${selectedDropdownvalue!.id}/');

    final response = await http.get(uri, headers: header);
    debugPrint(response.body);
    Map<String, dynamic> data = json.decode(response.body);

    loading = false;
    notifyListeners();
    if (data.containsKey("error")) {
      return null;
    }
    return PagePermission.fromJson(data);
  }

  Future<void> updatePermissions(BuildContext context) async {
    loading = true;

    notifyListeners();
    if (token == "") {
      await getToken();
    }
    roleList.clear();
    debugPrint("======================================================");
    var header = {
      "Authorization": "Token $token",
      HttpHeaders.contentTypeHeader: 'application/json'
    };

    final uri = Uri.parse('https://$baseUrl/api/v1/permisions/');
    bool ok=false;
    for (var element in pagePermissions) {
      final response =
          await http.post(uri, headers: header, body: jsonEncode(element));
      debugPrint(response.body);
      if (response.statusCode == HttpStatus.ok) {
        ok=true;
      }
    }
    if(ok){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Saved'),
              content: const Text('data saved successfully'),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=>const RoleList()));

                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          });
    }else{
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Failed'),
              content: const Text('data not saved '),
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

    loading = false;
    notifyListeners();
  }

  void getBusinessList(BuildContext context) async {
    loading = true;
    notifyListeners();
    if (token == "") {
      await getToken();
    }
    roleList.clear();
    debugPrint("======================================================");
    var header = {
      "Authorization": "Token $token",
      HttpHeaders.contentTypeHeader: 'application/json'
    };

    final uri = Uri.parse('https://$baseUrl/api/v1/roles/');
    debugPrint(token);
    final response = await http.get(uri, headers: header);
    debugPrint(response.body);
    if (response.statusCode == HttpStatus.ok) {
      loading = false;
      notifyListeners();
      Map<String, dynamic> data = json.decode(response.body);
      roleList = List<Roles>.from(data["roles"].map((x) => Roles.fromJson(x)));
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

  bool loadingFOr = false;
  void addBusiness(Roles model, BuildContext context, bool update) async {
    loadingFOr = true;
    notifyListeners();
    var header = {
      "Authorization": "Token $token",
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    var body = model.toJson();
    print(body);
    final uri = Uri.parse('https://$baseUrl/api/v1/roles/');
    print(uri);
    final response =
        await http.post(uri, headers: header, body: jsonEncode(body));

    if (response.statusCode == HttpStatus.created) {
      Map<String, dynamic> data = json.decode(response.body);
      selectedDropdownvalue = Roles.fromJson(data);
      loadingFOr = false;
      notifyListeners();
    } else if (response.statusCode == HttpStatus.badRequest) {
      Map<String, dynamic> data = json.decode(response.body);
      print(response.body);
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
     loadingFOr = false;
    notifyListeners();
  }

  void deletBusines(Roles model, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Delete'),
            content: const Text('This will delete this business'),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () async {
                  var header = {
                    "Authorization": "Token $token",
                    HttpHeaders.contentTypeHeader: 'application/json'
                  };

                  final uri = Uri.parse('https://$baseUrl/api/v1/roles/');
                  debugPrint(token);
                  final response = await http.delete(uri, headers: header);
                  if (response.statusCode == HttpStatus.ok) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                      'deleted',
                      style: TextStyle(color: whiteColor),
                    )));
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                      'this can not be deleted',
                      style: TextStyle(color: whiteColor),
                    )));
                    Navigator.pop(context);
                  }
                },
                child: const Text('delete'),
              ),
            ],
          );
        });
  }

  void updateBusiness(BuildContext context, Roles model) async {
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
    final uri = Uri.parse('https://$baseUrl/api/v1/roles/${model.id}/');
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
              content: const Text('role updated successfully'),
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

  void setSelctedDropDown(Roles? role) {
    selectedDropdownvalue = role;
    notifyListeners();
  }

  void setSelectedList(Roles item) {
    selectedDropdownvalue = item;
    notifyListeners();
  }
}
