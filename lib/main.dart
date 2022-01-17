import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fresh_new_one/router.dart';
import 'package:fresh_new_one/screens/Desingation/provider/desingation_provider.dart';
import 'package:fresh_new_one/screens/bussiness/provider/business_provider.dart';
import 'package:fresh_new_one/screens/categories/provider/category_provider.dart';
import 'package:fresh_new_one/screens/customers/provider/customer_provider.dart';
import 'package:fresh_new_one/screens/dashbord/body.dart';
import 'package:fresh_new_one/screens/dashbord/provider/assigned_business_provider.dart';
import 'package:fresh_new_one/screens/dashbord/provider/dashboard_provider.dart';
import 'package:fresh_new_one/screens/enquiry/provider/appointment_provider.dart';
import 'package:fresh_new_one/screens/login/body.dart';
import 'package:fresh_new_one/screens/login/provider/login_provider.dart';
import 'package:fresh_new_one/screens/products/provider/products_provider.dart';
import 'package:fresh_new_one/screens/roles/provider/role_provider.dart';
import 'package:fresh_new_one/screens/subcategory/provider/sub_category_provider.dart';
import 'package:fresh_new_one/screens/tax/provider/tax_provider.dart';
import 'package:fresh_new_one/screens/user/provider/users_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();



  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  messaging.setForegroundNotificationPresentationOptions(alert: true);
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? token;
  String notificationTitle = 'No Title';
  String notificationBody = 'No Body';
  String notificationData = 'No Data';

  Future<bool> initShared() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    token = _prefs.getString('token')!;
    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashBoardProvider()),
        ChangeNotifierProvider(create: (_) => DesignationProvider()),
        ChangeNotifierProvider(create: (_) => RoleProviderNew()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => UserProviderNew()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => SubCategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => TaxProvider()),
        ChangeNotifierProvider(create: (_) => AssignedBussinessProvider())
      ],
      child: MaterialApp(
        color: blackColor,
        title: 'Body Perfect',
        theme: ThemeData(
            textTheme: GoogleFonts.bellezaTextTheme(
              Theme.of(context).textTheme,
            ),
            primaryColor: blackColor,
            scaffoldBackgroundColor: lightBlack),
        onGenerateRoute: RouterPage.generateRoute,
        home: const SplashFuturePage(),
      ),
    );
  }
}

class SplashFuturePage extends StatefulWidget {
  const SplashFuturePage({Key? key}) : super(key: key);

  @override
  _SplashFuturePageState createState() => _SplashFuturePageState();
}

class _SplashFuturePageState extends State<SplashFuturePage> {
  String? token;
  Future<bool> initShared() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    token = _prefs.getString('token');
    return true;
  }

  Future<Widget> futureCall() async {
    await initShared();
    await Future.delayed(const Duration(milliseconds: 3000));
    return token != null
        ? Future.value(const DashBoard())
        : Future.value(const Login());
  }

  Future<void> updateToken() async {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      Provider.of<UserProviderNew>(context, listen: false).updateToken(token);
    }
  }

  @override
  void initState() {
    updateToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.asset('assets/icons/logo.png'),
      title: const Text(
        "Body Perfect",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.grey.shade400,
      showLoader: true,
      loadingText: const Text("Loading..."),
      futureNavigator: futureCall(),
    );
  }
}


