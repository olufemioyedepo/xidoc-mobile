import 'dart:convert';

import 'package:codix_geofencing/src/models/dtos/customer-create.dart';
import 'package:codix_geofencing/src/ui/widgets/general.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:codix_geofencing/src/helpers/variables.dart' as variables;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codix_geofencing/src/helpers/util.dart' as codixutil;

class CustomerCreatePage extends StatefulWidget {
  @override
  _CustomerCreatePageState createState() => _CustomerCreatePageState();
}

class _CustomerCreatePageState extends State<CustomerCreatePage> {
  final _formKey = new GlobalKey<FormState>();

  TextEditingController customerNameController = new TextEditingController();
  TextEditingController customerEmailController = new TextEditingController();
  TextEditingController customerPhoneController = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController locationController = new TextEditingController();
  
  List customerGroups = List();
  List currencies = List();
  List states = List();

  bool _customerGroupLoaded = false;
  bool _currenciesLoaded = false;
  bool _statesLoaded = false;
  bool _saving = false;

  int _statusCodeResponse;

  String _selectedCustomerGroup, _selectedCurrency, _seletedState, _agentPersonnelNumber, _agentRecId;

  getCustomerGroups() async {
    try {
      var res = await http.get(variables.baseUrl + 'customergroups');
      var resBody = json.decode(res.body);
      print(resBody);

      if (this.mounted) {
        setState(() {
          customerGroups = resBody;
          _customerGroupLoaded = true;
        });
      }
    } catch (e) {
      setState(() {
        _customerGroupLoaded = true;
      });
    }
  }

  getCurrencies() async {
    try {
      var res = await http.get(variables.baseUrl + 'currencies');
      var resBody = json.decode(res.body);

      print('currency status code: ' + res.statusCode.toString());

      if (this.mounted) {
        setState(() {
          currencies = resBody;
          _currenciesLoaded = true;
        });
      }

      if (res.statusCode != 200) {
        setState(() {
        _currenciesLoaded = true; 
        });
      }  
    } catch (e) {
      _currenciesLoaded = true;
    }
  }

  getStates() async {
    try {
      var res = await http.get(variables.baseUrl + 'states');
      var resBody = json.decode(res.body);

      if (this.mounted) {
        setState(() {
          states = resBody;
          _statesLoaded = true;
        });
      }

      if (res.statusCode != 200) {
        setState(() {
        _statesLoaded = true; 
        });
      }  
    } catch (e) {
      _statesLoaded = true;
    }
  }

  Future<String> getCustomerName() async {
    final prefs = await SharedPreferences.getInstance();
    String personnelNumber = prefs.getString('staffpersonnelnumber');
    return personnelNumber;
    // print(personnelNumber);

    // setState(() {
    //  _agentPersonnelNumber = personnelNumber; 
    // });
  }

  @override
  void initState() { 
    super.initState();
    this.getCustomerName().then((onValue) {
      print(onValue);
      setState(() {
       _agentPersonnelNumber = onValue; 
      });
    });

    codixutil.getHcmWorkerRecIdFromSharedPrefs().then((onValue) {
      setState(() {
       _agentRecId = onValue; 
      });
    });

    if (this.mounted) {
      getCustomerGroups();
      getCurrencies();
      getStates();
    }
  }

  Future<int> createCustomer(var _body) async {
    setState(() {
     _saving = true; 
    });

    Dio dio = new Dio();
    
    try {
      Response response = await dio.post(variables.baseUrl + 'customers', data: _body, options: Options(headers: {'Content-Type': 'application/json'}));
      var statusCode = response.statusCode;
      
      if (statusCode == 201) {
        //customer created successfully
        print('Customer created');

        setState(() {
         _statusCodeResponse = statusCode; 
         _saving = false;
        });
        resourceCreatedDialog(context, 'Customer');
      }
    } catch (error) {
      setState(() {
        _saving = false;
      });
      
      if (error.response == null) {
        couldNotConnectToServer(context);
      } else if (error.response.statusCode == 400) {
        // customer create request failed
        setState(() {
         _statusCodeResponse  = error.response.statusCode;
        });
        couldNotCreateResource(context, 'customer');
      }
    }

    return _statusCodeResponse;
  }

  
  Widget customerCreateForm() {
    return new Container(
      padding: EdgeInsets.all(15.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Name',
                    style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: variables.currentFont,
                    color: Colors.grey
                    )
                  ),
                  codixutil.requiredFieldWidget(),
                ],
              ),
              new TextFormField(
                controller: customerNameController,
                keyboardType: TextInputType.text,
                maxLength: 70,
                decoration: new InputDecoration(
                ),
                style: TextStyle(
                  fontFamily: variables.currentFont,
                  fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
              ),
              Row(
                children: <Widget>[
                  Text('Customer Group',
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont,
                      color: Colors.grey
                    )
                  ),
                  codixutil.requiredFieldWidget(),
                  Visibility(
                    child: Container(
                      height: 15.0,
                      width: 15.0,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    ),
                    visible: !_customerGroupLoaded,
                  ),
                ],
              ),

              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: new Text("Select Customer Group",
                        style: TextStyle(
                          fontFamily: variables.currentFont,
                        ),
                      ),
                      value: _selectedCustomerGroup,
                      onChanged: (String newValue) {
                        setState(() {
                          _selectedCustomerGroup = newValue;
                          print(_selectedCustomerGroup);
                        });
                      },
                      items: customerGroups.map((customerGroup) {
                        return new DropdownMenuItem<String>(
                          value: customerGroup["customerGroupId"].toString() ?? "",
                          child: new Text(
                            customerGroup["description"] ?? "",
                            style: TextStyle(
                              fontFamily: variables.currentFont,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
              ),

              Row(
                children: <Widget>[
                  Text('Currency',
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont,
                      color: Colors.grey
                    )
                  ),
                  codixutil.requiredFieldWidget(),
                  Visibility(
                    child: Container(
                      height: 15.0,
                      width: 15.0,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    ),
                    visible: !_currenciesLoaded,
                  ),
                ],
              ),

              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: new Text("Select Currency",
                        style: TextStyle(
                          fontFamily: variables.currentFont,
                        ),
                      ),
                      value: _selectedCurrency,
                      onChanged: (String newValue) {
                        setState(() {
                          _selectedCurrency = newValue;
                          print(_selectedCurrency);
                        });
                      },
                      items: currencies.map((currency) {
                        return new DropdownMenuItem<String>(
                          value: currency["currencyCode"].toString() ?? "",
                          child: new Text(
                            currency["currencyCode"] ?? "",
                            style: TextStyle(
                              fontFamily: variables.currentFont,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
              ),
              Row(
                children: <Widget>[
                  Text('Email',
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont,
                      color: Colors.grey
                    )
                  ),
                  
                ],
              ),
              
              new TextFormField(
                controller: customerEmailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: true,
                maxLength: 70,
                decoration: new InputDecoration(
                ),
                style: TextStyle(
                  fontFamily: variables.currentFont,
                  fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
              ),
              Row(
                children: <Widget>[
                  Text('Phone',
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont,
                      color: Colors.grey
                    )
                  ),
                 codixutil.requiredFieldWidget(),
                ],
              ),
              new TextFormField(
                controller: customerPhoneController,
                keyboardType: TextInputType.phone,
                autocorrect: true,
                maxLength: 15,
                decoration: new InputDecoration(
                ),
                style: TextStyle(
                  fontFamily: variables.currentFont,
                  fontWeight: FontWeight.bold
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    //print('value is empty');
                    return 'Error';
                  }
                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
              ),

              Row(
                children: <Widget>[
                  Text('State',
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont,
                      color: Colors.grey
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 5.0),
                  ),
                  Visibility(
                    child: Container(
                      height: 15.0,
                      width: 15.0,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    ),
                    visible: !_statesLoaded,
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: new Text("Select State",
                        style: TextStyle(
                          fontFamily: variables.currentFont,
                        ),
                      ),
                      value: _seletedState,
                      onChanged: (String newValue) {
                        setState(() {
                          _seletedState = newValue;
                          print(_seletedState);
                        });
                      },
                      items: states.map((state) {
                        return new DropdownMenuItem<String>(
                          value: state["state"].toString() ?? "",
                          child: new Text(
                            state["state"] ?? "",
                            style: TextStyle(
                              fontFamily: variables.currentFont,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
              ),

              Row(
                children: <Widget>[
                  Text('City',
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont,
                      color: Colors.grey
                    )
                  ),
                ],
              ),
              new TextFormField(
                controller: cityController,
                keyboardType: TextInputType.text,
                autocorrect: true,
                maxLength: 50,
                decoration: new InputDecoration(
                ),
                style: TextStyle(
                  fontFamily: variables.currentFont,
                  fontWeight: FontWeight.bold
                ),
              ),

              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
              ),

              Row(
                children: <Widget>[
                  Text('Location',
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont,
                      color: Colors.grey
                    )
                  ),
                ],
              ),
              new TextFormField(
                controller: locationController,
                keyboardType: TextInputType.text,
                autocorrect: true,
                maxLength: 50,
                decoration: new InputDecoration(
                ),
                style: TextStyle(
                  fontFamily: variables.currentFont,
                  fontWeight: FontWeight.bold
                ),
              ),

              RaisedButton(
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(12),
                child: Text('Save', 
                  style: TextStyle(fontFamily: variables.currentFont, color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)
                ),
                onPressed: () async {
                  final ConfirmAction confirmAction = await confirmationDialog(context, 'Create Customer?', 'Are you sure you want to perform this operation?');

                  if (confirmAction.index == 1) {
                    

                    CustomerForSave customerCreate = new CustomerForSave(
                      city: cityController.text,
                      currency: _selectedCurrency,
                      custGroup: _selectedCustomerGroup,
                      
                      location: locationController.text,
                      name: customerNameController.text,
                      personnelNumber: _agentPersonnelNumber,
                      hcmWorkerRecId: _agentRecId,
                      phone: customerPhoneController.text,
                      state: _seletedState
                    );

                    var customerForSave = customerCreate.toMap();
                    if (customerCreate.name.isEmpty) {
                      requiredFieldDialog(context, 'Customer Name');
                    } else if (customerCreate.custGroup == null) {
                      requiredFieldDialog(context, 'Customer Group');
                    } else if (customerCreate.currency == null) {
                      requiredFieldDialog(context, 'Currency');
                    } else if (customerCreate.phone.isEmpty) {
                      requiredFieldDialog(context, 'Phone');
                    } else {
                      // all required fields supplied, make api call
                      var customerCreateResponse = await createCustomer(customerForSave);
                      print(customerCreateResponse);
                      // print(customerForSave);
                    }
                  }

                  
                  
                  
                })
            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.blue,
        textTheme: TextTheme(
          
        ),
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text('Create New Customer', style: TextStyle(fontFamily: variables.currentFont, color: Colors.white, fontWeight: FontWeight.bold),),
      ),
      body: ModalProgressHUD(
        child: customerCreateForm(),
        inAsyncCall: _saving,
      ),
    );
  }
}