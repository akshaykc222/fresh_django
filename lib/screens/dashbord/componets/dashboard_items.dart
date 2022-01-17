import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:fresh_new_one/componets.dart';
import 'package:fresh_new_one/constants.dart';
import 'package:fresh_new_one/screens/dashbord/componets/select_business.dart';
import 'package:fresh_new_one/screens/dashbord/model/dash_menu.dart';
import 'package:fresh_new_one/screens/enquiry/provider/appointment_provider.dart';
import 'package:fresh_new_one/screens/user/componets/user_creation_form.dart';
import 'package:fresh_new_one/sizeconfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashBoardItems extends StatefulWidget {
  const DashBoardItems({ Key? key }) : super(key: key);

  @override
  _DashBoardItemsState createState() => _DashBoardItemsState();
}

class _DashBoardItemsState extends State<DashBoardItems> {


  int todayCount=0;
  int tommorowCont=0;

  List<DashBoardMenu> menuItems =[

    // DashBoardMenu(key: 'Customer',value: '25',image:'assets/icons/user.svg'),
    //  DashBoardMenu(key: 'Notifications',value: '0',image: 'assets/icons/notification.svg'),



       
  ];
    bool left=false;
   Future<int> getSelctedBusiness() async {

      SharedPreferences pref= await SharedPreferences.getInstance();
      int? sel= pref.getInt('selected_business');
      if(sel==null){
        showModalBottomSheet(
          context: context,
          useRootNavigator: false,
          isDismissible: false,
          enableDrag: false,
          builder: (context) {
            return Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft:  Radius.circular(25.0),
                    topRight:  Radius.circular(25.0),
                  )
              ),
              child:
                const BusinessSelectPopup(),

            );
          },
        );
      }
      return 1;
    }
   Future<void> getdata()  async {
     var p=Provider.of<AppointmentProvider>(context,listen: false);
     await Provider.of<AppointmentProvider>(context,listen: false).getCategoryList(context);
     setState(() {
       todayCount=p.today_appoint;
       tommorowCont=p.tommorow;

print("==============");
      if(menuItems.isEmpty){
        menuItems.add(DashBoardMenu(key: 'Today  Appointments',value: todayCount.toString(),image:'assets/icons/appointment-icon.svg' ));
        menuItems.add( DashBoardMenu(key: 'Tomorrow Appointments',value: tommorowCont.toString(),image: 'assets/icons/appointment-icon.svg'));
      }

     });
    }
@override
  void initState() {
    getdata();
    getSelctedBusiness();
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      getdata();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child:menuItems.isEmpty?const Center(child: CircularProgressIndicator(),) :GridView.builder(
        scrollDirection:Axis.vertical,
        itemCount:menuItems.length,
        itemBuilder: (_,index){
            left=!left;
            return DashBoardItem(model:menuItems[index] );
        }, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4/4
      ),
        ),
    );
  }
}
class DashBoardItem extends StatelessWidget {
  final DashBoardMenu model;

  const DashBoardItem({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,

      child: Stack(
        children: [

          Container(
            width: 200,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 200,
                ),
                spacer(50),
                Padding(
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
                            model.key,textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        spacer(10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            model.value,
                            style: const TextStyle(
                                color: textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              top: 30,
              left: MediaQuery.of(context).size.width*0.2,
              child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(model.image,width: 25,height: 25,),
                  ))),

        ],
      ),
    );
  }
}