import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fresh_new_one/componets.dart';
import 'package:fresh_new_one/constants.dart';

import 'componets/user_creation_form.dart';
import 'models/user_model.dart';

class UserCreation extends StatelessWidget {
  final UserModel? model;
  const UserCreation({Key? key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: appBar("User Creation", [], context),
      body: Container(
        color: lightBlack,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children:  [
              model!=null?  UserCreationForm(model: model,):const UserCreationForm()
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: black90,
      //   onPressed: () {},
      //   child: const Center(
      //     child: Icon(Icons.done, color: textColor),
      //   ),
      // ),
      // bottomNavigationBar: const BottomAppBar(
      //   color: blackColor,
      //   clipBehavior: Clip.antiAlias,
      //   shape: CircularNotchedRectangle(),
      //   child: SizedBox(
      //     height: 50,
      //     width: double.infinity,
      //   ),
      // ),
    );
  }
}
