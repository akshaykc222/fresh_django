import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fresh_new_one/screens/products/model/product_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';

class ProductProvider with ChangeNotifier {
  bool loading = false;
  bool update = false;
  List<ProductModel> productList = [];
  List<ProductModel> tempList = [];
  List<ProductModel> selectedListForAppoint = [];
  List<ProductModel> selectedListForAppointGet = [];
  String token = "";
  double totalPrice=0.0;
  ProductProvider() {
    if (token == "") {
      getToken();
    }
  }
  emptyAppointmentList(){
    totalPrice=0.0;
    selectedListForAppoint.clear();
    notifyListeners();
  }
  calculateTotalPriceForUpdate() {
   if(selectedListForAppoint.isNotEmpty){
     for (var element in selectedListForAppoint) {
       totalPrice=totalPrice+ element.mrp;
     }}
   notifyListeners();
  }
  selectAppointmentProduct(ProductModel model) {
    print("====addinf"+selectedListForAppoint.length.toString());
    ProductModel? modelHas=selectedListForAppoint.firstWhereOrNull((ele)=>ele.id==model.id);
    if (modelHas==null) {
      selectedListForAppoint.add(model);
      totalPrice=totalPrice+model.mrp;
    }else{
      totalPrice=totalPrice-model.mrp;
      print(totalPrice.toString());
      selectedListForAppoint.removeWhere((element) => element.id==model.id);

    }
    isSelectedProduct(model);
    notifyListeners();
  }


  bool isSelectedProduct(ProductModel model) {
    ProductModel? modelHas=selectedListForAppoint.firstWhereOrNull((ele)=>ele.id==model.id);

    if (modelHas==null) {
      return false;
    }else{
      return true;
    }

  }

    void initTemp() {
      if (tempList.isEmpty) {
        tempList = productList;
        debugPrint(productList.length.toString());
        notifyListeners();
      }
    }

    void retainList() {
      productList.clear();
      productList = tempList;
      debugPrint(productList.length.toString());
      notifyListeners();
    }

    void search(String s) {
      initTemp();
      List<ProductModel> searchList = [];
      for (int i = 0; i < tempList.length; i++) {
        ProductModel m = tempList[i];
        if (m.name.contains(s)) {
          searchList.add(m);
        }
      }
      productList.clear();
      productList = searchList;
      notifyListeners();
    }
  void gettemsWithListForUpdate({required BuildContext context, required List<int> id}) async {

      print('getting');
      loading = true;
      notifyListeners();
      if (token == "") {
        await getToken();
      }
      selectedListForAppoint.clear();
      debugPrint("=============================sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfds=========================");
      var header = {
        "Authorization": "Token $token",
        HttpHeaders.contentTypeHeader: 'application/json'
      };
      for (var element in id)  {
        final uri;


        uri = Uri.parse('https://$baseUrl/api/v1/products/$element/$element/');

        debugPrint(token);
        final response = await http.get(uri, headers: header);
        debugPrint(response.body);
        if (response.statusCode == HttpStatus.ok) {
          Map<String, dynamic> data = json.decode(response.body);
          selectedListForAppoint=List<ProductModel>.from(
              data["products"].map((x) => ProductModel.fromJson(x)));
          calculateTotalPriceForUpdate();
          notifyListeners();
        }
      }
      loading = false;



    // notifyListeners();
    //notifyListeners();
  }
  void gettemsWithList({required BuildContext context, required List<int> id}) async {
    if(selectedListForAppointGet.isEmpty){
      print('getting');
      loading = true;
      notifyListeners();
      if (token == "") {
        await getToken();
      }
      selectedListForAppointGet.clear();
      debugPrint("=============================sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfds=========================");
      var header = {
        "Authorization": "Token $token",
        HttpHeaders.contentTypeHeader: 'application/json'
      };
      for (var element in id)  {
        final uri;


        uri = Uri.parse('https://$baseUrl/api/v1/products/$element/$element/');

        debugPrint(token);
        final response = await http.get(uri, headers: header);
        debugPrint(response.body);
        if (response.statusCode == HttpStatus.ok) {
          Map<String, dynamic> data = json.decode(response.body);
          selectedListForAppointGet=List<ProductModel>.from(
              data["products"].map((x) => ProductModel.fromJson(x)));
          notifyListeners();
        }
      }
      loading = false;
    }


    // notifyListeners();
    //notifyListeners();
  }

    void get({required BuildContext context, int? id}) async {
      loading = true;
      notifyListeners();
      if (token == "") {
        await getToken();
      }
      productList.clear();
      debugPrint("======================================================");
      var header = {
        "Authorization": "Token $token",
        HttpHeaders.contentTypeHeader: 'application/json'
      };

      final uri;

      id != null
          ? uri = Uri.parse('https://$baseUrl/api/v1/products/$id/')
          : uri = Uri.parse('https://$baseUrl/api/v1/products/');
      debugPrint(token);
      final response = await http.get(uri, headers: header);
      debugPrint(response.body);
      if (response.statusCode == HttpStatus.ok) {
        Map<String, dynamic> data = json.decode(response.body);
        productList = List<ProductModel>.from(
            data["products"].map((x) => ProductModel.fromJson(x)));
        loading = false;

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
                  title: const Text('Faild'),
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

    void add(ProductModel model, BuildContext context) async {
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
      final uri = Uri.parse('https://$baseUrl/api/v1/products/');
      print(uri);
      final response =
      await http.post(uri, headers: header, body: jsonEncode(body));
      print(response.body);
      if (response.statusCode == HttpStatus.created) {
        get(context: context);
        loading = false;
        notifyListeners();
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('Added'),
                content: const Text('Product added successfully'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      get(context: context);
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

    void delete(ProductModel model, BuildContext context) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Delete'),
              content: const Text('This will delete this product'),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    //action for delete

                    productList.remove(model);
                    notifyListeners();
                    Navigator.pop(context);
                  },
                  child: const Text('delete'),
                ),
              ],
            );
          });
    }

    // CategoriesModel? selectedCategory;
    //
    // void setDropDownValue(CategoriesModel value) {
    //   selectedCategory = value;
    //   notifyListeners();
    // }

    // List<BusinessModel> selectedBussinessList = [];

    // void setSelectedBussiness() {
    //   if (selectedBussinessList.contains(selectedBusiness)) {
    //     selectedBussinessList.remove(selectedBusiness);
    //   }
    //   selectedBussinessList.add(selectedBusiness!);
    //   notifyListeners();
    // }

    ProductModel? updateModel;
    void updateNavigate(BuildContext context, ProductModel model) {
      update = true;
      updateModel = model;
      debugPrint(updateModel!.toJson().toString());
      notifyListeners();
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (_) => const Bussiness()));
    }

    void updateFun(BuildContext context, ProductModel model) async {
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
      final uri =
      Uri.parse('https://$baseUrl/api/v1/products/${model.id}/');
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
                content: const Text('Product updated successfully'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                      loading = false;
                      notifyListeners();
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
                  title: const Text('Faild'),
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
  }
