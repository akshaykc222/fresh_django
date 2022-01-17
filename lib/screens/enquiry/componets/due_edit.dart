import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_new_one/constants.dart';
import 'package:fresh_new_one/screens/categories/models/categories_model.dart';
import 'package:fresh_new_one/screens/categories/provider/category_provider.dart';
import 'package:fresh_new_one/screens/enquiry/model/appointmentsmodel.dart';
import 'package:fresh_new_one/screens/enquiry/provider/appointment_provider.dart';
import 'package:fresh_new_one/sizeconfig.dart';

import '../../../componets.dart';
import 'enquiry_detail.dart';

class DueEdit extends StatefulWidget {
  final AppointMentModel model;
  const DueEdit({Key? key,required this.model}) : super(key: key);

  @override
  _DueEditState createState() => _DueEditState();
}

class _DueEditState extends State<DueEdit> {
  final taxController = TextEditingController();
  final taxShortController = TextEditingController();
  final taxPercentageController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  double dueAmount=0.0;
  @override
  void initState() {
    taxController.text=widget.model.amountPaid.toString();
    super.initState();


  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          headingText("Update Amount paid") ,
          spacer(10),
          amountPaid("Enter amount paid", "amount",
              TextInputType.number, taxController),
          // spacer(10),
          // columUserTextFiledsBlack("Enter tax short name", "Tax short name", TextInputType.none, taxPercentageController),
          // spacer(10),
          // columUserTextFiledsBlack("Enter tax percentage", "Tax percentage", TextInputType.number, taxPercentageController),
          Consumer<AppointmentProvider>(
              builder: (context, snapshot,child) {
                return snapshot.loading ?const Center(child: CircularProgressIndicator(color: blackColor,),) :Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (formKey.currentState!.validate()) {

                          Map<String,dynamic> data={
                            "amount_paid":double.parse(taxController.text),
                            "due_amount":dueAmount

                          };
                          widget.model.amountPaid=double.parse(taxController.text);
                          widget.model.dueAmount=dueAmount;
                          Provider.of<AppointmentProvider>(context,listen: false).updateCategory(context, widget.model);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>AppointmentDetail(model: widget.model,)));
                          }
                        },
                        child: defaultButton(SizeConfig.screenWidth! * 0.5,widget.model!=null?"Update": add)),
                    InkWell(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          cancel,
                          style: TextStyle(color: blackColor),
                        ))
                  ],
                );
              }
          ),
          spacer(10)
        ],
      ),
    );
  }
  Widget amountPaid(String label, String hint, TextInputType keyboard,
      TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return "Please Enter value for $hint";
          }else if(double.parse(value) > widget.model.customerFee){
            return " value must be less than customer fee";
          }
          return null;
        },
        controller: controller,
        keyboardType: keyboard,
        onChanged: (val){
          if(widget.model.customerFee>=double.parse(taxController.text)) {
            setState(() {
              dueAmount=widget.model.customerFee-double.parse(taxController.text);
            });
          }
        },
        style: const TextStyle(color: textColor),
        decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              color: Colors.black,
              fontSize: 13,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black),
            filled: true,
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade500, width: 1)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade500, width: 1)),
            disabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white30)),
            border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white30))),
      ),
    );
  }
}
