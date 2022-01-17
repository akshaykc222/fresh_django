
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:fresh_new_one/componets.dart';
import 'package:fresh_new_one/constants.dart';
import 'package:fresh_new_one/screens/Desingation/models/designation_model.dart';
import 'package:fresh_new_one/screens/Desingation/provider/desingation_provider.dart';

class ListDesingations extends StatefulWidget {
  const ListDesingations({Key? key}) : super(key: key);

  @override
  _ListDesingationsState createState() => _ListDesingationsState();
}

class _ListDesingationsState extends State<ListDesingations> {

  @override
  void initState() {
    
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {

      Provider.of<DesignationProvider>(context, listen: false)
          .getBusinessList(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DesignationProvider>(builder: (context, snapshot, child) {
      return GridView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio:
              MediaQuery.of(context).size.width * 0.3 / 90),
          physics: const BouncingScrollPhysics(),
          itemCount: snapshot.businessList.length,
          itemBuilder: (_, index) {
            return snapshot.businessList.isEmpty
                ? Container()
                : DesignationTile(model: snapshot.businessList[index]);
          },);
    });
  }
}

class DesignationTile extends StatefulWidget {
  final DesingationModel model;
  const DesignationTile({Key? key, required this.model}) : super(key: key);

  @override
  State<DesignationTile> createState() => _DesignationTileState();
}

class _DesignationTileState extends State<DesignationTile> {
  void showAlertDelete(DesingationModel model) {
    showBottomSheet(
        context: context,
        builder: (_) {
          return Wrap(
            children: [
              Column(
                children: [
                  Text(
                    "This action will delete the ${model.designation} from the designations",
                    style: const TextStyle(
                        color: blackColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  spacer(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                          onTap: () {
                            Provider.of<DesignationProvider>(context,
                                    listen: false)
                                .deletBusines(model, context);
                          },
                          child: defaultButton(
                              MediaQuery.of(context).size.width * 0.4,
                              "Delete")),
                      const Text(
                        cancel,
                        style: TextStyle(color: blackColor),
                      )
                    ],
                  )
                ],
              )
            ],
          );
        });
  }

  final _formKey = GlobalKey<FormState>();
  final designationText = TextEditingController();

  void showAddAlert(DesingationModel model) {
    designationText.text=widget.model.designation;
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
                          TextInputType.name, designationText),
                      spacer(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {}

                                Provider.of<DesignationProvider>(context,
                                        listen: false)
                                    .updateBusiness(
                                        context,
                                        DesingationModel(
                                            id: widget.model.id,
                                            designation: designationText.text));
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
  void initState() {
    designationText.text=widget.model.designation;
    super.initState();
  }
  @override
  void dispose() {
    designationText.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: blackColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.model.designation,
                style: const TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            spacer(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    Provider.of<DesignationProvider>(context, listen: false)
                        .deletBusines(widget.model, context);
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: lightBlack),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          'assets/icons/trash.svg',
                          width: 20,
                          height: 20,
                          color: whiteColor,
                        ),
                      )),
                ),
                InkWell(
                  onTap: () {
                    //Navigator.push(context, MaterialPageRoute(builder: (_)=>Create))
                    showAddAlert( widget.model);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: lightBlack),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        'assets/icons/edit.svg',
                        width: 20,
                        height: 20,
                        color: whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
