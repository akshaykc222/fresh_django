import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_new_one/componets.dart';
import 'package:fresh_new_one/constants.dart';
import 'package:fresh_new_one/screens/Desingation/componets/list_designation.dart';

import 'models/designation_model.dart';
import 'provider/desingation_provider.dart';

class Designations extends StatefulWidget {
  const Designations({Key? key}) : super(key: key);

  @override
  State<Designations> createState() => _DesignationsState();
}

class _DesignationsState extends State<Designations> {
  final designationText01 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  void showAddAlert01() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (_) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Wrap(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      columUserTextFiledsBlack("Designation title", "Designation",
                          TextInputType.name, designationText01),
                      spacer(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {}
                                var random = Random();
                                Provider.of<DesignationProvider>(context,
                                        listen: false)
                                    .addBusiness(
                                        DesingationModel(
                                            designation: designationText01.text),
                                        context);
                              },
                              child: defaultButton(
                                  MediaQuery.of(context).size.width * 0.4,
                                  add)),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              cancel,
                              style: TextStyle(color: blackColor),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      extendBody: true,
      appBar: appBar("Designations", [], context),
      resizeToAvoidBottomInset: false,
      body: Container(
        color: lightBlack,
        child:const ListDesingations(),
      ),
      bottomNavigationBar: const BottomAppBar(
        color: blackColor,
        child: SizedBox(
          width: double.infinity,
          height: 50,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: lightBlack,
        onPressed: () {
            showAddAlert01();
        },
        child: const Center(
          child: Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
