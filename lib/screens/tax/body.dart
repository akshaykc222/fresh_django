import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:fresh_new_one/screens/tax/components/add_tax.dart';
import 'package:fresh_new_one/screens/tax/model/taxmodel.dart';
import 'package:fresh_new_one/screens/tax/provider/tax_provider.dart';

import '../../componets.dart';
import '../../constants.dart';

class Tax extends StatelessWidget {
  const Tax({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void showAlertDelete1(BuildContext _context) {
      showModalBottomSheet(
          context: _context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          builder: (_) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom
              ),
              child: Wrap(
                children: const [Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TaxForm(),
                )],
              ),
            );
          });
    }

    return Scaffold(
      extendBody: true,
      appBar: appBar("Tax", [], context),
      resizeToAvoidBottomInset: false,
      body: Container(
        color: lightBlack,
        child: Consumer<TaxProvider>(builder: (context, snap, child) {
          return GridView.builder(
              shrinkWrap: true,
              itemCount: snap.businessList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio:
                      MediaQuery.of(context).size.width * 0.3 / 90),
              itemBuilder: (_, index) {
                return TaxListTile(model: snap.businessList[index]);
              });
        }),
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
          showAlertDelete1(context);
        },
        child: const Center(
          child: Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class TaxListTile extends StatelessWidget {
  final TaxModel model;
  const TaxListTile({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void showUpdate(BuildContext _context, TaxModel model) {
      showModalBottomSheet(
          context: _context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          builder: (_) {
            return Wrap(
              children: [
                TaxForm(
                  model: model,
                )
              ],
            );
          });
    }

    ;
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
                model.shortName,
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
                    Provider.of<TaxProvider>(context, listen: false)
                        .deletBusines(model, context);
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
                    showUpdate(context, model);
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
