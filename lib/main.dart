import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:codix_geofencing/src/ui/login.dart';
import 'package:codix_geofencing/src/ui/splashscreen.dart';
import 'package:codix_geofencing/src/ui/salesorder/salesorders-create.dart';
import 'package:codix_geofencing/src/helpers/variables.dart' as variables;

//void main() => runApp(MyApp());

void main() {
  runApp(MyApp());
  //black
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
}

class MyApp extends StatelessWidget {
  // This widget is the root of the application.

  final routes = <String, WidgetBuilder>{
    '/login-page': (context) => LoginPage(),
    '/salesorder-create': (context) => SalesOrderCreatePage()
    // HomePage.tag: (context) => HomePage(),
  };

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    

    return MaterialApp(
      title: 'XIDOC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: variables.currentFont,
      ),
      home: SplashScreen(),
      routes: routes,
    );
  }

}
