import 'dart:developer';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fresh_new_one/componets.dart';
import 'package:fresh_new_one/screens/Desingation/provider/desingation_provider.dart';
import 'package:fresh_new_one/screens/customers/models/country_model.dart';
import 'package:fresh_new_one/screens/customers/provider/customer_provider.dart';
import 'package:fresh_new_one/screens/enquiry/model/appointmentsmodel.dart';
import 'package:fresh_new_one/screens/enquiry/model/timeslotmodel.dart';
import 'package:fresh_new_one/screens/enquiry/provider/appointment_provider.dart';
import 'package:fresh_new_one/screens/products/provider/products_provider.dart';
import 'package:fresh_new_one/screens/services/componets/select_product.dart';
import 'package:fresh_new_one/screens/services/componets/select_time_slot.dart';
import 'package:fresh_new_one/screens/user/models/user_model.dart';
import 'package:fresh_new_one/screens/user/provider/users_provider.dart';

import '../../../constants.dart';

class OrderProducts extends StatefulWidget {
  final AppointMentModel? model;
  const OrderProducts({Key? key,  this.model}) : super(key: key);

  @override
  _OrderProductsState createState() => _OrderProductsState();
}

class _OrderProductsState extends State<OrderProducts> {
  final name = TextEditingController();
  final age = TextEditingController();
  final phone = TextEditingController();
  final mail = TextEditingController();
  final address = TextEditingController();

  final time = TextEditingController();
  final proposed_fee = TextEditingController();
  final actual_fee = TextEditingController();
  final amount_paid = TextEditingController();
  final pending = TextEditingController();
  final main_consultant = TextEditingController();
  final in_consultant = TextEditingController();
  final rem_date = TextEditingController();
  final description = TextEditingController();
  final refferd = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DateTime? bookDate;
  TimeOfDay? bookTime;
  DateTime? reminderdate;
  Future<void> _showBookingRemPicker() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 360)));
    if (picked != null) {
      setState(() {
        rem_date.text = DateFormat("yyyy-MM-dd").format(picked);
        reminderdate = picked;
      });
    }
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 5, minute: 10));
    if (picked != null) {
      setState(() {
        time.text = picked.format(context);
        bookTime=picked;
      });
    }
  }



  bool  setedData=false;
  DateTime selectedDate = DateTime.now();
  String dropdownvalue = 'enquired';

  // List of items in our dropdown menu
  var items = ['enquired', 'advance paid', 'completed', 'canceled'];

  getDataForUpdate() async{

  actual_fee.text=widget.model!.customerFee.toString();
    var p= Provider.of<CustomerProvider>(context,listen: false);
    var a= Provider.of<UserProviderNew>(context,listen: false);
    var pr= Provider.of<ProductProvider>(context,listen: false);
    // p.setDropDownValue(await p.getCategoryListWithId(context, widget.model!.customer));
    a.setreferWithID(widget.model!.refferdBy!);
    a.setmainConsulatntWithId(widget.model!.mainConsultant);
    a.setiniConsultantWithId(widget.model!.initialConsultant);
    pr.gettemsWithListForUpdate(context: context,id: widget.model!.products);
    var psd= Provider.of<AppointmentProvider>(context,listen: false);
    psd.setBookDate(widget.model!.bookingDate);
    psd.setSlotSelect(await psd.getTimeSlotsWithId(context, widget.model!.slot));
    amount_paid.text=widget.model!.amountPaid.toString();
    pending.text=widget.model!.dueAmount.toString();
    rem_date.text=DateFormat("yyyy-MM-dd").format(widget.model!.reminderDate);
    description.text=widget.model!.notes;
    psd.setSel(widget.model!.status!);
    setState(() {
      setedData=true;

    });
  }

  @override
  void initState() {
    if(widget.model!=null){
      log("selected status ${widget.model!.toJson()}");
      // name.text=widget._model.;
      // date.text=DateFormat("yyyy-MM-dd").format(widget.model!.bookingDate);
      bookDate=widget.model!.bookingDate;

    }

    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Provider.of<CustomerProvider>(context, listen: false).emptyDropdown();
      Provider.of<ProductProvider>(context, listen: false)
          .emptyAppointmentList();
      Provider.of<CustomerProvider>(context, listen: false)
          .getCategoryList(context);
      // Provider.of<DesignationProvider>(context, listen: false)
      //     .getBusinessList(context);
      Provider.of<UserProviderNew>(context, listen: false)
          .setRefer(null);
      Provider.of<UserProviderNew>(context, listen: false)
          .setiniConsultant(null);
      Provider.of<UserProviderNew>(context, listen: false)
          .setmainConsulatnt(null);
      Provider.of<UserProviderNew>(context, listen: false)
          .getBusinessList(context);
      Provider.of<AppointmentProvider>(context, listen: false)
          .setSlotSelect(null);
      var p= Provider.of<AppointmentProvider>(context,listen: false);
      p.setBookDate(null);

      if(widget.model!=null){
        getDataForUpdate();
      }

      // proposed_fee.text=widget.model!.proposedFee.toString();
    });
  }
  errorLoader(String message){
    showDialog(
      context: context,

      builder: (BuildContext context) {
        return Dialog(
          child:  SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [


                    Text(message),
                  ],
                ),
                spacer(10),
                InkWell(
                    onTap: ()=>Navigator.pop(context),
                    child: defaultButton(100, 'Ok'))
                
              ],
            ),
          ),
        );
      },
    );
  }
  Widget selectedDateTime(){
    return Consumer<AppointmentProvider>(

        builder: (context, snapshot,child) {
          return Padding(
            padding:const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(10)
              ),
              child:snapshot.selectedSlot==null||snapshot.selectedBookDate==null?Container(): ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>widget.model==null?const SelectDateAndTimeSlot():SelectDateAndTimeSlot(bookDate: widget.model!.bookingDate,)));
                },
                title: Text(DateFormat("yyyy-MM-dd").format(snapshot.selectedBookDate!),style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),) ,
                // subtitle: Text(model.is_product!=null?model.is_product!?"product":"service":"",style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                trailing: Text(snapshot.selectedSlot==null?"": snapshot.selectedSlot!.slot),
                selectedTileColor: Colors.blue.shade300,

              ),
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: appBar("Appointments", [], context),
      body:widget.model!=null&&!setedData?const Center(child: CircularProgressIndicator(),): SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
          key: formKey,
          child: Column(
            children: [
              widget.model!=null?Container():  const HeadText(txt: 'Select customer'),
              widget.model!=null?Container():  spacer(10),
              widget.model!=null?Container():    Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 25),
                child: Consumer<CustomerProvider>(
                    builder: (context, provider, child) {
                  return DropdownButtonFormField(
                    validator: (val){
                      if(val==null || val==""){
                        return "Please select customer";
                      }
                    },
                    value: provider.selectedCategory,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    decoration:
                        defaultDecoration("Select Customer", "Select Customer"),
                    items: provider.customerList
                        .map((e) => DropdownMenuItem<CustomerModel>(
                            value: e, child: Text(e.name!,style:const TextStyle(color: Colors.pinkAccent))))
                        .toList(),
                    onChanged: (CustomerModel? value) {
                      FocusScope.of(context).requestFocus(FocusNode());
                      provider.setDropDownValue(value!);
                    },
                  );
                }),
              ),
              widget.model!=null?Container():  InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, customers);
                  },
                  child: const Text(
                    "Not listed?. add here",
                    style: TextStyle(color: Colors.blue),
                  )),
              spacer(10),
              const HeadText(txt: 'Select Booking Date'),
              spacer(10),
              Consumer<AppointmentProvider>(

                builder: (context,snap,child) {
                  return snap.selectedBookDate==null||snap.selectedSlot==null? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ArgonButton(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.6,
                      borderRadius: 5.0,
                      color: const Color(0xFF7866FE),
                      child: const Text(
                        "Select date and time slot",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      loader: Container(
                        padding: const EdgeInsets.all(10),
                        child: const SpinKitRotatingCircle(
                          color: Colors.white,
                          // size: loaderWidth ,
                        ),
                      ),
                      onTap: (startLoading, stopLoading, btnState) {
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>widget.model==null?const SelectDateAndTimeSlot():SelectDateAndTimeSlot(bookDate: widget.model!.bookingDate,)));
                      },
                    ),
                  ):selectedDateTime();
                }
              )


              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              //   child: DropdownButtonFormField(
              //     // Initial Value
              //     value: refferd,
              //     decoration: InputDecoration(
              //         labelText: "Referred By",
              //         floatingLabelBehavior: FloatingLabelBehavior.auto,
              //         border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(15))),
              //     // Down Arrow Icon
              //     icon: const Icon(Icons.keyboard_arrow_down),

              //     // Array list of items
              //     items: staffs.map((String items) {
              //       return DropdownMenuItem(
              //         value: items,
              //         child: Text(items),
              //       );
              //     }).toList(),
              //     // After selecting the desired option,it will
              //     // change button value to selected value
              //     onChanged: (String? newValue) {
              //       setState(() {
              //         refferd = newValue!;
              //       });
              //     },
              //   ),
              // ),,
              ,spacer(10),
              const HeadText(txt: 'Select Internal details'),
              spacer(10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 25),
                child:
                Consumer<UserProviderNew>(builder: (context, provider, child) {
                  return DropdownButtonFormField(
                    validator: (val){
                      if(val==null || val==""){
                        return "please select";
                      }
                    },
                    value: provider.refer,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    decoration: defaultDecoration(
                        "Referred by", "Select staff"),
                    items: provider.userList
                        .map((e) => DropdownMenuItem<UserModel>(
                        value: e, child: Text(e.name!,style:const TextStyle(color: Colors.pinkAccent))))
                        .toList(),
                    onChanged: (UserModel? value) {
                      setState(() {
                        provider.setRefer(value!);
                      });
                    },
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 25),
                child:
                Consumer<UserProviderNew>(builder: (context, provider, child) {
                  return DropdownButtonFormField(
                      validator: (val){
                        if(val==null || val==""){
                          return "please select";
                        }
                        return null;
                      },
                      value: provider.selectedinitalDocter,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      decoration: defaultDecoration(
                          "Initial consultant", "Select doctor"),
                      items: provider.userList
                          .map((e) => DropdownMenuItem<UserModel>(
                          value: e, child: Text(e.name!,style:const TextStyle(color: Colors.pinkAccent),)))
                          .toList(),
                      onChanged: (UserModel? value) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        provider.setiniConsultant(value!);
                      });
                }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 25),
                child:
                Consumer<UserProviderNew>(builder: (context, provider, child) {
                  return DropdownButtonFormField(
                    validator: (val){
                      if(val==null || val==""){
                        return "please select";
                      }
                    },
                    value: provider.selectedmainDocter,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    decoration: defaultDecoration(
                        "Main consultant", "Select doctor"),
                    items: provider.userList
                        .map((e) => DropdownMenuItem<UserModel>(
                        value: e, child: Text(e.name!,style:const TextStyle(color: Colors.pinkAccent))))
                        .toList(),
                    onChanged: (UserModel? value) {
                      FocusScope.of(context).requestFocus(FocusNode());
                      setState(() {
                        provider.setmainConsulatnt(value!);
                      });
                    },
                  );
                }),
              ),
              spacer(10),
              const HeadText(txt: ' Product and fee'),
              spacer(10),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                Color(0xFF0D47A1),
                                Color(0xFF1976D2),
                                Color(0xFF42A5F5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(8.0),
                          primary: Colors.white,
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            useRootNavigator: true,
                            builder: (context) {
                              return const ProductListAppointment();
                            },
                          );
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.add),
                            Text('Select Treatments')
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child:Consumer<ProductProvider>(

                      builder: (context, snapshot,child) {
                        return  snapshot.selectedListForAppoint.isEmpty?const Center(child:  Text("No products selected",style: TextStyle(color: Colors.white),),):
                        ListView.builder(
                          physics:const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.selectedListForAppoint.length,
                            itemBuilder: (context,index){
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ProductListItemAppointPage(model: snapshot.selectedListForAppoint[index]),
                              );
                            }
                        );
                      }
                  ),),
              ),
              Consumer<ProductProvider>(

                builder: (context, snapshot,child) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      proposed_fee.text=snapshot.totalPrice.toString();
    });

                  return proposedFee(
                      "Proposed fee", "proposed fee", TextInputType.number, proposed_fee);
                }
              ),
              RawKeyboardListener(
                onKey: (event){
                  if(event.logicalKey==LogicalKeyboardKey.backspace){
                    amount_paid.text="";
                  }
                },
                focusNode: FocusNode(),
                child: customerFee(
                    "Confirmed fee", "Confirmed fee", TextInputType.number, actual_fee),
              ),
              amountPaid(
                  "Amount Paid", "Amount Paid", TextInputType.number, amount_paid),
              dueAmount(
                  "Due amount", "Due amount", TextInputType.number, pending),
              spacer(10),
              const HeadText(txt: ' Reminder and notes'),
              spacer(10),
              InkWell(
                  onTap: () {
                    _showBookingRemPicker();
                  },
                  child: dateFiled("reminder date", "reminder",
                      TextInputType.none, rem_date))
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              //   child: DropdownButtonFormField(
              //     // Initial Value
              //     value: doctorSel,
              //     decoration: InputDecoration(
              //         labelText: "Initial consultant",
              //         floatingLabelBehavior: FloatingLabelBehavior.auto,
              //         border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(15))),
              //     // Down Arrow Icon
              //     icon: const Icon(Icons.keyboard_arrow_down),

              //     // Array list of items
              //     items: doctors.map((String items) {
              //       return DropdownMenuItem(
              //         value: items,
              //         child: Text(items),
              //       );
              //     }).toList(),
              //     // After selecting the desired option,it will
              //     // change button value to selected value
              //     onChanged: (String? newValue) {
              //       setState(() {
              //         doctorSel = newValue!;
              //       });
              //     },
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              //   child: DropdownButtonFormField(
              //     // Initial Value
              //     value: doctorSel,
              //     decoration: InputDecoration(
              //         labelText: "Main consultant",
              //         floatingLabelBehavior: FloatingLabelBehavior.auto,
              //         border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(15))),
              //     // Down Arrow Icon
              //     icon: const Icon(Icons.keyboard_arrow_down),

              //     // Array list of items
              //     items: doctors.map((String items) {
              //       return DropdownMenuItem(
              //         value: items,
              //         child: Text(items),
              //       );
              //     }).toList(),
              //     // After selecting the desired option,it will
              //     // change button value to selected value
              //     onChanged: (String? newValue) {
              //       setState(() {
              //         doctorSel = newValue!;
              //       });
              //     },
              //   ),
              // ),
              ,


              notes(
                  "Notes", " description", TextInputType.multiline, description),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text("Status :",style: TextStyle(color: whiteColor),),
                    const SizedBox(
                      width: 10,
                    ),
                    Consumer<AppointmentProvider>(
                      builder: (context,snap,child) {
                        return DropdownButton(
                          // Initial Value
                          value: snap.dropDownvalue,

                          // Down Arrow Icon
                          icon: const Icon(Icons.keyboard_arrow_down),

                          // Array list of items
                          items: items.map((String items) {

                            return DropdownMenuItem(
                              value: items,
                              child: Container(
                                height: 40,

                                  child: Center(child: Text(items,style: const TextStyle(color: Colors.pink),))),
                            );
                          }).toList(),
                          // After selecting the desired option,it will
                          // change button value to selected value
                          onChanged: (String? newValue) {

                            FocusScope.of(context).requestFocus(FocusNode());
                            switch (newValue) {
                              case "enquired":

                                      snap.setSel("E");



                                break;
                              case "advance paid":
                                snap.setSel("A");
                                break;
                              case "completed":
                                snap.setSel("C");
                                break;
                              case "canceled":
                                snap.setSel("F");
                                break;
                            }

                          },
                        );
                      }
                    ),

                  ],
                ),
              ),
              spacer(10),
              InkWell(onTap: () async {
                
                if(widget.model!=null){
                  if (formKey.currentState!.validate()) {
                    print("++++++++++++++++++++++++++++++wrrr+++++");
                    Iterable<int> product=Provider.of<ProductProvider>(context,listen: false).selectedListForAppoint.map((e) => e.id!);
                    print(product);
                    if(product.isEmpty){
                      ScaffoldMessenger.of(context


                      ).showSnackBar(const SnackBar(content: Text('please select products/services',style: TextStyle(color: Colors.white),),));
                    }else{

                      Timeslots? tmwSlot=Provider.of<AppointmentProvider>(context, listen: false).selectedSlot;
                      String seld=Provider.of<AppointmentProvider>(context, listen: false).sel;
                      UserModel? refer=Provider.of<UserProviderNew>(context, listen: false).refer;
                      UserModel? initconsultant=Provider.of<UserProviderNew>(context, listen: false).selectedinitalDocter;
                      UserModel? miancon=Provider.of<UserProviderNew>(context, listen: false).selectedmainDocter;
                      DateTime? bookedDate=Provider.of<AppointmentProvider>(context, listen: false).selectedBookDate;
                      if( bookedDate!=null&&refer!=null&&initconsultant!=null&&miancon!=null){
                        // DateTime bookdate= DateTime(bookDate!.year,bookDate!.month,bookDate!.day,bookTime!.hour,bookTime!.minute);

                        AppointMentModel model = AppointMentModel(
                          id: widget.model!.id,

                            bookingDate: bookedDate,
                            proposedFee: double.parse(proposed_fee.text),
                            customerFee: double.parse(actual_fee.text),
                            amountPaid: double.parse(amount_paid.text),
                            dueAmount: double.parse(pending.text),
                            reminderDate: reminderdate==null?widget.model!.reminderDate:reminderdate!,
                            notes: description.text,
                            customer: widget.model!.customer,
                            initialConsultant: initconsultant.id!,
                            mainConsultant: miancon.id!,
                            refferdBy:refer.id,
                            status: seld,
                            products: product.toList(), slot: tmwSlot==null?widget.model!.slot:tmwSlot.id);
                          print(model.toJson());

                        Provider.of<AppointmentProvider>(context, listen: false)
                            .updateCategory(context,model);

                      }else{
                        print("+++++++++++++++++++++++++++++++++++");
                        if(refer==null){
                          errorLoader('Please Select referred');
                        }else if(initconsultant==null){
                          errorLoader('Please Select initial consultant');
                        }else if(miancon==null){
                          errorLoader('Please Select main consultant');
                        }else{
                          errorLoader('Please Select time slot');
                        }

                      }


                    }
                  }else{
                    errorLoader("Please select details");
                  }
                }else{
                  if (formKey.currentState!.validate()) {
                    print("++++++++++++++++++++++++++++++wrrr+++++");
                    Iterable<int> product=Provider.of<ProductProvider>(context,listen: false).selectedListForAppoint.map((e) => e.id!);
                    if(product.isEmpty){
                      ScaffoldMessenger.of(context


                      ).showSnackBar(const SnackBar(content: Text('please select products/services',style: TextStyle(color: Colors.white),),));
                    }else{
                      var selec_customer =
                          Provider.of<CustomerProvider>(context, listen: false)
                              .selectedCategory;
                      Timeslots? tmwSlot=Provider.of<AppointmentProvider>(context, listen: false).selectedSlot;
                      print("selected slot${tmwSlot}");
                      UserModel? refer=Provider.of<UserProviderNew>(context, listen: false).refer;
                      String seld=Provider.of<AppointmentProvider>(context, listen: false).sel;
                      UserModel? initconsultant=Provider.of<UserProviderNew>(context, listen: false).selectedinitalDocter;
                      UserModel? miancon=Provider.of<UserProviderNew>(context, listen: false).selectedmainDocter;
                      DateTime? bookedDate=Provider.of<AppointmentProvider>(context, listen: false).selectedBookDate;
                      if(tmwSlot!=null&& bookedDate!=null&&refer!=null&&initconsultant!=null&&miancon!=null){
                        // DateTime bookdate= DateTime(bookDate!.year,bookDate!.month,bookDate!.day,bookTime!.hour,bookTime!.minute);

                        AppointMentModel model = AppointMentModel(
                            bookingDate: bookedDate,
                            proposedFee: double.parse(proposed_fee.text),
                            customerFee: double.parse(actual_fee.text),
                            amountPaid: double.parse(amount_paid.text),
                            dueAmount: double.parse(pending.text),
                            reminderDate: reminderdate!,
                            notes: description.text,
                            customer: selec_customer!.id!,
                            initialConsultant: initconsultant.id!,
                            mainConsultant: miancon.id!,
                            refferdBy:refer.id,
                            status: seld,
                            products: product.toList(), slot: tmwSlot.id);

                        Provider.of<AppointmentProvider>(context, listen: false)
                            .addCategory(model, context);

                      }else{
                        print("+++++++++++++++++++++++++++++++++++");
                        if(refer==null){
                          errorLoader('Please Select referred');
                        }else if(initconsultant==null){
                          errorLoader('Please Select initial consultant');
                        }else if(miancon==null){
                          errorLoader('Please Select main consultant');
                        }else{
                          errorLoader('Please Select time slot');
                        }

                      }


                    }
                  }else{
                    errorLoader("Please select details");
                  }
                }
                
              }, child: Consumer<AppointmentProvider>(
                  builder: (context, snapshot, child) {
                return snapshot.loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : defaultButton(300,widget.model!=null?"Update Appointment": "Book Appointment");
              })),
              spacer(20),
            ],
          ),
        ),
      ),
    );

  }

  Widget notes(String label, String hint, TextInputType keyboard,
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
        maxLines: 3,
        onChanged: (val){




        },

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

  Widget proposedFee(String label, String hint, TextInputType keyboard,
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
        onChanged: (val){




        },
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
  Widget customerFee(String label, String hint, TextInputType keyboard,
      TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return "Please Enter value for $hint";
          }else if(double.parse(value) > double.parse(proposed_fee.text)){
            return " value must be less than proposed fee";
          }
          return null;
        },
        controller: controller,
        keyboardType: keyboard,
        onChanged: (val){




        },
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
  Widget amountPaid(String label, String hint, TextInputType keyboard,
      TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return "Please Enter value for $hint";
          }else if(double.parse(value) > double.parse(actual_fee.text)){
            return " value must be less than customer fee";
          }
          return null;
        },
        controller: controller,
        keyboardType: keyboard,
        onChanged: (val){
          if(double.parse(actual_fee.text)>=double.parse(amount_paid.text)) {
            setState(() {
              pending.text="${double.parse(actual_fee.text)-double.parse(amount_paid.text)}";
            });
          }
        },
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

  Widget dueAmount(String label, String hint, TextInputType keyboard,
      TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return "Please Enter value for $hint";
          }else if(double.parse(value) > double.parse(proposed_fee.text)){
            return " value must be less than proposed fee";
          }
          return null;
        },
        enabled: false,
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
}

Widget dateFiled(String label, String hint, TextInputType keyboard,
    TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    child: TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Please select value for $hint";
        }
        return null;
      },
      enabled: false,
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
class TimeSlotList extends StatelessWidget {
  final String date;
  const TimeSlotList({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<AppointmentProvider>(
          builder: (_,snap,child){
            return snap.slots.isEmpty?const Center(child: Text('No time slot found for the selectede date'),) : GridView.builder(
              itemCount: snap.slots.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: (){
                      snap.setSlotSelect(snap.slots[index]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: snap.selectedSlot!=null&&snap.selectedSlot!.id==snap.slots[index].id?Colors.lightBlue.shade400: Colors.pinkAccent.shade400,
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Center(child: Text(snap.slots[index].slot,style: const TextStyle(color: Colors.white),),),

                  ),
                );

              }, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              childAspectRatio: 3/1
            ),
            );
          }
      ),
    );
  }
}
class HeadText extends StatelessWidget {
  final String txt;
  const HeadText({Key? key, required this.txt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(child: Text(txt,style: const TextStyle(color: Colors.white,fontSize: 20),),),
    );
  }
}
