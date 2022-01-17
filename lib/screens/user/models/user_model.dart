import 'package:fresh_new_one/screens/roles/models/role_model.dart';
import 'package:fresh_new_one/screens/user/models/role_models.dart';

class UserModel {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? password;
  int? designation;
  List<RoleModel?>? roleList;
  UserModel(
      {this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.password,
      required this.designation,
      this.roleList
     });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<RoleModel> _roleslist = <RoleModel>[];
    if (json['roles'] != null) {
      json['roles'].forEach((v) {
        _roleslist.add(RoleModel.fromJson(v));
      });
    }
    return UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        password: json['password'],
        designation: json['designation'],
        roleList:_roleslist
       );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['designation'] = designation;
    data['password1'] = password;
    data['password2'] = password;
    data['roles']= List<dynamic>.from(roleList!.map((x) => x!.toJson()));

    return data;
  }
}
