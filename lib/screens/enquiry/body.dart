import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:fresh_new_one/screens/customers/models/country_model.dart';
import 'package:fresh_new_one/screens/customers/provider/customer_provider.dart';
import 'package:fresh_new_one/screens/enquiry/componets/enquiry_detail.dart';

import 'package:fresh_new_one/screens/enquiry/model/appointmentsmodel.dart';
import 'package:fresh_new_one/screens/enquiry/model/timeslotmodel.dart';
import 'package:fresh_new_one/screens/enquiry/provider/appointment_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fresh_new_one/screens/services/componets/order.dart';
import 'package:uuid/uuid.dart';

import '../../componets.dart';
import '../../constants.dart';

class Enquiry extends StatefulWidget {
  const Enquiry({Key? key}) : super(key: key);

  @override
  State<Enquiry> createState() => _EnquiryState();
}

class _EnquiryState extends State<Enquiry> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Provider.of<AppointmentProvider>(context, listen: false)
          .getCategoryList(context);
      var p = Provider.of<AppointmentProvider>(context, listen: false);
      p.unFilterList(context);
    });
  }

  showFilterAndSortSheet() async {
    var p = Provider.of<AppointmentProvider>(context, listen: false);
    p.clearTempList();
    await showModalBottomSheet(
      isScrollControlled: true, // required for min/max child size
      context: context,
      builder: (ctx) {
        return MultiSelectBottomSheet(
          items: items.map((e) => MultiSelectItem(e, e)).toList(),
          initialValue: null,
          onConfirm: (List<String> values) {
            if (values.isNotEmpty) {
              for (var element in values) {
                switch (element) {
                  case "enquired":
                    p.filterListWithEnquired();

                    break;
                  case 'advance paid':
                    p.filterListWithAdvancePaid();

                    break;
                  case 'completed':
                    p.filterListWithCompleted();

                    break;
                  case 'canceled':
                    p.filterListWithCanceled();

                    break;
                  case 'remove filters':
                    p.unFilterList(context);

                    break;
                }
              }
            }
          },
          initialChildSize: 0.8,
          maxChildSize: 0.8,
        );
      },
    );
  }

  bool tap = false;
  List<String> selectedItem = [];
  List<String> sortItemList = [
    "Sort by ascending booking date",
    "Sort by descending booking date"
  ];
  var items = [
    'enquired',
    'advance paid',
    'completed',
    'canceled',
    'remove filters'
  ];
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: appBar("Appointments", [], context),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // columUserTextFileds("search","",TextInputType.name,TextEditingController()),
            spacer(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () async {
                    var p = Provider.of<AppointmentProvider>(context,
                        listen: false);
                    await showModalBottomSheet(
                      isScrollControlled:
                          true, // required for min/max child size
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      builder: (ctx) {
                        return Wrap(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const Text(
                                  'Sort',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Container(
                                        alignment: Alignment.topCenter,
                                        margin: const EdgeInsets.all(4),
                                        child: ChoiceChip(
                                          backgroundColor:
                                              Colors.lightBlueAccent.shade200,
                                          label: const Text(
                                            "Sort by booking date ascending",
                                            style: TextStyle(color: whiteColor),
                                          ),
                                          selected: true,
                                          disabledColor: Colors.black,
                                          onSelected: (bool value) {
                                            p.sortAscendingByDate();
                                            Navigator.pop(context);
                                          },
                                          pressElevation: 20,
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topCenter,
                                        margin: const EdgeInsets.all(4),
                                        child: ChoiceChip(
                                          backgroundColor:
                                              Colors.lightBlueAccent.shade200,
                                          label: const Text(
                                              "Sort by booking date descending",
                                              style:
                                                  TextStyle(color: whiteColor)),
                                          selected: true,
                                          onSelected: (bool value) {
                                            p.sortDescendingByDate();
                                            Navigator.pop(context);
                                          },
                                          pressElevation: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 100,
                          )
                        ]);
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: const [Text("sort by"), Icon(Icons.sort)],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    showFilterAndSortSheet();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: const [
                        Text("Filter"),
                        Icon(Icons.filter_list_alt)
                      ],
                    ),
                  ),
                )
              ],
            ),
            const Divider(),
            spacer(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ClipRRect(
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
                          Navigator.pushNamed(context, order);
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.add),
                            Text('Book appointment')
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Consumer<AppointmentProvider>(builder: (context, snapshot, child) {
              print(snapshot.tempList.length);
              return ListView.builder(
                  itemCount: snapshot.tempList.isEmpty
                      ? snapshot.categoryList.length
                      : snapshot.tempList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, index) {
                    return EnquiryCustomer(
                      model: snapshot.tempList.isEmpty
                          ? snapshot.categoryList[index]
                          : snapshot.tempList[index],
                    );
                  });
            })
          ],
        ),
      ),
    );
  }
}

class EnquiryCustomer extends StatefulWidget {
  final AppointMentModel model;
  const EnquiryCustomer({Key? key, required this.model}) : super(key: key);

  @override
  State<EnquiryCustomer> createState() => _EnquiryCustomerState();
}

class _EnquiryCustomerState extends State<EnquiryCustomer> {
  String dropdownvalue = 'enquired';

  // List of items in our dropdown menu
  var items = ['enquired', 'advance paid', 'completed', 'canceled'];
  DateTime? today;
  CustomerModel? customerModel;
  bool is_appointmentToday = false;
  bool is_appointmentTommarrow = false;
  String timeSlot = "";
  @override
  void initState() {
    today = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String todayDate = formatter.format(today!);
    final now = DateTime.now();
    String tomorrow =
        formatter.format(DateTime(now.year, now.month, now.day + 1));
    String bookdate = formatter.format(widget.model.bookingDate);
    if (todayDate == bookdate) {
      setState(() {
        is_appointmentToday = true;
      });
    } else if (tomorrow == bookdate) {
      setState(() {
        is_appointmentTommarrow = true;
      });
    }

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
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

      customerModel =
          await Provider.of<CustomerProvider>(context, listen: false)
              .getCategoryListWithId(context, widget.model.customer);
      if (this.mounted) {
        setState(() {
          customerModel;
        });
      }

    });
  }

  writePdf() async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text("customer name : ${customerModel!.name}"),
                pw.SizedBox(height: 10),
                pw.Text("customer phone : ${customerModel!.phone}"),
                pw.SizedBox(height: 10),
                pw.Text("customer address : ${customerModel!.address}"),
                pw.SizedBox(height: 10),
                pw.Text("status : $dropdownvalue"),
                pw.SizedBox(height: 10),
                pw.Text(
                    "booking date : ${widget.model.bookingDate.day}-${widget.model.bookingDate.month}-${widget.model.bookingDate.year}"),
                pw.Text("booking time : $timeSlot")
              ]); // Center
        }));
    Uuid uuid = Uuid();
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/Recipt${uuid.v1()}.pdf");
    print(file.absolute);
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return customerModel == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.99,
                  decoration: BoxDecoration(
                      color: widget.model.status == "F"
                          ? Colors.red.shade300
                          : secondrayColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                customerModel!.name!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            Text(
                                'created date :${widget.model.bookingDate.day}-${widget.model.bookingDate.month}-${widget.model.bookingDate.year}')
                          ],
                        ),
                      ),
                      spacer(10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            BookDateCard(
                                head: 'Booked Date',
                                tail:
                                    ' ${widget.model.bookingDate.day}-${widget.model.bookingDate.month}-${widget.model.bookingDate.year}'),
                            spacer(10),
                            FutureBuilder(
                                future: Provider.of<AppointmentProvider>(
                                        context,
                                        listen: false)
                                    .getTimeSlotsWithId(
                                        context, widget.model.slot),
                                builder: (context, data) {
                                  if (data.hasData) {
                                    Timeslots t = data.data as Timeslots;
                                    timeSlot = t.slot;
                                    return BookDateCard(
                                        head: 'Booked Time', tail: t.slot);
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                }),
                          ],
                        ),
                      ),
                      spacer(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Status :",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            dropdownvalue,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => AppointmentDetail(
                                            model: widget.model,
                                          )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.red.shade600,
                                    borderRadius: BorderRadius.circular(5)),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "View details",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(2.0),
                            primary: Colors.white,
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => OrderProducts(
                                          model: widget.model,
                                        )));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Text(
                                    'Edit',
                                    style: TextStyle(color: Colors.blueAccent),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.edit,
                                    color: Colors.blueAccent,
                                  ),
                                ],
                              ),
                              is_appointmentToday
                                  ? Container(
                                      width: 100,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Colors.blue.shade300),
                                      child: const Center(
                                          child: Text(
                                        'Today',
                                        style: TextStyle(color: Colors.white),
                                      )),
                                    )
                                  : is_appointmentTommarrow
                                      ? Container(
                                          width: 100,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: Colors.blue.shade300),
                                          child: const Center(
                                              child: Text(
                                            'Tomorrow',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                        )
                                      : Container()
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}

class BookDateCard extends StatelessWidget {
  final String head;
  final String tail;
  const BookDateCard({Key? key, required this.head, required this.tail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          head,
          style: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.normal),
        ),
        Text(
          tail,
          style: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
