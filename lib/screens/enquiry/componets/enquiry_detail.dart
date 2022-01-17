import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:fresh_new_one/componets.dart';
import 'package:fresh_new_one/screens/customers/models/country_model.dart';
import 'package:fresh_new_one/screens/customers/provider/customer_provider.dart';
import 'package:fresh_new_one/screens/enquiry/componets/due_edit.dart';
import 'package:fresh_new_one/screens/enquiry/model/appointmentsmodel.dart';
import 'package:fresh_new_one/screens/enquiry/model/timeslotmodel.dart';
import 'package:fresh_new_one/screens/enquiry/provider/appointment_provider.dart';
import 'package:fresh_new_one/screens/products/provider/products_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';

class AppointmentDetail extends StatefulWidget {
  final AppointMentModel model;
  const AppointmentDetail({Key? key,required this.model}) : super(key: key);

  @override
  State<AppointmentDetail> createState() => _AppointmentDetailState();
}

class _AppointmentDetailState extends State<AppointmentDetail> {
  String dropdownvalue = 'enquired';
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  // List of items in our dropdown menu
  var items = ['enquired', 'advance paid', 'completed', 'canceled'];
  bool visible=false;
  @override
  void initState() {

    print(widget.model.toJson());

    switch (widget.model.status) {
      case "P":
        setState(() {
          print("==================e");
          dropdownvalue = "enquired";
        });

        break;
      case "E":
        setState(() {
          print("==================e");
          dropdownvalue = "enquired";
        });

        break;
      case "A":
        setState(() {
          print("==================ap");
          dropdownvalue = "advance paid";
        });
        break;
      case "C":
        setState(() {
          print("==================c");
          dropdownvalue = "completed";
        });
        break;
      case "F":
        setState(() {
          print("==================f");
          dropdownvalue = "canceled";
        });
        break;
    }
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      Provider.of<ProductProvider>(context,listen: false).gettemsWithList(context: context, id: widget.model.products);
      print('=====================${widget.model.products}===========================');
    });

  }
  void _printScreen() {
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      final doc = pw.Document();

      final image = await WidgetWraper.fromKey(
        key: _printKey,
        pixelRatio: 2.0,
      );

      doc.addPage(pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Expanded(
                child: pw.Image(image),
              ),
            );
          }));

      return doc.save();
    });
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
     body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: RepaintBoundary(
            key: _printKey,

            child: Column(
              children: [
                FutureBuilder(
                  future: Provider.of<CustomerProvider>(context,listen: false).getCategoryListWithId(context, widget.model.customer),
                  builder: (_,snapshot) {
                   if(snapshot.hasData){
                      CustomerModel? data =snapshot.data as CustomerModel?;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Customer details',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
                          ),
                          SizedBox(
                              width:150,
                              height: 150,
                              child: Image.network(data!.image==null?"":data.image!)),
                          DetailCard(head: 'Name', value: data.name!),
                          DetailCard(head: 'Address', value: data.address),
                          DetailCard(head: 'Phone', value: data.phone),
                          DetailCard(head: 'Email', value: data.mail),
                          DetailCard(head: 'City', value: data.city),
                          DetailCard(head: 'Insurance company', value: data.insurance_comapny),
                          DetailCard(head: 'Insurance number', value: data.insurance_num),
                          DetailCard(head: 'Insurance expiry date', value: data.insurance_expiry),
                        ],
                      );
                  }else{
                     return const CircularProgressIndicator();
                   }
                }
              ),
                spacer(20),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Selected services',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
                ),
                spacer(10),
                Consumer<ProductProvider>(
                    builder: (_,snap,child){
                    return snap.selectedListForAppointGet.isEmpty?const Center(child: CircularProgressIndicator(),):
                        ListView.builder(
                          physics:const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                            itemCount: snap.selectedListForAppointGet.length,
                            itemBuilder:(_,index){
                              return ListTile(title: Text(snap.selectedListForAppointGet[index].name,style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),subtitle: Text(snap.selectedListForAppointGet[index].is_product!?"Product":"Service"),trailing: Text(snap.selectedListForAppointGet[index].mrp.toString()),);
                            }
                        );
                }),
                spacer(20),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Appointment details',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
                ),
                DetailCard(head: 'Proposed fee', value: widget.model.proposedFee.toString()),
                DetailCard(head: 'Customer fee', value: widget.model.customerFee.toString()),

                DetailCard(head: 'Amount paid', value: widget.model.amountPaid.toString(),),
                DetailCard(head: 'Due amount', value: widget.model.dueAmount.toString()),
               DetailCard(head: 'Booked date', value: '${widget.model.bookingDate.day}-${widget.model.bookingDate.month}-${widget.model.bookingDate.year}',),
                // widget.model.status == "F"?DetailCard(head: 'Booked Time', value: DateFormat.jm().format(DateFormat("hh:mm:ss").parse('${widget.model.bookingDate.hour}:${widget.model.bookingDate.minute}:00')),): DetailCardWithEdit(head: 'Booked time', value:DateFormat.jm().format(DateFormat("hh:mm:ss").parse('${widget.model.bookingDate.hour}:${widget.model.bookingDate.minute}:00')),edit: true,model: widget.model),
                FutureBuilder(
                    future: Provider.of<AppointmentProvider>(context,listen: false).getTimeSlotsWithId(context, widget.model.slot),
                    builder: (context,data) {
                      if(data.hasData){
                        Timeslots t=data.data as Timeslots;
                        return DetailCard(head: 'Booked Time', value: t.slot,);
                      }else{
                        return const Center(child: CircularProgressIndicator(),);
                      }
                    }
                ),
                DetailCard(head: 'Status',value: dropdownvalue,),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     const Text("Status :"),
                //     const SizedBox(
                //       width: 10,
                //     ),
                //     DropdownButton(
                //       // Initial Value
                //       value: dropdownvalue,
                //
                //       // Down Arrow Icon
                //       icon: const Icon(Icons.keyboard_arrow_down),
                //
                //       // Array list of items
                //       items: items.map((String items) {
                //         log("${widget.model.status}===========================$dropdownvalue");
                //         return DropdownMenuItem(
                //           value: items,
                //           child: Text(items),
                //         );
                //       }).toList(),
                //       // After selecting the desired option,it will
                //       // change button value to selected value
                //       onChanged: (String? newValue) {
                //         switch (newValue) {
                //           case "enquired":
                //             widget.model.status = "E";
                //             break;
                //           case "advance paid":
                //             widget.model.status = "A";
                //             break;
                //           case "completed":
                //             widget.model.status = "C";
                //             break;
                //           case "canceled":
                //             widget.model.status = "F";
                //             break;
                //         }
                //
                //         Provider.of<AppointmentProvider>(context,
                //             listen: false)
                //             .updateCategory(context, widget.model);
                //       },
                //     ),
                //
                //   ],
                // ),
                spacer(20),
                InkWell(
                  onTap: (){
                    print('df');
                      setState(() {
                        visible=!visible;
                      });
                    _printScreen();
                  },
                    child: Visibility(
                        visible: !visible,
                        child: defaultButton(300, 'Print')))

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetailCard extends StatelessWidget {
  final String head;
  final String value;
  final bool? edit;
  const DetailCard({Key? key,required this.head,required this.value, this.edit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('$head :',style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('$value ',style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
        ),


      ],
    );
  }
}

class DetailCardWithEdit extends StatefulWidget {
  final String head;
  final String value;
  final AppointMentModel model;
  final bool? edit;
  const DetailCardWithEdit({Key? key,required this.head,required this.value, this.edit,required this.model}) : super(key: key);

  @override
  State<DetailCardWithEdit> createState() => _DetailCardWithEditState();
}

class _DetailCardWithEditState extends State<DetailCardWithEdit> {
  String? v;
  TimeOfDay? bookTime;
  DateTime? bookDate;
  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 5, minute: 10));
    if (picked != null) {
      setState(() {

        bookTime=picked;
        DateTime bookdate= DateTime(widget.model.bookingDate.year,widget.model.bookingDate.month,widget.model.bookingDate.day,bookTime!.hour,bookTime!.minute);
        setState(() {
          widget.model.bookingDate=bookdate;
          String selTime =
              bookdate.hour.toString() + ':' + bookdate.minute.toString() + ':00';
          v=DateFormat.jm().format(DateFormat("hh:mm:ss").parse(selTime));
        });
        Provider.of<AppointmentProvider>(context,listen: false).updateCategory(context, widget.model);

      });
    }
  }

  Future<void> _showBookingPicker() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 360)));
    if (picked != null) {

        bookDate=picked;
        DateTime bookdate= DateTime(bookDate!.year,bookDate!.month,bookDate!.day,widget.model.bookingDate.hour,widget.model.bookingDate.minute);
       setState(() {
         widget.model.bookingDate=bookdate;
         v='${widget.model.bookingDate.day}-${widget.model.bookingDate.month}-${widget.model.bookingDate.year}';

       });
        Provider.of<AppointmentProvider>(context,listen: false).updateCategory(context, widget.model);

    }
  }

  @override
  Widget build(BuildContext context) {

    void showAlertDelete1(BuildContext _context) {
      showModalBottomSheet(

          context: _context,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          builder: (_) {
            return Padding(
              padding:  EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Wrap(
                children:  [DueEdit(model: widget.model)],
              ),
            );
          });
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('${widget.head} :',style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(v==null?'${widget.value} ':v!,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
        ),
        widget.edit==null?Container():InkWell(
          onTap: (){
           if(widget.head=="Amount paid"){
             showAlertDelete1(context);
           }else if(widget.head=="Booked date"){
             _showBookingPicker();
           }else{
             _showTimePicker();
           }

          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              'assets/icons/edit.svg',
              width: 20,
              height: 20,
              color: Colors.black,
            ),
          ),
        ),

      ],
    );
  }
}
