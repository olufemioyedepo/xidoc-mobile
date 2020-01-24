import 'dart:async';
import 'dart:convert';

import 'package:codix_geofencing/src/models/dtos/personnelnumber.dart';
import 'package:codix_geofencing/src/ui/widgets/general.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codix_geofencing/src/models/dtos/userlogin.dart';
import 'package:codix_geofencing/src/helpers/variables.dart' as variables;
import 'package:codix_geofencing/src/repositories/authrepository.dart';
//import 'package:codix_geofencing/src/helpers/page-transition.dart';
import 'package:codix_geofencing/src/ui/dashboard-new.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  bool _saving = false;
  bool isSalesAgent = false;
  final authRepository = AuthRepository();

  Future<void> isSalesAgentCheck(String employeeId) async {
    PersonnelNumber personnelNumber = new PersonnelNumber();
    personnelNumber.value = employeeId;

    Dio dio = new Dio();
    try {
      print('Checking if employee is a sales rep...');

      Response response = await dio.post(variables.baseUrl + 'employees/issalesagent', data: personnelNumber.toMap(), options: Options(headers: {'Content-Type': 'application/json'}));
      var statusCode = response.statusCode;
      
      if (statusCode == 200) {
        setState(() {
          isSalesAgent = response.data;
          print('Completed Sales Rep check...$isSalesAgent');
        });
      }
    } catch (error) {
      print('Could not complete sales agent check, an error occured...');
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 88.0,
        child: Container(
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          child: Image.asset('assets/images/codix-logo.png'),
        ),
      ),
    );

    final loginForm = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: false,
            validator: (emailAddressValue) {
              if (emailAddressValue.isEmpty) {
                return 'Email address is still empty!';
              }
              return null;
              
            },
            maxLength: 40,
            decoration: InputDecoration(
              hintText: 'Email',
              labelText: 'Enter Email',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
          ),
          SizedBox(height: 10.0),
          TextFormField(
            controller: passwordController,
            autofocus: false,
            validator: (passwordValue) {
              if (passwordValue.isEmpty) {
                return 'Password is still empty!';
              }
              return null;
            },
            obscureText: true,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: 'Password',
              labelText: 'Enter Password',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ) 
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: EdgeInsets.all(12),
              color: Colors.blue,
              onPressed: () async {
                
                print(emailController.text);
                if (_formKey.currentState.validate()) {
                  // If the form is valid, make a login attempt.
                  UserLogin userLogin = new UserLogin(
                    email: emailController.text,
                    password: passwordController.text
                  );

                  setState(() {
                    _saving = true;
                  });

                  LoginResponse loginResponse = await doLogin(variables.baseUrl + 'auth/login', body: userLogin.toMap());
                  // Future<LoginResponse> loginResponse = authRepository.login(userLogin);
                  if (loginResponse != null)
                  {
                    // use the employee id to carry out a 'is sales agent' check 
                    isSalesAgentCheck(loginResponse.personnelNumber).then((onValue){
                      // employee has been set as Sales Agent
                      if (isSalesAgent == true)
                      {
                        setState(() {
                          _saving = false;
                        });
                        // extract content of the response object and store as shared preferences object
                        storeUserInfoOnSharedPrefs(loginResponse);

                        // Fluttertoast.showToast(
                        //   msg: "Login successful!",
                        //   toastLength: Toast.LENGTH_LONG,
                        //   gravity: ToastGravity.BOTTOM,
                        //   timeInSecForIos: 1,
                        //   backgroundColor: Colors.black,
                        //   textColor: Colors.white,
                        //   fontSize: 16.0
                        // );
                        // redirect to the dashboard

                        // Scaffold.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text('Logged in successfully...', 
                        //       style: TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //         fontFamily: variables.currentFont
                        //       ),
                        //     ),
                        //   ),
                        // );

                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                        NewDashboardTabPage()), (Route<dynamic> route) => false);
                        // Navigator.push(
                        //   context,
                        //   PageTransition(type: PageTransitionType.leftToRightWithFade, 
                        //   child: NewDashboardTabPage()
                        //   )
                        // );
                      } else {
                        setState(() {
                          _saving = false;
                        });
                        // employee has not been set as Sales Agent
                        // display an access-denied dialog
                        showAccessDeniedDialog(context, loginResponse.firstName);                       
                      }
                    });
                    
                  } else if (loginResponse == null) {
                    print(loginResponse.toString() + ' at login');
                    // invalid user account credentials
                    // showInvalidLoginCredentialsDialog(context);
                  }
                  
                  // print(loginResponse);
                }
              },
              child: Text('Login', style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );

    // final forgotLabel = FlatButton(
    //   child: Text(
    //     'Forgot password?',
    //     style: TextStyle(color: Colors.black54),
    //   ),
    //   onPressed: () {},
    // );

    Widget _centeredLoginForm() {
      return new Container(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              // logo,
              // SizedBox(height: 10.0),
              // email,
              // SizedBox(height: 8.0),
              // password,
              // SizedBox(height: 24.0),
              // loginButton,
              logo,
              loginForm,
              //forgotLabel
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background-2.jpg")
        )
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        
        body: ModalProgressHUD(child: _centeredLoginForm(), inAsyncCall: _saving)
      ),
    );
  }

  showAccessDeniedDialog(BuildContext context, String firstName) {
    String contentText;

    if (firstName != "")
    {
      contentText = "Hi $firstName, You've not been enlisted as a sales agent on this platform.";
    } else {
      contentText = "You've not been enlisted as a sales agent on this platform.";
    }

    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () { 
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      elevation: 10,
      title: Text("Access denied!"),
      content: Text(contentText),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  void storeUserInfoOnSharedPrefs(LoginResponse loginResponse) async {
    final prefs = await SharedPreferences.getInstance();
    print(loginResponse.toMap());
    
    prefs.setString('hcmWorkerRecId', loginResponse.hcmWorkerRecId.toString());
    prefs.setString('staffpersonnelnumber', loginResponse.personnelNumber);
    prefs.setString('lastName', loginResponse.lastName);
    prefs.setString('firstName', loginResponse.firstName);
    prefs.setString('name', loginResponse.name);
    prefs.setString('primaryContactEmail', loginResponse.primaryContactEmail);
    prefs.setString('salesAgentLongitude', loginResponse.salesAgentLongitude);
    prefs.setString('salesAgentLatitude', loginResponse.salesAgentLatitude);
    prefs.setDouble('coverageRadius', loginResponse.coverageRadius);
    prefs.setDouble('outOfCoverargeLimit', loginResponse.outOfCoverageLimit);
    prefs.setDouble('commissionPercentageRate', loginResponse.commissionPercentageRate);
    prefs.setString('agentLocation', loginResponse.agentLocation);
  }

  Future<LoginResponse> doLogin(String url, {Map body}) async {

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    return http.post(url, headers: requestHeaders, body: json.encode(body)).then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode == 200) {
        
      } else if (statusCode == 404) {
        // invalid login credentials
        showInvalidLoginCredentialsDialog(context);
      }

      return LoginResponse.fromJson(json.decode(response.body));
    }).catchError((e) {
      print("Got error: ${e.message}");
      
      setState(() {
        _saving = false;
      });
      if (e.address == null) {
        // no active internet connection
        couldNotConnectToServer(context);
      }



      
      //logger.d(e);
    });
  }

  Future<void> loginAction() async {

  }
}