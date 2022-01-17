import 'package:flutter/material.dart';
import 'package:fresh_new_one/screens/categories/body.dart';
import 'package:fresh_new_one/screens/customers/body.dart';

import 'package:fresh_new_one/screens/dashbord/body.dart';
import 'package:fresh_new_one/screens/enquiry/body.dart';
import 'package:fresh_new_one/screens/login/body.dart';
import 'package:fresh_new_one/screens/products/componets/product_list.dart';
import 'package:fresh_new_one/screens/region/body.dart';
import 'package:fresh_new_one/screens/roles/body.dart';
import 'package:fresh_new_one/screens/roles/componets/roles_list.dart';
import 'package:fresh_new_one/screens/services/componets/order.dart';
import 'package:fresh_new_one/screens/services/componets/services.dart';
import 'package:fresh_new_one/screens/tax/body.dart';
import 'package:fresh_new_one/screens/unint/body.dart';
import 'package:fresh_new_one/screens/user/componets/user_list.dart';

import 'constants.dart';
import 'screens/Desingation/body.dart';
import 'screens/bussiness/componets/list_bussiness.dart';
import 'screens/user/body.dart';

class RouterPage {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case adminPanel:
        return MaterialPageRoute(builder: (_) => const DashBoard());
      case roles:
        return MaterialPageRoute(builder: (_) => const UserRoles());
      case roleList:
        return MaterialPageRoute(builder: (_) => const RoleList());
      case userCreation:
        return MaterialPageRoute(builder: (_) => const UserList());
      case "Createuser":
        return MaterialPageRoute(builder: (_) => const UserCreation());
      case business:
        return MaterialPageRoute(builder: (_) => const BussinessList());
      case taxNav:
        return MaterialPageRoute(builder: (_) => const Tax());
      case products:
        return MaterialPageRoute(builder: (_) => const ProductList());
      case unitNav:
        return MaterialPageRoute(builder: (_) => const Unit());
      case regionNav:
        return MaterialPageRoute(builder: (_) => const RegionList());
      // case servicesAdd:
      //   return MaterialPageRoute(builder: (_) => const ServicesAdd());
      case order:
        return MaterialPageRoute(builder: (_) => const OrderProducts());
      case enquiry:
        return MaterialPageRoute(builder: (_) => const Enquiry());
      case customers:
        return MaterialPageRoute(builder: (_) => const CustomerList());
      case designation:
        return MaterialPageRoute(builder: (_) => const Designations());
      case loginNav:
        return MaterialPageRoute(builder: (_) => const Login());
      case category:
        return MaterialPageRoute(builder: (_) => const Categories());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
