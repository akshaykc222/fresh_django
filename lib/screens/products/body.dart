import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fresh_new_one/componets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fresh_new_one/screens/products/model/product_model.dart';
import 'package:fresh_new_one/screens/products/provider/products_provider.dart';
import 'package:fresh_new_one/screens/subcategory/models/sub_category.dart';
import 'package:fresh_new_one/screens/subcategory/provider/sub_category_provider.dart';
import 'package:fresh_new_one/screens/tax/model/taxmodel.dart';
import 'package:fresh_new_one/screens/tax/provider/tax_provider.dart';

import '../../constants.dart';
import '../../sizeconfig.dart';
import 'componets/categrory.dart';
import 'componets/products.dart';

class Products extends StatelessWidget {
  const Products({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Treatment", [], context),
      body: Stack(children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: const [
              CategorySelection(),
              ProductDetails(),
              SizedBox(
                height: 100,
              )
            ],
          ),
        ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: defaultButton(
                    MediaQuery.of(context).size.width * 0.6, add)))
      ]),
    );
  }
}

class AddTreatments extends StatefulWidget {
  final ProductModel? model;
  const AddTreatments({Key? key, this.model}) : super(key: key);

  @override
  _AddTreatmentsState createState() => _AddTreatmentsState();
}

class _AddTreatmentsState extends State<AddTreatments> {
  final titleController = TextEditingController();
  final purchaseController = TextEditingController();
  final mrpController = TextEditingController();
  final salespController = TextEditingController();
  final salesRController = TextEditingController();
  final expiryController = TextEditingController();
  final durationController = TextEditingController();
  final taxRateController = TextEditingController();
  String image = "";
  String service = "service";
  List<String> serItems = ["service", "product"];

  _upload() {
    if (formKey.currentState!.validate()) {
      int subID = Provider.of<SubCategoryProvider>(context, listen: false)
          .selectedCategory!
          .id!;
      if (subID == null) {
        errorLoader('select sub category');
      }else if(Provider.of<TaxProvider>(context,listen: false).selectedBusiness==null){
        errorLoader('select tax category');
      } else if (widget.model != null) {
        if (titleController.text.isEmpty || mrpController.text.isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('fields required')));
        } else {
          loader('Updating.please wait');
          ProductModel model = ProductModel(
              image: image,
              id: widget.model!.id,
              name: titleController.text,
              purchaseRate: double.parse(purchaseController.text),
              mrp: double.parse(mrpController.text),
              is_product: service == "service" ? false : true,
              salesPercentage:
                  salespController.text == null || salespController.text.isEmpty
                      ? 0.0
                      : double.parse(salespController.text),
              salesRate:
                  salesRController.text == null || salesRController.text.isEmpty
                      ? 0.0
                      : double.parse(salesRController.text),
              duration: durationController.text == null ||
                      durationController.text.isEmpty
                  ? 0.00
                  : double.parse(durationController.text),
              subCategory: subID,
              taxRate: Provider.of<TaxProvider>(context,listen: false).selectedBusiness!.id!);
          Provider.of<ProductProvider>(context, listen: false)
              .updateFun(context, model);
          Navigator.pop(context);
        }
      } else {
        if (titleController.text.isEmpty || mrpController.text.isEmpty) {
          errorLoader('fields missing');
        } else {
          loader('Updating.please wait');
          ProductModel model = ProductModel(
              image: image,
              name: titleController.text,
              purchaseRate:purchaseController.text==null||purchaseController.text.isEmpty?0.0: double.parse(purchaseController.text),
              mrp:mrpController.text==null?0.0: double.parse(mrpController.text),
              salesPercentage:
                  salespController.text == null || salespController.text.isEmpty
                      ? 0.0
                      : double.parse(salespController.text),
              salesRate:
                  salesRController.text == null || salesRController.text.isEmpty
                      ? 0.0
                      : double.parse(salesRController.text),
              duration: durationController.text == null ||
                      durationController.text.isEmpty
                  ? 0.00
                  : double.parse(durationController.text),
              is_product: service == "service" ? false : true,
              subCategory: subID,
              taxRate: Provider.of<TaxProvider>(context,listen: false).selectedBusiness!.id!);
          Provider.of<ProductProvider>(context, listen: false)
              .add(model, context);
          Navigator.pop(context);
        }
      }
    }
  }

  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      try {
        image = widget.model!.image!;
        titleController.text = widget.model!.name;
        mrpController.text = widget.model!.mrp.toString();
        purchaseController.text = widget.model!.purchaseRate.toString();

        salesRController.text = widget.model!.salesRate.toString();
      } catch (e) {
        print('eroor');
      }
    }
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      Provider.of<TaxProvider>(context,listen: false).getBusinessList(context);
      Provider.of<TaxProvider>(context,listen: false).setDropDownValue(null);
    });
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 360)));
    if (picked != null) {
      setState(() {
        expiryController.text = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  loader(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(
                  width: 20,
                ),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  errorLoader(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(message),
                spacer(10),
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: defaultButton(300, "Ok"))
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Form(
        key: formKey,
        child: Column(
          children: [
            widget.model != null
                ? headingText("Update Product")
                : headingText("Add Product"),
            columUserTextFiledsBlack(
                "Enter Title", "Title", TextInputType.name, titleController),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: DropdownButtonFormField(
                // Initial Value
                value: service,
                decoration: InputDecoration(
                    labelText: "Type",
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
                // Down Arrow Icon
                icon: const Icon(Icons.keyboard_arrow_down),

                // Array list of items
                items: serItems.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                // After selecting the desired option,it will
                // change button value to selected value
                onChanged: (String? newValue) {
                  setState(() {
                    service = newValue!;
                  });
                },
              ),
            ),
            const CategorySelection(),

            service != "service"
                ? columUserTextFiledsBlack("Enter Purchase rate",
                    "Purchase rate", TextInputType.number, purchaseController)
                : Container(),
            columUserTextFiledsBlack(
                "Enter Rate", "Rate", TextInputType.number, mrpController),
            service != "service"
                ? columUserTextFiledsBlack("Enter Sales Percentage",
                    "Sales Percentage", TextInputType.number, salespController)
                : Container(),
            service != "service"
                ? columUserTextFiledsBlack("Enter Sales Rate", "Sales Rate",
                    TextInputType.number, salesRController)
                : Container(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 25),
              child:
              Consumer<TaxProvider>(builder: (context, provider, child) {
                return DropdownButtonFormField(
                  value: provider.selectedBusiness,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  decoration: InputDecoration(
                      labelText: "Tax",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15))),
                  items: provider.businessList
                      .map((e) => DropdownMenuItem<TaxModel>(
                      value: e, child: Text(e.name)))
                      .toList(),
                  onChanged: (TaxModel? value) {
                    setState(() {
                      provider.setDropDownValue(value!);
                    });
                  },
                );
              }),
            ),

            service != "service"
                ? InkWell(
                    onTap: () {
                      _showDatePicker();
                    },
                    child: dateField("Enter Expiry date", "Expiry date",
                        TextInputType.datetime, expiryController),
                  )
                : Container(),
            service!= "service"
                ? duration("duration", "Expiry date", TextInputType.datetime,
                    durationController)
                : Container(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Product Images',
                style: TextStyle(
                    color: blackColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            InkWell(
              onTap: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(type: FileType.image);

                if (result != null) {
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
                  File file = File(result.files.single.path!);
                  FirebaseStorage storage = FirebaseStorage.instance;
                  Reference ref =
                      storage.ref().child("image" + DateTime.now().toString());
                  UploadTask uploadTask = ref.putFile(file);
                  uploadTask.then((res) async {
                    String url = await res.ref.getDownloadURL();
                    debugPrint(url);
                    setState(() {
                      image = url;
                    });

                    Navigator.pop(context);
                  });
                } else {
                  // User canceled the picker
                }
              },
              child: image == ""
                  ? SizedBox(
                      width: 50,
                      height: 50,
                      child: Container(
                        color: Colors.grey,
                        child: const Center(
                          child: Icon(Icons.add_a_photo_outlined),
                        ),
                      ),
                    )
                  : SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.network(image),
                    ),
            ),
            spacer(10),
            // Visibility(
            //     visible: !isService, child: columUserTextFileds("Duration")),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                    onTap: () {
                      SubCategoryModel? model =
                          Provider.of<SubCategoryProvider>(context,
                                  listen: false)
                              .selectedCategory;
                      model == null
                          ? errorLoader('Please select subcategory')
                          : _upload();
                    },
                    child: defaultButton(SizeConfig.screenWidth! * 0.5,
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
            ),
            spacer(10)
          ],
        ),
      ),
    );
  }
}

Widget duration(String label, String hint, TextInputType keyboard,
    TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    child: TextFormField(
      validator: (vval) {
        if (vval!.isEmpty) {
          return null;
        }
      },
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: blackColor),
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: blackColor),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          hintText: hint,
          hintStyle: const TextStyle(color: blackColor),
          filled: true,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: blackColor,
              width: 2.0,
            ),
          ),
          disabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor)),
          border: const UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor))),
    ),
  );
}

Widget dateField(String label, String hint, TextInputType keyboard,
    TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: blackColor),
      decoration: InputDecoration(
          labelText: label,
          enabled: false,
          labelStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: blackColor),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          hintText: hint,
          hintStyle: const TextStyle(color: blackColor),
          filled: true,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: blackColor,
              width: 2.0,
            ),
          ),
          disabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor)),
          border: const UnderlineInputBorder(
              borderSide: BorderSide(color: blackColor))),
    ),
  );
}
