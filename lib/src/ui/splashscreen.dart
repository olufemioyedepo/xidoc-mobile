import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:codix_geofencing/constants.dart';
import 'package:codix_geofencing/src/helpers/page-transition.dart';
import 'package:codix_geofencing/src/ui/login.dart';
import 'package:codix_geofencing/src/ui/dashboard-new.dart';
import 'package:codix_geofencing/src/helpers/util.dart' as codixutil;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var _duration = new Duration(seconds: 2);

    // check if user info exists on shared prefs. If yes, user is currently logged in
    // Future<bool> _userLoggedIn = codixutil.getUserInfoFromSharedPrefs();
    codixutil.isUserLoggedIn().then((loggedIn)
    {
      print(loggedIn);

      if (loggedIn == true) {
        return new Timer(_duration, dashBoardPageNavigation);
      } else {
        return new Timer(_duration, loginPageNavigation);
      }
      
    });
  }

  void loginPageNavigation() {
    Navigator.of(context).pushReplacement(
      PageTransition(
        type:PageTransitionType.leftToRightWithFade,
        child: LoginPage()
      )
    );
  }

  void dashBoardPageNavigation() {
    Navigator.of(context).pushReplacement(
      PageTransition(
        type:PageTransitionType.leftToRightWithFade,
        // child: DashboardTabPage()
        child: NewDashboardTabPage()
      )
    );
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: new Image.asset('assets/images/codix-logo.png'),
          ),
          
        ],
      ),
    );
  }
}