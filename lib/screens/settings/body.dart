import 'dart:convert';
import 'dart:io';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:fresh_new_one/componets.dart';
import 'package:fresh_new_one/screens/bussiness/models/bussinessmode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<Map<String, dynamic>> getLogindetails() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    print("email ${_pref.getString("email")}");
    Map<String, dynamic> d = {
      "email": _pref.getString("email"),
      "business": _pref.getString("select_bus_detail")
    };
    return d;
  }

  String? version;
  String? buildNumber;
  void getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  void _launchURL(String url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      width: MediaQuery.of(context).size.width,
      child: FutureBuilder(
          future: getLogindetails(),
          builder: (context, snap) {
            if (snap.hasData) {
              final d = snap.data as Map<String, dynamic>;

              BusinessModel? m = d['business'] == null
                  ? null
                  : BusinessModel.fromJson(jsonDecode(d['business']));
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 5,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: m == null || m.image == null
                          ? SvgPicture.asset(
                              'assets/icons/user.svg',
                              height: 150.0,
                              width: 150.0,
                            )
                          : Image.network(
                              m.image!,
                              height: 150.0,
                              width: 150.0,
                            ),
                    ),
                    Text(
                      d['email'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                      overflow: TextOverflow.fade,
                      maxLines: 2,
                    ),
                    spacer(50),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: ArgonButton(
                    //     height: 50,
                    //     width: MediaQuery.of(context).size.width * 0.6,
                    //     borderRadius: 5.0,
                    //     color: const Color(0xFF7866FE),
                    //     child: const Text(
                    //       "Privacy Policy",
                    //       style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.w700
                    //       ),
                    //     ),
                    //     loader: Container(
                    //       padding: const EdgeInsets.all(10),
                    //       child: const SpinKitRotatingCircle(
                    //         color: Colors.white,
                    //         // size: loaderWidth ,
                    //       ),
                    //     ),
                    //     onTap: (startLoading, stopLoading, btnState) async {
                    //       SharedPreferences pref=await SharedPreferences.getInstance();
                    //       pref.clear();
                    //       if (Platform.isAndroid) {
                    //         SystemNavigator.pop();
                    //       } else if (Platform.isIOS) {
                    //         exit(0);
                    //       }
                    //       // Navigator.push(context, MaterialPageRoute(builder: (_)=>widget.model==null?const SelectDateAndTimeSlot():SelectDateAndTimeSlot(bookDate: widget.model!.bookingDate,)));
                    //     },
                    //   ),
                    // ),
                    spacer(50),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: ArgonButton(
                    //     height: 50,
                    //     width: MediaQuery.of(context).size.width * 0.6,
                    //     borderRadius: 5.0,
                    //     color: const Color(0xFF7866FE),
                    //     child: const Text(
                    //       "Terms and Conditions",
                    //       style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.w700
                    //       ),
                    //     ),
                    //     loader: Container(
                    //       padding: const EdgeInsets.all(10),
                    //       child: const SpinKitRotatingCircle(
                    //         color: Colors.white,
                    //         // size: loaderWidth ,
                    //       ),
                    //     ),
                    //     onTap: (startLoading, stopLoading, btnState) async {
                    //       SharedPreferences pref=await SharedPreferences.getInstance();
                    //       pref.clear();
                    //       if (Platform.isAndroid) {
                    //         SystemNavigator.pop();
                    //       } else if (Platform.isIOS) {
                    //         exit(0);
                    //       }
                    //       // Navigator.push(context, MaterialPageRoute(builder: (_)=>widget.model==null?const SelectDateAndTimeSlot():SelectDateAndTimeSlot(bookDate: widget.model!.bookingDate,)));
                    //     },
                    //   ),
                    // ),
                    InkWell(
                        onTap: () {
                          _launchURL(
                              "https://www.privacypolicygenerator.info/live.php?token=8eqywuj8zluzoqRUkMGgS4IyJMMGMh41");
                        },
                        child: defaultButton(300, 'Privacy policy')),
                    spacer(50),
                    InkWell(
                        onTap: () {
                          _launchURL(
                              "https://www.privacypolicygenerator.info/live.php?token=8eqywuj8zluzoqRUkMGgS4IyJMMGMh41");
                        },
                        child: defaultButton(300, 'Terms and condition')),
                    spacer(50),
                    InkWell(
                      onTap: () async {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        pref.clear();
                        if (Platform.isAndroid) {
                          SystemNavigator.pop();
                        } else if (Platform.isIOS) {
                          exit(0);
                        }
                      },
                      child: defaultButton(300, 'Log out'),
                    ),

                    spacer(10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        version == null ? "" : version!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        buildNumber == null ? "" : version!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              );
            } else {
              return const CircularProgressIndicator();
            }
          }),
    )));
  }
}
