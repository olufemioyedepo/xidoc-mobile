import 'dart:async';
import 'dart:convert';

//import 'package:codix_geofencing/src/models/location.dart';
import 'package:codix_geofencing/src/models/dtos/geolocationparameters.dart';
import 'package:codix_geofencing/src/models/location.dart';
import 'package:codix_geofencing/src/models/salesorder.dart';
import 'package:codix_geofencing/src/ui/salesline/salesline-list.dart';
import 'package:codix_geofencing/src/ui/widgets/general.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codix_geofencing/src/helpers/util.dart' as util;
import 'package:codix_geofencing/src/helpers/variables.dart' as variables;
import 'package:permission_handler/permission_handler.dart';
//import 'package:codix_geofencing/src/models/customers.dart';
import 'package:codix_geofencing/src/models/dtos/salesorder-create.dart';


class SalesOrderCreatePage extends StatefulWidget {
  @override
  _SalesOrderCreatePageState createState() => _SalesOrderCreatePageState();
}

class _SalesOrderCreatePageState extends State<SalesOrderCreatePage> {
  
  final _formKey = GlobalKey<FormState>();
  ProgressDialog pr;
  bool _saving = false;
  bool loadedCustomers = false;
  bool _canAgentMakeTransaction;
  bool _isLocationEnabled = false;
  bool isDiscountValid = true;

  bool _checkingTerritoryBoundaries = false, customersLoading = false;
  bool showOutOfBoundariesMessage = false;
  bool agentWithinRange = false;

  String _selectedCustomer, _selectCustomerAccount, _selectedCurrency, _employeeName, _employeePersonnelNumber;
  var listOfCustomers;

  TextEditingController invoiceAccountController = new TextEditingController();
  TextEditingController lineDiscountController = new TextEditingController();
  TextEditingController deliveryNameController = new TextEditingController();
  TextEditingController salesResponsibleNameController = new TextEditingController();
  List<DropdownMenuItem> customersDropdownItems = [];
  SalesOrder salesOrderInfo;

  List customersData = List();
  List currenciesData = List();

  Future<void> getCustomers() async {
    try {
      setState(() {
        customersLoading = true;
      });

      var res = await http.get(variables.baseUrl + 'customers');
      var resBody = json.decode(res.body);

      if (this.mounted) {
        setState(() {
          customersData = resBody;
          loadedCustomers = true;
          customersLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        customersLoading = true;
        loadedCustomers = true;
      });
    }
  }

  Future<void> getCurrencies() async {
    try {
      var res = await http.get(variables.baseUrl + 'currencies');
      var resBody = json.decode(res.body);

      //print(resBody);

      if (this.mounted) {
        setState(() {
          currenciesData = resBody;
        });
      }  
    } catch (e) {

    }
  }

  Future<Null> getEmployeeName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _employeeName = prefs.getString("name");
    _employeePersonnelNumber = prefs.getString("staffpersonnelnumber");
    salesResponsibleNameController.text = _employeeName;
  }
  
  Future<void> locationSettingsCheck() async{
    ServiceStatus serviceStatus = await PermissionHandler().checkServiceStatus(PermissionGroup.location);
    bool enabled = (serviceStatus == ServiceStatus.enabled);

    setState(() {
      _isLocationEnabled = enabled;
      // if location setting is on, check if sales rep is within range
      if (_isLocationEnabled == true)
      {
        _checkingTerritoryBoundaries = true;
        print("User location settings: $_isLocationEnabled" );
        isAgentWithinRange();
      } else {
        // display 'Location is off' warning and ask them to try again
        
      }
    });
  }

  Future<void> isAgentWithinRange() async {
    RangeChecker agentWithinRangePayload = new RangeChecker();
    Future<UserLocation> currentLocation = util.getLocation();

    final prefs = await SharedPreferences.getInstance();
    String employeeId = prefs.getString('staffpersonnelnumber');

    currentLocation.then((onValue) async {
      var latitude = onValue.latitude.toString();
      var longitude = onValue.longitude.toString();
      
      agentWithinRangePayload.employeeId = employeeId;
      agentWithinRangePayload.agentLatitude = latitude;
      agentWithinRangePayload.agentLongitude = longitude;

      // print(agentWithinRangePayload.toMap());

      Dio dio = new Dio();
      
      try {
        setState(() {
         _checkingTerritoryBoundaries = true; 
        });
        print('Checking if sales rep can make transaction...');

        Response response = await dio.post(variables.baseUrl + 'geolocation/agentwithinrange', data: agentWithinRangePayload.toMap(), options: Options(headers: {'Content-Type': 'application/json'}));
        var statusCode = response.statusCode;
        
        if (statusCode == 200) {
          setState(() {
            _checkingTerritoryBoundaries = false;
            agentWithinRange = response.data;
            print('Is agent within sales territory: ' + agentWithinRange.toString());

            if (agentWithinRange == false) {
              showOutOfBoundariesMessage = true;
            } else {
              getCurrencies();
              getCustomers();
            }
          });
          
        }
      } catch (error) {
        _checkingTerritoryBoundaries = false;
        
        print(error.toString());
        if (error.response == null) {
        } else if (error.response.statusCode == 400) {
          setState(() {
            // _statusCodeResponse  = error.response.statusCode;
          });
        }
      }
    });
    
    return agentWithinRange;
  }

  Future<SalesOrderForSaveResponse> createSalesOrder(String url, {Map body}) async {
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
    
    pr.style(
      message: 'Please wait...',
      borderRadius: 2.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 4.0,
      insetAnimCurve: Curves.slowMiddle,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );

    setState(() {
       _saving = true;
    });

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    Widget noButton = FlatButton(
      child: Text("No", 
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
          // color: Colors.green
        )
      ),
      onPressed: () { 
        Navigator.of(context).pop();
      },
    );

    Widget yesButton = FlatButton(
      child: Text("Yes", 
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
          // color: Colors.green
        )
      ),
      onPressed: () async {
        Navigator.of(context).pop();
        pr.show();
        getLastSalesOrder().then((onValue){
          //pr.hide();
          // redirects to the sales lines list page
          //Navigator.push(context, MaterialPageRoute(builder: (context) => SalesLineListPage(salesOrder: this.salesOrderInfo)));
        });     
      },
    );

    // set up the AlertDialog
    AlertDialog successAlert = AlertDialog(
      elevation: 10,
      title: Text("Success", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      content: Container(
        height: 80.0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text('Sales order created successfully!'),
            ),
            Text('Do you want to add line items to the newly created Sales Order?')
          ],
        ),
      ),
      actions: [
        noButton,
        yesButton
      ],
    );

    return http.post(url, headers: requestHeaders, body: json.encode(body)).then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode == 201) {
        print('sales order created...');
        
        setState(() {
          _saving = false;

          // show the success dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return successAlert;
            },
          );
        });
      } else {
        setState(() {
          _saving = false;
        });

      }

      return SalesOrderForSaveResponse.fromJson(json.decode(response.body));
    }).catchError((e) {
      print("Got error: ${e.message}");
      Widget okButton = FlatButton(
          child: Text("OK"),
          onPressed: () { 
            //Navigator.of(context).pop();
          },
        );

        // internet connection is probably off
        AlertDialog alert = AlertDialog(
          elevation: 10,
          title: Text("Error!"),
          content: Text('Could not connect to server...'),
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

        setState(() {
          _saving = false;
        });
      //logger.d(e);
    });
  }

  Future<void> getLastSalesOrder() async {
    //final SalesOrder salesOrderInfo;

    util.getHcmWorkerRecIdFromSharedPrefs().then((onValue) async {
      String employeeRecId = onValue;
      print('Getting last sales order...');

      try {
        var res = await http.get(variables.baseUrl + 'salesOrder/lastsalesorder/' + employeeRecId);
        var resBody = json.decode(res.body);
        
        setState(() {
          salesOrderInfo = SalesOrder.fromJson(resBody);
          pr.hide();
          Navigator.push(context, MaterialPageRoute(builder: (context) => SalesLineListPage(salesOrder: this.salesOrderInfo)));
        });        

      } catch (e) {
        print(e);
      }
    });
  }

  Future<void> isLocationEnabled() async{
    ServiceStatus serviceStatus = await PermissionHandler().checkServiceStatus(PermissionGroup.location);
    bool enabled = (serviceStatus == ServiceStatus.enabled);

    setState(() {
      _isLocationEnabled = enabled;

      if (_isLocationEnabled == false) {
        Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () { 
          Navigator.of(context).pop();
        },
      );

      // set up the AlertDialog
      AlertDialog successAlert = AlertDialog(
        elevation: 10,
        title: Text("Warning!"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Your device\’s location setting is off!.'),
              Text('Kindly turn it on and try again!'),
            ],
          ),
        ),
        actions: [
          okButton,
        ],
      );

      // show the success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return successAlert;
        },
      );
      }
      
      print ('service status is: ' + _isLocationEnabled.toString());
    });
  }

  void validateDiscount() {
    if (double.parse(lineDiscountController.text) > 100) {
      setState(() {
       isDiscountValid = false; 
      });
    }

    if (double.parse(lineDiscountController.text) < 100) {
      setState(() {
       isDiscountValid = true; 
      });
    }
  }
  Widget releaseProductsSearchable() {
    customersDropdownItems.clear();

    for (var item in customersData) {
      var customerInfo = item["name"] +  " [" + item["customerAccount"] + "]";

      customersDropdownItems.add(new DropdownMenuItem(
        child: new Text(customerInfo,
          style: new TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
              fontFamily: variables.currentFont,
            )
          ),
        value: customerInfo,
      ));
    }

    return new SearchableDropdown(
      items: customersDropdownItems,

      value: _selectedCustomer,
      isExpanded: true,
      hint: new Text(
        'Select Customer',
        style: new TextStyle(
          fontFamily: variables.currentFont
        ),

      ),
      searchHint: new Text(
        'Select Customer',
        style: new TextStyle(
            fontSize: 20,
            fontFamily: variables.currentFont
        ),
      ),
      onChanged: (value) {
        setState(() {
          _selectedCustomer = value;
          _selectCustomerAccount = util.extractAccNoFromCustNameAccount(value);
          invoiceAccountController.text = _selectCustomerAccount;
          print('selected customer account: $_selectCustomerAccount');
        });
      },
    );
  }

  @override
  void initState() { 
    super.initState();
    lineDiscountController.text = "0.0";

    locationSettingsCheck();
    getEmployeeName();
    //getCustomers();
    //getCurrencies();
  }

  doSalesOrderCreate() async {

    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    SalesOrderForSave salesOrderForSave = new SalesOrderForSave();

    //salesOrderForSave.salesAgentLatitude = latitude; // onValue.latitude.toString();
    //salesOrderForSave.salesAgentLongitude = longitude; // onValue.longitude.toString();
    salesOrderForSave.custAccount = invoiceAccountController.text;
    salesOrderForSave.totalDiscountPercentage = lineDiscountController.text;
    salesOrderForSave.dateTimeCreated = formattedDate;
    salesOrderForSave.staffPersonnelNumber = _employeePersonnelNumber;

    SalesOrderForSaveResponse salesOrderForSaveResponse = await createSalesOrder(variables.baseUrl + 'salesorder', body: salesOrderForSave.toMap());
    print(salesOrderForSave.toMap());
    
    print(salesOrderForSaveResponse);
    // Get user's geolocation details
    // util.getGeolocationDetails().then((onValue) async {

    // });
  }

  @override
  Widget build(BuildContext context) {
    final salesOrderCreateForm = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: _isLocationEnabled == true && _checkingTerritoryBoundaries == true,
            child: Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 5.0),
                  ),
                  Container(
                    height: 20.0,
                    width: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 5.0),
                  ),
                  Text('Checking territory mapping...', style: TextStyle(fontFamily: variables.currentFont, color: Colors.green)),
                    Padding(padding: EdgeInsets.only(bottom: 20.0),
                  ),
                ],
              ),
            )
          ),

          Visibility(
            visible: showOutOfBoundariesMessage == true,
            child: Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                  ),
                  Text("You're currently outside of your sales region(s)!", 
                    style: TextStyle(
                      color: Colors.red
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 15.0),
                  ),
                ],
              )
            )
          ),

          Visibility(
            visible: _isLocationEnabled == false,
            
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Your Location setting is currently turned off, turn it on and retry...', 
                      style: TextStyle(
                        color: Colors.red
                      )
                    ),
                  RaisedButton(
                    onPressed: () async {
                      locationSettingsCheck();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          ),

          Row(
            children: <Widget>[
              Text('Customer',
                style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: variables.currentFont,
                color: Colors.grey
                )
              ),
              util.requiredFieldWidget(),
              Visibility(
                child: Container(
                  height: 15.0,
                  width: 15.0,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    strokeWidth: 2.0,
                  ),
                ),
                visible: customersLoading,
              ),
            ],
          ),
          SizedBox(height: 10.0),
          AbsorbPointer(
            absorbing: !loadedCustomers,
            child: releaseProductsSearchable(),
          ),
          SizedBox(height: 29.0),
          Row(
            children: <Widget>[
              Text('Invoice Account',
                style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: variables.currentFont,
                color: Colors.grey
                )
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0) ,
            child: TextFormField(
            controller: invoiceAccountController,
             keyboardType: TextInputType.text,
             enabled: false,
             autofocus: false,
             validator: (invoiceAccount) {
               if (invoiceAccount.isEmpty) {
                 return 'Invoice Account  is still empty!';
               }
               return null;
               
             },
             style: TextStyle(fontWeight: FontWeight.bold),
           ),
          ),
          Row(
            children: <Widget>[
              Text('Total Discount (%)',
                style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: variables.currentFont,
                color: Colors.grey
                )
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: lineDiscountController,
                  keyboardType: TextInputType.number,
                  autofocus: false,
                  maxLength: 5,
                  validator: (lineDiscount) {
                    if (lineDiscount.isNotEmpty && double.parse(lineDiscount) > 100 ) {
                      setState(() {
                       isDiscountValid = false; 
                      });
                      print('Invoice Account is more than 100!');
                    }

                    if (lineDiscount.isEmpty) {
                      setState(() {
                       isDiscountValid = true;
                       lineDiscountController.text = "0.0";
                      });
                      print('Invoice Account  is still empty!');
                    }
                    
                    return null;
                  },
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Visibility(
                  visible: !isDiscountValid,
                  child: Text('Discount cannot be more than 100!', style: TextStyle(color: Colors.red),),
                ),
                
              ],
            )
            
            
          ),
          
          SizedBox(height: 10.0),
          Row(
            children: <Widget>[
              Text('Currency',
                style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: variables.currentFont,
                color: Colors.grey
                )
              ),
              util.requiredFieldWidget(),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0) ,
            child: DropdownButton<String>(
              //isDense: true,
              isExpanded: true,
              hint: new Text("Select Currency"),
              value: _selectedCurrency,
              onChanged: (String selectedCurrency) {
                setState(() {
                  _selectedCurrency = selectedCurrency;
                  print(_selectedCurrency);
                });
              },
              items: currenciesData.map((currency) {
                return new DropdownMenuItem<String>(
                  value: currency["currencyCode"].toString(),
                  child: new Text(
                    currency["currencyCode"],
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont,
                      color: Colors.black
                    )
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 23.0),
          Row(
            children: <Widget>[
              Text('Sales Responsible',
                style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: variables.currentFont,
                color: Colors.grey
                )
              )
            ],
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0) ,
            child: TextFormField(
              controller: salesResponsibleNameController,
              keyboardType: TextInputType.text,
              enabled: false,
              autofocus: false,
              validator: (salesResponsible) {
               if (salesResponsible.isEmpty) {
                 return 'Sales Responsible is still empty!';
               } else {
                 return null;
               }
              },
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.only(top: 10.0)
          ),
          AbsorbPointer(
            absorbing: agentWithinRange == false,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(12),
                  color: Colors.blue,
                  onPressed: () async {
                    print('hhh');
                    validateDiscount();
                    // if form is valid
                    if (_formKey.currentState.validate()) {
                      //check if the location is "On" on user's device
                      
                      if (isDiscountValid == true) {
                        final ConfirmAction confirmAction = await confirmationDialog(context, 'Create Sales Order?', 'Are you sure you want to perform this operation?');

                        if (confirmAction.index == 1) {
                            setState(() {
                              _saving = true; 
                            });
                            doSalesOrderCreate();
                        }
                      }
                    }
                  },
                  child: Text('Save', style: TextStyle(fontFamily: variables.currentFont, color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
                ),
            ),
          )

          
        ],
      ),
    );


    Widget _createSalesOrderForm() {
      return new Container(
        child: Container(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(15.0),
            children: <Widget>[
              salesOrderCreateForm,
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
        appBar: new AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.blue,
          textTheme: TextTheme(
            
          ),
          iconTheme: IconThemeData(
            color: Colors.white
          ),
          title: Text('Create Sales Order', style: TextStyle(fontFamily: variables.currentFont, color: Colors.white, fontWeight: FontWeight.bold),),
        ),
        body: ModalProgressHUD(child: _createSalesOrderForm(), inAsyncCall: _saving)
      ),
    );

  }
}