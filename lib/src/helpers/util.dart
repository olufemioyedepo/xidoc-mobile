library codixutil;

import 'package:codix_geofencing/src/models/dtos/geolocationparameters.dart';
import 'package:codix_geofencing/src/models/dtos/userinfo.dart';
import 'package:codix_geofencing/src/models/location.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codix_geofencing/src/helpers/variables.dart' as variables;
//import 'package:dio/dio.dart';

bool userLoggedIn;
UserLocation _currentLocation;
var location = Location();

Future<String> getUserPersonnelNumberFromSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final staffPersonnelNumber = prefs.getString('staffpersonnelnumber');
  
  return staffPersonnelNumber;
}

Future<String> getUserFullNameFromSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final staffFullName = prefs.getString('name');
  
  return staffFullName;
}

Future<UserInfo> getNameEmailFromSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final staffFullName = prefs.getString('name');
  final email = prefs.getString('primaryContactEmail');
  var userinfo = new UserInfo(staffFullName, email);

  return userinfo;
}

Future<bool> isLocationEnabled() async{
  ServiceStatus serviceStatus = await PermissionHandler().checkServiceStatus(PermissionGroup.location);
  bool locationEnabled = (serviceStatus == ServiceStatus.enabled);

  return locationEnabled;
}

Future<UserLocation> getGeolocationDetails() async {
  try {
    var userLocation = await location.getLocation();
    _currentLocation = UserLocation(
      latitude: userLocation.latitude,
      longitude: userLocation.longitude,
    );
  } on Exception catch (e) {
    print('Could not get location: ${e.toString()}');
  }

  return _currentLocation;
}

Future<String> getHcmWorkerRecIdFromSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final _hcmWorkerRecId = prefs.getString('hcmWorkerRecId');
  
  return _hcmWorkerRecId;
}

Future<String> gePersonnelNumberFromSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final _hcmWorkerRecId = prefs.getString('staffpersonnelnumber');
  
  return _hcmWorkerRecId;
}

Future<AgentGeolocationParameter> getAgentGeolocationParams() async {
  final agentGeolocationParams = new AgentGeolocationParameter();
  final prefs = await SharedPreferences.getInstance();
  agentGeolocationParams.hcmWorkerRecId = prefs.getString('hcmWorkerRecId');
  // agentGeolocationParams.agentLongitude = prefs.getString('salesAgentLongitude');
  // agentGeolocationParams.agentLatitude = prefs.getString('salesAgentLatitude');
  
  return agentGeolocationParams;
}

Future<bool> isAgentWithinRange(String _currentGeolocationLatitude, String _currentGeolocationLongitude, String _hcmWorkerRecId) async{
  bool responseData;
  var geolocationDetails = new AgentGeolocationParameter();

  //getAgentGeolocationParams().then((value) async {
    //geolocationDetails = value;
    geolocationDetails.currentGeolocationLatitude = _currentGeolocationLatitude;
    geolocationDetails.currentGeolocationLongitude = _currentGeolocationLongitude;
    geolocationDetails.hcmWorkerRecId = _hcmWorkerRecId;

    print (geolocationDetails.toMap());

    try 
    {
      Dio dio = new Dio();
      Response response = await dio.post(variables.baseUrl + 'geolocation/calculatedistance', data: geolocationDetails.toMap(), options: Options(headers: {'Content-Type': 'application/json'}));
      var statusCode = response.statusCode;
      responseData = response.data;

      if (statusCode == 200) {
        //got a response
        print('got a response: ' + responseData.toString());
        return responseData;
      }
    } catch (error) {
      if (error.response == null) {
        //couldNotConnectToServer(context);
      } else if (error.response.statusCode == 400) {
        
        //couldNotCreateResource(context, 'sales line');
      }
    }
    //return geolocationDetails;
  //});

  return responseData;
  
}

Future<bool> isUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final staffPersonnelNumber = prefs.getString('staffpersonnelnumber');
  bool response = true;
  
  if (staffPersonnelNumber == null) {
    response = false;
  }

  userLoggedIn = response;

  return userLoggedIn;
}

Future<bool> clearSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.clear();
}

String formatDateFromApiResponse(String dateFromApi) {
  String formattedDate = "";

  if (dateFromApi != null) {
    var parsedDate = DateTime.parse(dateFromApi);
    formattedDate = DateFormat("EEE, MMMM d, y 'at' h:mm a").format(parsedDate);
  }
  
  return formattedDate;
}

String extractAccNoFromCustNameAccount(String customerNameAccount) {
  if (customerNameAccount == "") {
    return "";
  }
  
  List splittedStrings = customerNameAccount.split("[");
  String accountNumberWithBrace = splittedStrings[1];
  String customerAccountNumer = accountNumberWithBrace.substring(0, accountNumberWithBrace.length - 1);
  return customerAccountNumer;
}

List<String> getMonths() {
  List<String> months = new List<String>();

  months.add('Select Month');
  months.add('January');
  months.add('February');
  months.add('March');
  months.add('April');
  months.add('May');
  months.add('June');
  months.add('July');
  months.add('August');
  months.add('September');
  months.add('October');
  months.add('November');
  months.add('December');

  return months;
}

List<String> getPaymentMethods() {
  List<String> paymentMethods = new List<String>();

  paymentMethods.add('Non');
  paymentMethods.add('Cheque');
  paymentMethods.add('Electronic Transfer');
  paymentMethods.add('Cash');
  paymentMethods.add('USSD');
 
  return paymentMethods;
}

TextStyle inputTextStyle() {
  var textStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontFamily: variables.currentFont
  );
  
  return textStyle;
}

TextStyle labelTextStyle() {
  var textStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontFamily: variables.currentFont,
    color: Colors.grey
  );
  
  return textStyle;
}

Text requiredFieldWidget() {
  var requiredField = Text(' * ',
    style: new TextStyle(
      fontWeight: FontWeight.bold,
      fontFamily: variables.currentFont,
      color: Colors.red
    )
  );

  return requiredField;
}





String getCurrentYear() {
  var now = new DateTime.now();
  var currentYear = now.year;

  return currentYear.toString();
}

Future<void> setCurrentTab(String currentTab) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('currentTab', currentTab);
  print('Set active tab: ' + currentTab);
}

Future<String> getActiveTab() async {
  final prefs = await SharedPreferences.getInstance();
  String activeTab = prefs.getString('currentTab');
  print('Gotten active tab: ' + activeTab);
  return activeTab;
}

Future<UserLocation> getLocation() async {
  try {
    var userLocation = await location.getLocation();
    _currentLocation = UserLocation(
      latitude: userLocation.latitude,
      longitude: userLocation.longitude,
    );
  } on Exception catch (e) {
    print('Could not get location: ${e.toString()}');
  }

  return _currentLocation;
}

Widget buildAppBarTitle(String title) {
  return new Padding(
    padding: new EdgeInsets.all(10.0),
    child: new Text(title, style: TextStyle(color: Colors.white),),
  );
}
