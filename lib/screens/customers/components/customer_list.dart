import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:fresh_new_one/screens/customers/models/country_model.dart';
import 'package:fresh_new_one/screens/customers/provider/customer_provider.dart';
import 'package:intl/intl.dart';
import 'package:fresh_new_one/screens/user/componets/user_creation_form.dart';
import '../../../componets.dart';
import '../../../constants.dart';
import '../../../sizeconfig.dart';

class CustomerForm extends StatefulWidget {
  final CustomerModel? model;
  const CustomerForm({Key? key, this.model}) : super(key: key);

  @override
  _CustomerFormState createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final mailController = TextEditingController();
  final bloodController = TextEditingController();
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final pincodeController = TextEditingController();
  final insurance_company = TextEditingController();
  final insurance_exp = TextEditingController();
  final insurance_num = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String image = "";
  DateTime selectedDate = DateTime.now();
  _selectDate() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 320)),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;

        insurance_exp.text =
            "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
      });
    }
  }

  _upload() {
    if (formKey.currentState!.validate()) {
      print(mailController.text);
      CustomerModel model = CustomerModel(
          id: widget.model != null ? widget.model!.id : null,
          image: image,
          name: nameController.text,
          age: int.parse(ageController.text),
          phone: phoneController.text,
          mail: mailController.text,
          blood: bloodController.text,
          country: countryController.text,
          state: stateController.text,
          city: cityController.text,
          pincode: pincodeController.text,
          address: addressController.text,
          insurance_comapny: insurance_company.text,
          insurance_expiry: insurance_exp.text,
          insurance_num: insurance_num.text);
      widget.model == null
          ? Provider.of<CustomerProvider>(context, listen: false)
              .addCategory(model, context)
          : Provider.of<CustomerProvider>(context, listen: false)
              .updateCategory(context, model);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      try {
        nameController.text = widget.model!.name!;
        ageController.text = widget.model!.age.toString();
        phoneController.text = widget.model!.phone;
        stateController.text = widget.model!.state;
        bloodController.text = widget.model!.blood;
        countryController.text = widget.model!.country;
        stateController.text = widget.model!.state;
        cityController.text = widget.model!.city;
        addressController.text = widget.model!.address;
        pincodeController.text = widget.model!.pincode.toString();
        insurance_company.text = widget.model!.insurance_comapny;
        insurance_exp.text = widget.model!.insurance_expiry.toString();
        insurance_num.text = widget.model!.insurance_num;
        mailController.text = widget.model!.mail;
        setState(() {
          image = widget.model!.image == null ? "" : widget.model!.image!;
        });
      } catch (e) {
        print(e);
      }
    }
  }

  Future getImagefromcamera() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      File file = File(image.path);
      _uploadImage(file);
    }
  }

  _uploadImage(File file) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(
                  width: 20,
                ),
                Text("Loading.."),
              ],
            ),
          ),
        );
      },
    );

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("image" + DateTime.now().toString());
    UploadTask uploadTask = ref.putFile(file);
    uploadTask.then((res) async {
      String url = await res.ref.getDownloadURL();
      debugPrint(url);
      setState(() {
        image = url;
      });
      Navigator.pop(context);
      Navigator.pop(context);
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  Future getImagefromGallery() async {
    final ImagePicker _picker = ImagePicker();
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path);
      _uploadImage(file);
    }
  }

  showImageupload() {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: [
                        FloatingActionButton(
                          onPressed: getImagefromcamera,
                          tooltip: "Pick Image form camera",
                          child: Icon(Icons.add_a_photo),
                        ),
                        const Text('From camera')
                      ],
                    ),
                    Column(
                      children: [
                        FloatingActionButton(
                          onPressed: getImagefromGallery,
                          tooltip: "Pick Image from gallery",
                          child: const Icon(Icons.camera_alt),
                        ),
                        const Text('From gallery')
                      ],
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }

  String counryCode = "";
  void pickCountry() {
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
      onSelect: (Country country) {
        setState(() {
          countryController.text = country.name;
          counryCode = country.countryCode;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                widget.model != null
                    ? const Text(
                        'Update Customer',
                        style: TextStyle(color: whiteColor, fontSize: 20),
                      )
                    : const Text(
                        'Create Customer',
                        style: TextStyle(color: whiteColor, fontSize: 20),
                      ),
                columUserTextFileds(
                    "Enter name", "Title", TextInputType.name, nameController),

                phoneTextField(
                    "Enter phone",
                    "phone number without country code",
                    TextInputType.number,
                    phoneController),
                emailWhiteField("Enter mail", "mail",
                    TextInputType.emailAddress, mailController),
                columUserTextFileds(
                    "Enter age", "age", TextInputType.number, ageController),
                columUserTextFileds("Enter blood", "Blood group",
                    TextInputType.name, bloodController),
                InkWell(
                  onTap: () {
                    pickCountry();
                  },
                  child: country("Enter Country", "Country", TextInputType.name,
                      countryController),
                ),
                columUserTextFileds("Enter State", "State", TextInputType.name,
                    stateController),
                columUserTextFileds(
                    "Enter City", "City", TextInputType.name, cityController),
                columUserTextFileds("Enter address", "address",
                    TextInputType.streetAddress, addressController),
                picode("Pin code", "Pin code", TextInputType.number,
                    pincodeController),
                notManditaryFields("Insurance company", "Insurance company",
                    TextInputType.name, insurance_company),
                InkWell(
                  onTap: () {
                    _selectDate();
                  },
                  child: expiryDate("insurance expiry", "2025-02-02",
                      TextInputType.datetime, insurance_exp),
                ),
                notManditaryFields("insurance number", "insurance number",
                    TextInputType.name, insurance_num),
                spacer(10),

                InkWell(
                  onTap: () {
                    showImageupload();
                  },
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Center(
                        child: image == ""
                            ? const Icon(
                                Icons.add_a_photo_outlined,
                                color: Colors.white,
                              )
                            : Image.network(image)),
                  ),
                ),
                spacer(10),
                // Visibility(
                //     visible: !isService, child: columUserTextFileds("Duration")),
                Consumer<CustomerProvider>(builder: (context, snapshot, child) {
                  return snapshot.loading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                                onTap: () {
                                  _upload();
                                },
                                child: defaultButton(
                                    SizeConfig.screenWidth! * 0.5,
                                    widget.model != null ? "update" : add)),
                            InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  cancel,
                                  style: TextStyle(color: blackColor),
                                ))
                          ],
                        );
                }),
                spacer(10)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget notManditaryFields(String label, String hint, TextInputType keyboard,
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

Widget phoneTextField(String label, String hint, TextInputType keyboard,
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
      keyboardType: TextInputType.phone,
      maxLength: 15,
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

Widget country(String label, String hint, TextInputType keyboard,
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
      enabled: false,
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

Widget expiryDate(String label, String hint, TextInputType keyboard,
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
      enabled: false,
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: whiteColor),
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

Widget picode(String label, String hint, TextInputType keyboard,
    TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    child: TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Please Enter value for picode";
        }
        return null;
      },
      maxLength: 12,
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: whiteColor),
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

Widget emailWhiteField(String label, String hint, TextInputType keyboard,
    TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    child: TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Please Enter value for email";
        } else if (!emailRegex.hasMatch(value)) {
          return "invaild email address";
        }
        return null;
      },
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: whiteColor),
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
