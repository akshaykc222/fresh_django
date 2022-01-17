import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_new_one/constants.dart';
import 'package:fresh_new_one/screens/tax/model/taxmodel.dart';
import 'package:fresh_new_one/screens/tax/provider/tax_provider.dart';
import 'package:fresh_new_one/sizeconfig.dart';

import '../../../componets.dart';

class TaxForm extends StatefulWidget {
  final TaxModel? model;
  const TaxForm({Key? key, this.model}) : super(key: key);

  @override
  _TaxFormState createState() => _TaxFormState();
}

class _TaxFormState extends State<TaxForm> {
  final taxController = TextEditingController();
  final taxShortController = TextEditingController();
  final taxPercentageController = TextEditingController();

  @override
  void initState() {
    if (widget.model != null) {
      taxController.text = widget.model!.name;
      taxShortController.text = widget.model!.shortName;
      taxPercentageController.text = widget.model!.taxPercentage.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(
      children: [
        widget.model == null
            ? headingText("Add tax")
            : headingText("Update tax"),
        spacer(10),
        columUserTextFiledsBlack(
            "Enter tax name", "Tax name", TextInputType.name, taxController),
        spacer(10),
        columUserTextFiledsBlack("Enter tax short name", "Tax short name",
            TextInputType.name, taxShortController),
        spacer(10),
        columUserTextFiledsBlack("Enter tax percentage", "Tax percentage",
            TextInputType.number, taxPercentageController),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
                onTap: () {
                  if (widget.model == null) {
                    TaxModel model = TaxModel(
                        name: taxController.text,
                        shortName: taxShortController.text,
                        taxPercentage:
                            double.parse(taxPercentageController.text));
                    Provider.of<TaxProvider>(context, listen: false)
                        .addBusiness(model, context);
                  } else {
                    TaxModel model = TaxModel(
                        id: widget.model!.id,
                        name: taxController.text,
                        shortName: taxShortController.text,
                        taxPercentage:
                            double.parse(taxPercentageController.text));
                    Provider.of<TaxProvider>(context, listen: false)
                        .updateBusiness(context, model);
                  }
                },
                child: defaultButton(SizeConfig.screenWidth! * 0.5,
                    widget.model == null ? add : 'Update')),
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
    );
  }
}
