import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fresh_new_one/constants.dart';
import 'package:fresh_new_one/screens/bussiness/body.dart';
import 'package:fresh_new_one/screens/categories/models/categories_model.dart';
import 'package:fresh_new_one/screens/enquiry/model/appointmentsmodel.dart';
import 'package:fresh_new_one/screens/enquiry/model/timeslotmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class AppointmentProvider with ChangeNotifier {
  bool loading = false;
  bool update = false;
  Timeslots? selectedSlot;
  DateTime? selectedBookDate;
  List<AppointMentModel> categoryList = [];
  List<AppointMentModel> tempList = [];
  int today_appoint=0;

  int tommorow=0;
  setBookDate(DateTime? bookdate){
    selectedBookDate=bookdate;
    notifyListeners();
  }
  String token = "";
  AppointmentProvider() {
    if (token == "") {
      getToken();
    }
  }
  void setSlotSelect(Timeslots? slot){
    selectedSlot=slot;
    notifyListeners();
  }
  void initTemp() {
    if (tempList.isEmpty) {
      tempList = categoryList;
      debugPrint(categoryList.length.toString());
      notifyListeners();
    }
  }

  void retainList() {
    categoryList.clear();
    categoryList = tempList;
    debugPrint(categoryList.length.toString());
    notifyListeners();
  }

  // void searchBusiness(String s) {
  //   initTemp();
  //   List<AppointMentModel> searchList = [];
  //   for (int i = 0; i < tempList.length; i++) {
  //     AppointMentModel m = tempList[i];
  //     if (m.customer.contains(s)) {
  //       searchList.add(m);
  //     }
  //   }
  //   categoryList.clear();
  //   categoryList = searchList;
  //   notifyListeners();
  // }
  void sortAscendingByDate(){
    categoryList.sort((b,a)=>a.bookingDate.compareTo(b.bookingDate));
    notifyListeners();
  }
  void sortDescendingByDate(){
    categoryList.sort((a,b)=>a.bookingDate.compareTo(b.bookingDate));
    notifyListeners();
  }
  void unFilterList(BuildContext context){
    categoryList.clear();
    tempList.clear();
    getCategoryList(context);
    notifyListeners();
  }
  void clearTempList(){
    tempList.clear();
    notifyListeners();
  }

  void filterListWithEnquired(){



    List<AppointMentModel> tList=categoryList.where((element) => element.status=="E"||element.status=="P").toList();

    tempList=tList;
    notifyListeners();
  }

  void filterListWithCompleted(){

    List<AppointMentModel> tList=categoryList.where((element) => element.status=="C").toList();

    tempList.addAll(tList);
    notifyListeners();
  }
  void filterListWithAdvancePaid(){

    List<AppointMentModel> tList=categoryList.where((element) => element.status=="A").toList();

    tempList.addAll(tList);
    notifyListeners();
  }
  void filterListWithCanceled(){

    List<AppointMentModel> tList=categoryList.where((element) => element.status=="F").toList();

    tempList.addAll(tList);
    notifyListeners();
  }

  void filterListWithTomorrow(){
    if(tempList.isEmpty){
      tempList=categoryList;
    }
    if(categoryList.length<tempList.length){
      categoryList=tempList;
    }
    final tomorrow=DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+1);
    List<AppointMentModel> tList=categoryList.where((element) => element.bookingDate==tomorrow).toList();
    categoryList.clear();
    categoryList=tList;
    notifyListeners();
  }
  Future<int> getCategoryList(BuildContext context) async {
    if(categoryList.isEmpty){
      loading = true;
      notifyListeners();
      if (token == "") {
        await getToken();
      }
      categoryList.clear();
      debugPrint("======================================================");
      var header = {
        "Authorization": "Token $token",
        HttpHeaders.contentTypeHeader: 'application/json'
      };

      final uri = Uri.parse('https://$baseUrl/api/v1/appointments/');
      debugPrint(token);
      final response = await http.get(uri, headers: header);
      debugPrint(response.body);
      if (response.statusCode == HttpStatus.ok) {
        Map<String, dynamic> data = json.decode(response.body);
        categoryList = List<AppointMentModel>.from(
            data["appointments"].map((x) => AppointMentModel.fromJson(x)));
        DateTime today=DateTime.now();
        final todayDate=DateTime(today.year,today.month,today.day);
        final tomorow=DateTime(today.year,today.month,today.day+1);
        categoryList.forEach((element) {
          if(todayDate==element.bookingDate){
            today_appoint=today_appoint+1;
          }else if(tomorow==element.bookingDate){
            tommorow=tommorow+1;
          }
        });
        categoryList.sort((b,a)=>a.bookingDate.compareTo(b.bookingDate));
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
                  content: Text(data.toString()),
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
    return 1;
    //notifyListeners();
  }

  Future<void> getToken() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();

    token = _prefs.getString("token")!;
  }

  void addCategory(AppointMentModel model, BuildContext context) async {
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
    final uri = Uri.parse('https://$baseUrl/api/v1/appointments/');
    print(uri);
    final response =
        await http.post(uri, headers: header, body: jsonEncode(body));
    print(response.body);
    if (response.statusCode == HttpStatus.created) {
      loading = false;
      notifyListeners();
      Navigator.pop(context);
      getCategoryList(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Added'),
              content: const Text('appointments added successfully'),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    categoryList.clear();
                    getCategoryList(context);
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
                title: const Text('Faild'),
                content: Text(data.toString()),
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

  void deleteCategory(CategoriesModel model, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Delete'),
            content: const Text('This will delete this appointments'),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  //action for delete
                  void getBusinessList(BuildContext context) async {
                    loading = true;
                    notifyListeners();
                    if (token == "") {
                      await getToken();
                    }
                    categoryList.clear();
                    debugPrint(
                        "======================================================");
                    var header = {
                      "Authorization": "Token $token",
                      HttpHeaders.contentTypeHeader: 'application/json'
                    };

                    final uri = Uri.parse(
                        'https://$baseUrl/api/v1/categories/${model.id}/');
                    debugPrint(token);
                    final response = await http.delete(uri, headers: header);
                    debugPrint(response.body);
                    if (response.statusCode == HttpStatus.ok) {
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
                    //notifyListeners();
                  }

                  categoryList.remove(model);
                  notifyListeners();
                  Navigator.pop(context);
                },
                child: const Text('delete'),
              ),
            ],
          );
        });
  }

  CategoriesModel? selectedCategory;
  emptyDropdown() {
    selectedCategory = null;
  }

  bool setDropDownValue(CategoriesModel value) {
    selectedCategory = value;
    notifyListeners();

    return true;
  }

  // List<BusinessModel> selectedBussinessList = [];

  // void setSelectedBussiness() {
  //   if (selectedBussinessList.contains(selectedBusiness)) {
  //     selectedBussinessList.remove(selectedBusiness);
  //   }
  //   selectedBussinessList.add(selectedBusiness!);
  //   notifyListeners();
  // }

  CategoriesModel? updateModel;
  void updateNavigate(BuildContext context, CategoriesModel model) {
    update = true;
    updateModel = model;
    debugPrint(updateModel!.toJson().toString());
    notifyListeners();
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (_) => const Bussiness()));
  }
  void updateCategoryOneField(BuildContext context, Map<String,dynamic> model,int id) async {
    loading = true;
    notifyListeners();
    if (token == "") {
      await getToken();
    }
    var header = {
      "Authorization": "Token $token",
      HttpHeaders.contentTypeHeader: 'application/json'
    };


    final uri = Uri.parse('https://$baseUrl/api/v1/appointments/$id/');
    print(uri);
    final response =
    await http.put(uri, headers: header, body: jsonEncode(model));

    if (response.statusCode == HttpStatus.ok) {
      loading = false;
      notifyListeners();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Updated'),
              content: const Text(' updated successfully'),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(context);
                    loading = false;
                    notifyListeners();
                    categoryList.clear();
                    getCategoryList(context);
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
  void updateCategory(BuildContext context, AppointMentModel model) async {
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
    final uri = Uri.parse('https://$baseUrl/api/v1/appointments/${model.id}/');
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
              content: const Text(' updated successfully'),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(context);

                    loading = false;
                    notifyListeners();
                    categoryList.clear();
                    getCategoryList(context);
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
//time slot
  List<Timeslots> slots=[];
  void getTimeSlots(BuildContext context,String date) async {
    loading = true;
    notifyListeners();
    if (token == "") {
      await getToken();
    }
    // slots.clear();
    debugPrint("======================================================");
    var header = {
      "Authorization": "Token $token",
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    var body={
      "date":date
    };
    final uri = Uri.parse('https://perfect-new.herokuapp.com/api/v1/timeslots/');
    debugPrint(token);

    // final newURI = uri.replace(queryParameters: params);
    final response = await http.post(uri, headers: header,body: jsonEncode(body));
    debugPrint(response.body);
    if (response.statusCode == HttpStatus.ok) {
      loading = false;
      notifyListeners();
      Map<String, dynamic> data = json.decode(response.body);
      slots = List<Timeslots>.from(
          data["timeslots"].map((x) => Timeslots.fromJson(x)));
      print(slots.length);
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
                content: const Text('some thing went wrong'),
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
  // void getTimeSlots(BuildContext context,String date) async {
  //   loading = true;
  //   notifyListeners();
  //   if (token == "") {
  //     await getToken();
  //   }
  //   // slots.clear();
  //   debugPrint("======================================================");
  //   var header = {
  //     "Authorization": "Token $token",
  //     HttpHeaders.contentTypeHeader: 'application/json'
  //   };
  //   var body={
  //     "date":date
  //   };
  //   final uri = Uri.parse('https://perfect-new.herokuapp.com/api/v1/timeslots/');
  //   debugPrint(token);
  //
  //   // final newURI = uri.replace(queryParameters: params);
  //   final response = await http.post(uri, headers: header,body: jsonEncode(body));
  //   debugPrint(response.body);
  //   if (response.statusCode == HttpStatus.ok) {
  //     loading = false;
  //     notifyListeners();
  //     Map<String, dynamic> data = json.decode(response.body);
  //     slots = List<Timeslots>.from(
  //         data["timeslots"].map((x) => Timeslots.fromJson(x)));
  //     print(slots.length);
  //     notifyListeners();
  //   } else if (response.statusCode == HttpStatus.badRequest) {
  //     loading = false;
  //     notifyListeners();
  //     Map<String, dynamic> data = json.decode(response.body);
  //     try {
  //       showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return CupertinoAlertDialog(
  //               title: const Text('Failed'),
  //               content: Text(data['error']),
  //               actions: <Widget>[
  //                 CupertinoDialogAction(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: const Text('Ok'),
  //                 ),
  //               ],
  //             );
  //           });
  //     } catch (e) {
  //       loading = false;
  //       notifyListeners();
  //       showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return CupertinoAlertDialog(
  //               title: const Text('Failed'),
  //               content: const Text('some thing went wrong'),
  //               actions: <Widget>[
  //                 CupertinoDialogAction(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: const Text('Ok'),
  //                 ),
  //               ],
  //             );
  //           });
  //     }
  //   }
  //   //notifyListeners();
  // }
  Future<Timeslots?> getTimeSlotsWithId(BuildContext context,int id) async {

    if (token == "") {
      await getToken();
    }
    // slots.clear();
    debugPrint("=========================getting specif item=============================");
    var header = {
      "Authorization": "Token $token",
      HttpHeaders.contentTypeHeader: 'application/json'
    };

    final uri = Uri.parse('https://perfect-new.herokuapp.com/api/v1/timeslots/$id/');
    debugPrint(token);

    // final newURI = uri.replace(queryParameters: params);
    final response = await http.get(uri, headers: header);
    debugPrint(response.body);
    if (response.statusCode == HttpStatus.ok) {
      print("status ok");
      Map<String, dynamic> data = json.decode(response.body);
      print(' gettede data${Timeslots.fromJson(data)}');
      return Timeslots.fromJson(data);

    }
    //notifyListeners();
  }

  //status
  String sel="p";
  String dropDownvalue="enquired";
  setSel(String p){
    sel=p;
    switch (p) {
      case "P":


        dropDownvalue = "enquired";


        break;
      case "E":

          dropDownvalue = "enquired";


        break;
      case "A":

          dropDownvalue = "advance paid";

        break;
      case "C":

          dropDownvalue = "completed";

        break;
      case "F":


          dropDownvalue = "canceled";

        break;
    }
    notifyListeners();
  }
  setDropDownvalue(String s){
    dropDownvalue=s;

    notifyListeners();
  }
}
