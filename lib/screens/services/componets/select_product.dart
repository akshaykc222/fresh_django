import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_new_one/componets.dart';
import 'package:fresh_new_one/screens/categories/provider/category_provider.dart';
import 'package:fresh_new_one/screens/enquiry/provider/appointment_provider.dart';
import 'package:fresh_new_one/screens/products/model/product_model.dart';
import 'package:fresh_new_one/screens/products/provider/products_provider.dart';
import 'package:fresh_new_one/screens/subcategory/provider/sub_category_provider.dart';

class ProductListAppointment extends StatefulWidget {
  const ProductListAppointment({Key? key}) : super(key: key);

  @override
  _ProductListAppointmentState createState() => _ProductListAppointmentState();
}

class _ProductListAppointmentState extends State<ProductListAppointment> {


  @override
  void initState() {

    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Provider.of<ProductProvider>(context, listen: false).get(context: context);

    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child:Consumer<ProductProvider>(

            builder: (context, snapshot,child) {
              return  snapshot.loading? snapshot.productList.isEmpty?const Center(child:  Text("no products"),): const Center(child: CircularProgressIndicator(),):
                      ListView.builder(
                        itemCount: snapshot.productList.length,
                          itemBuilder: (context,index){
                            return ProductListItem(model: snapshot.productList[index]);
                          }
                      );
            }
          ),),
        Positioned(
          bottom: 0,
            left: 0,
            right: 0,
            child: InkWell(
              onTap: (){
                Navigator.pop(context);
              },
                child: defaultButton(300, "ok")))
      ],
    );
  }
}

class ProductListItem extends StatelessWidget {
  final ProductModel model;
  const ProductListItem({Key? key,required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(

      builder: (context, snapshot,child) {
        return ListTile(
          onTap: (){
            snapshot.selectAppointmentProduct(model);
          },
          title:Text(model.name,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),) ,
          subtitle: Text(model.is_product!=null?model.is_product!?"product":"service":"",style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
          trailing: Text(model.mrp.toString()),
          selectedTileColor: Colors.blue.shade300,
          selected: snapshot.isSelectedProduct(model),
        );
      }
    );
  }
}

class ProductListItemAppointPage extends StatelessWidget {
  final ProductModel model;
  const ProductListItemAppointPage({Key? key,required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(

        builder: (context, snapshot,child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(10)
              ),
              child: ListTile(
                onTap: (){
                  snapshot.selectAppointmentProduct(model);
                },
                title:Text(model.name,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),) ,
                subtitle: Text(model.is_product!=null?model.is_product!?"product":"service":"",style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                trailing: Text(model.mrp.toString()),
                selectedTileColor: Colors.blue.shade300,
              
              ),
            ),
          );
        }
    );
  }
}
