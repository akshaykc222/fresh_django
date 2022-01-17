import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../componets.dart';
import '../../../constants.dart';
import '../../customers/components/customer_list.dart';
import '../models/bussinessmode.dart';
import '../provider/business_provider.dart';



class CreateBussiness extends StatefulWidget {
  final BusinessModel? model;
  const CreateBussiness({Key? key, this.model}) : super(key: key);

  @override
  _CreateBussinessState createState() => _CreateBussinessState();
}

class _CreateBussinessState extends State<CreateBussiness> {
  final bussinessController = TextEditingController();
  final addressController = TextEditingController();
  final pincodeController = TextEditingController();
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final taxController = TextEditingController();
  final taxController1 = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String image="";
  String selectRegion = "india";
  List<String> regionList = ["india", "dubai"];
  BusinessModel? updateModel;
  _upload() {
    print('seleff');
    if (formKey.currentState!.validate()) {
      var uuid = Uuid();
      String id = uuid.v1();
      BusinessModel model = BusinessModel(
          name: bussinessController.text,
          address: addressController.text,
          pincode: pincodeController.text.toString(),
          country: countryController.text,
          state: stateController.text,
          city: cityController.text,
          tax: taxController.text,
          tax1: taxController1.text, image: image);
      FocusScope.of(context).requestFocus(FocusNode());
      BusinessModel? upmodel =
          Provider.of<BusinessProvider>(context, listen: false).updateModel;
      if (upmodel != null) {
        debugPrint("===========================update Business=============");
        Provider.of<BusinessProvider>(context, listen: false)
            .updateBusiness(context, model);
      } else {
        debugPrint("===========================create Business=============");
        Provider.of<BusinessProvider>(context, listen: false)
            .addBusiness(model, context, true);
      }
    }
  }
  String counryCode="";
  void pickCountry(){
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, color: Colors.blueGrey),
        //Optional. Sets the border radius for the bottomsheet.
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        //Optional. Styles the search field.
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
      onSelect: (Country country){
        setState(() {
          countryController.text=country.name;
          counryCode=country.countryCode;
        });
      },
    );
  }
  @override
  void initState() {

    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      Provider.of<BusinessProvider>(context, listen: false)
          .setDropDownValue(null);
      // Provider.of<BusinessProvider>(context, listen: false)
      //     .setDropDownValue(widget.model!);
      Provider.of<BusinessProvider>(context, listen: false)
          .getBusinessList(context);
      BusinessModel? model =
          Provider.of<BusinessProvider>(context, listen: false).updateModel;
      if (model != null) {
        bussinessController.text = model.name;
        addressController.text = model.address;
        pincodeController.text = model.pincode.toString();
        countryController.text = model.country;
        stateController.text = model.state;
        cityController.text = model.city;
        taxController.text = model.tax;
        taxController1.text = model.tax1;
        // Provider.of<BusinessProvider>(context, listen: false)
        //     .setDropDownValue(widget.model!);
        setState(() {
         image=model.image==null?"":model.image!;
         print(image);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // columUserTextFileds("Branch Under"),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 25),
            child:
                Consumer<BusinessProvider>(builder: (context, provider, child) {
              return DropdownButtonFormField(
                value: provider.selectedBusiness ?? null,
                icon: const Icon(Icons.keyboard_arrow_down),
                decoration: defaultDecoration(
                    "Parent business", "Select parent business"),
                items: provider.businessList
                    .map((e) => DropdownMenuItem<BusinessModel>(
                        value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (BusinessModel? value) {
                  setState(() {
                    provider.setDropDownValue(value!);
                  });
                },
              );
            }),
          ),

          columUserTextFileds("Enter Business Name", "Business name",
              TextInputType.name, bussinessController),
          columUserTextFileds("Enter Address", "Address",
              TextInputType.multiline, addressController),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          //   child: DropdownButtonFormField(
          //     style: const TextStyle(color: textColor),
          //     value: selectRegion,
          //     icon: const Icon(
          //       Icons.keyboard_arrow_down,
          //       color: textColor,
          //     ),
          //     decoration: const InputDecoration(
          //         labelText: "Region",
          //         labelStyle: TextStyle(
          //             fontSize: 20,
          //             fontWeight: FontWeight.bold,
          //             color: textColor),
          //         floatingLabelBehavior: FloatingLabelBehavior.auto,
          //         hintStyle: TextStyle(color: textColor),
          //         filled: true,
          //         enabledBorder: UnderlineInputBorder(
          //           borderSide: BorderSide(
          //             color: Colors.white30,
          //             width: 2.0,
          //           ),
          //         ),
          //         disabledBorder: UnderlineInputBorder(
          //             borderSide: BorderSide(color: Colors.white30)),
          //         border: UnderlineInputBorder(
          //             borderSide: BorderSide(color: Colors.white30))),
          //     items: regionList
          //         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          //         .toList(),
          //     onChanged: (String? value) {
          //       setState(() {
          //         selectRegion = value!;
          //       });
          //     },
          //   ),
          // ),

          pinCode("Enter Pin code", "Pin code", TextInputType.number,
              pincodeController),
          InkWell(
            onTap: (){
              pickCountry();
            },
            child: country("Enter Country name", "Country",
                TextInputType.name, countryController),
          ),
          columUserTextFileds(
              "Enter State name", "State", TextInputType.name, stateController),
          columUserTextFileds(
              "Enter City name", "City", TextInputType.name, cityController),
          taxField("Enter tax number", "Tax number",
              TextInputType.name, taxController),
          taxField("Enter tax 1 number", "Tax number",
              TextInputType.name, taxController1),
          spacer(20),
          InkWell(
            onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.image
              );

              if (result != null) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      child:  SizedBox(
                        height: 100,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(width: 20,),
                            Text("Loading.."),
                          ],
                        ),
                      ),
                    );
                  },
                );
                File file = File(result.files.single.path!);
                FirebaseStorage storage = FirebaseStorage.instance;
                Reference ref = storage.ref().child("image" + DateTime.now().toString()+".jpg");
                UploadTask uploadTask = ref.putFile(file);
                uploadTask.then((res) async {
                  String url=await res.ref.getDownloadURL();
                  debugPrint(url);
                  setState(() {
                    image=url;
                  });
                  Navigator.pop(context);
                });
              } else {
                // User canceled the picker
              }
            },
            child:image==""? SizedBox(
              width: 50,
              height: 50,
              child: Container(
                color: Colors.grey,
                child: const Center(
                  child: Icon(Icons.add_a_photo_outlined),
                ),
              ),
            ):SizedBox(
              width: 150,
                height: 150,
            child: Image.network(image),
            ),
          ),
          Consumer<BusinessProvider>(builder: (context, snapshot, child) {
            return snapshot.loading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: whiteColor,
                  ))
                : InkWell(
                    onTap: () {
                      _upload();
                    },
                    child: defaultButton(
                        MediaQuery.of(context).size.width * 0.6,
                        snapshot.update ? "Update" : create));
          })
        ],
      ),
    );
  }
}
Widget pinCode(String label, String hint, TextInputType keyboard,
    TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    child: TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Please Enter value for $hint";
        }
        return null;
      },
      controller: controller,
      keyboardType: keyboard,
      maxLength: 10,
      style: const TextStyle(color: textColor),
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: whiteColor,
            fontSize: 13,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          hintText: hint,
          hintStyle: const TextStyle(color: textColor),
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
Widget taxField(String label, String hint, TextInputType keyboard,
    TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    child: TextFormField(

      controller: controller,
      keyboardType: keyboard,

      style: const TextStyle(color: textColor),
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: whiteColor,
            fontSize: 13,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          hintText: hint,
          hintStyle: const TextStyle(color: textColor),
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