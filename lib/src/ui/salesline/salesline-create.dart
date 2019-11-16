import 'dart:convert';

import 'package:codix_geofencing/src/helpers/util.dart';

import 'package:codix_geofencing/src/models/dtos/salesline-create.dart';
import 'package:codix_geofencing/src/models/location.dart';
import 'package:codix_geofencing/src/ui/widgets/general.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:codix_geofencing/src/helpers/variables.dart' as variables;
import 'package:codix_geofencing/src/helpers/util.dart' as codixutil;
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:auto_size_text/auto_size_text.dart';

class SalesLineCreatePage extends StatefulWidget {
  final String salesOrderHeaderNumber;
  SalesLineCreatePage({ @required this.salesOrderHeaderNumber});
  

  @override
  _SalesLineCreateState createState() => _SalesLineCreateState();
}

class _SalesLineCreateState extends State<SalesLineCreatePage> {
  final _formKey = new GlobalKey<FormState>();
  final currencyFormatter = new NumberFormat("#,###");

  TextEditingController salesOrderNumberController = new TextEditingController();
  TextEditingController unitCostController = new TextEditingController();
  TextEditingController netAmountController = new TextEditingController();
  
  UserLocation _currentLocation;
  String _selectedProduct, _selectedWarehouse;
  String _selectedProductNumber;
  String selectedValue;
  String dropdownValue = 'One';

  double _salesPrice, _netAmount;

  int quantityDropDown = 1;
  int _statusCodeResponse;
  
  bool _saving = false;
  bool _isLocationOn;
  bool _canAgentMakeTransaction;
  bool _productsLoaded = false;
  
  List releasedProducts = List();
  List warehouses = List();
  List<int> quantities = List();
  List<DropdownMenuItem> releasedProductitems = [];
  
  var location = Location();

  
   
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
  
  @override
  void initState() { 
    super.initState();
    getReleasedProducts();
    getWarehouses();
    initializeQuantities();
  }

  void initializeQuantities() {
    List<int> temp = List();
    
    //temp.clear();
    //quantities.clear();

    for (int i = 1; i <= 100; i++) {
      temp.add(i);
    }
    setState(() {
      quantities = temp;
      print(quantities);
    });
  }

  Future<void> getReleasedProducts() async {
    try {
      var res = await http.get(variables.baseUrl + 'products/released');
      var resBody = json.decode(res.body);

      if (this.mounted) {
        setState(() {
          releasedProducts = resBody;
          _productsLoaded = true;
        });
      }
    } catch (e) {
      setState(() {
       _productsLoaded = true; 
      });
    }
    
  }

  Future<void> getWarehouses() async {
    var res = await http.get(variables.baseUrl + 'warehouses');
    var resBody = json.decode(res.body);

    if (this.mounted) {
      setState(() {
        warehouses = resBody;
      });
    }
  }

  String getItemNumberForSelectedProduct(String productName)
  {
    String itemNumber;
    var item = releasedProducts.firstWhere((item) => item['itemName'] == productName);
    itemNumber = item['itemNumber'];

    return itemNumber;
  }

  double getSalesPriceByItemNumber(String itemNumber)
  {
    double salesPrice;
    if (itemNumber.isEmpty) {
      return 0.0;
    }

    var item = releasedProducts.firstWhere((item) => item['itemNumber'] == itemNumber);
    salesPrice = item['salesPrice'];

    return salesPrice;
  }

  double calculateNetAmount(int quantity, double salesPrice) {
    double netAmount = quantity * salesPrice;
    return netAmount;
  }

  

  Future<int> createSalesLine(var _body) async {
    setState(() {
     _saving = true; 
    });

    Dio dio = new Dio();
    
    try {
      Response response = await dio.post(variables.baseUrl + 'salesline', data: _body, options: Options(headers: {'Content-Type': 'application/json'}));
      var statusCode = response.statusCode;
      
      if (statusCode == 201) {
        //sales line created successfully
        setState(() {
         _statusCodeResponse = statusCode; 
         _saving = false;
        });
        resourceCreatedDialog(context, 'Sales Line');
      }
    } catch (error) {
      if (error.response == null) {
        couldNotConnectToServer(context);
      } else if (error.response.statusCode == 400) {
        // Sales line create request failed
        setState(() {
         _statusCodeResponse  = error.response.statusCode;
        });
        couldNotCreateResource(context, 'sales line');
      }
    }

    return _statusCodeResponse;
  }

  
  Widget releaseProductsSearchable() {
    releasedProductitems.clear();

    for (var item in releasedProducts) {
      releasedProductitems.add(new DropdownMenuItem(
        child: new Text(item["itemName"],
          style: new TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
              fontFamily: variables.currentFont,
            )
          ),
        value: item["itemName"],
      ));
    }

    return new SearchableDropdown(
      items: releasedProductitems,

      value: _selectedProduct,
      isExpanded: true,
      hint: new Text(
        'Select Product',
        style: new TextStyle(
          fontFamily: variables.currentFont
        ),

      ),
      searchHint: new Text(
        'Select Product',
        style: new TextStyle(
            fontSize: 20,
            fontFamily: variables.currentFont
        ),
      ),
      onChanged: (value) {
        setState(() {
          _selectedProduct = value;
          _selectedProductNumber = getItemNumberForSelectedProduct(_selectedProduct);  
          _salesPrice = getSalesPriceByItemNumber(_selectedProductNumber);

          String unitCostText = variables.currencySymbol + currencyFormatter.format(_salesPrice);
          print(unitCostText);
          unitCostController.text = unitCostText;
          if (_salesPrice >= 0 && quantityDropDown >= 0) {
            double netAmount = calculateNetAmount(quantityDropDown, _salesPrice);
            netAmountController.text = variables.currencySymbol + currencyFormatter.format(netAmount).toString();
          }
        });
      },
    );
  }

  Widget salesLineCreateForm() {
    return new Container(
      padding: EdgeInsets.all(12.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Product',
                    style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: variables.currentFont,
                    color: Colors.grey
                    )
                  ),
                  Text(
                    ' * ',
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont,
                      color: Colors.red
                    )
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
                    visible: !_productsLoaded,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 0.0)
              ),
              AbsorbPointer(
                absorbing: !_productsLoaded,
                child: releaseProductsSearchable(),
              ),
              
              Padding(
                padding: EdgeInsets.only(bottom: 20.0)
              ),
              Row(
                children: <Widget>[
                  Text('Warehouse',
                    style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: variables.currentFont,
                    color: Colors.grey
                    )
                  ),
                  Text(' * ',
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont,
                      color: Colors.red
                    )
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 3.0)
              ),
              DropdownButton<String>(
                isDense: true,
                hint: new Text("Select Warehouse",
                  style: TextStyle(
                    fontFamily: variables.currentFont,
                  ),
                ),
                value: _selectedWarehouse,
                onChanged: (String newValue) {
                  setState(() {
                    _selectedWarehouse = newValue;
                    //invoiceAccountController.text = _selectedCustomer;
                  });
                },
                items: warehouses.map((warehouse) {
                  return new DropdownMenuItem<String>(
                    value: warehouse["inventLocationId"].toString(),
                    child: new Text(
                      warehouse["name"],
                      style: TextStyle(
                        fontFamily: variables.currentFont,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 30.0)
              ),
              Text('Sales Order No.',
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: variables.currentFont,
                  color: Colors.grey
                )
              ),
              new TextFormField(
                controller: salesOrderNumberController,
                keyboardType: TextInputType.emailAddress,
                enabled: false,
                autofocus: false,
                decoration: new InputDecoration(
                ),
                style: TextStyle(
                  fontFamily: variables.currentFont,
                  fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0)
              ),
              Row(
                children: <Widget>[
                  Text('Quantity',
                    style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: variables.currentFont,
                    color: Colors.grey
                    )
                  ),
                  Text(' * ',
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont,
                      color: Colors.red
                    )
                  )
                ],
              ),
              DropdownButton<int>(
                value: quantityDropDown,
                style: TextStyle(
                  fontFamily: variables.currentFont,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
                underline: Container(
                  height: 5,
                ),
                onChanged: (int newValue) {
                  setState(() {
                    quantityDropDown = newValue;

                    // calculate net mount and update the Net Amount textfield
                    _netAmount = calculateNetAmount(quantityDropDown, _salesPrice);
                    String netAmountText = variables.currencySymbol + currencyFormatter.format(_netAmount);
                    netAmountController.text = netAmountText;
                  });
                },
                items: quantities.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0)
              ),
              Row(
                children: <Widget>[
                  Text('Unit Cost',
                    style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: variables.currentFont,
                    color: Colors.grey
                    )
                  )
                ],
              ),
              new TextFormField(
                controller: unitCostController,
                enabled: false,
                autofocus: false,
                decoration: new InputDecoration(
                ),
                style: TextStyle(
                  fontFamily: variables.currentFont,
                  fontWeight: FontWeight.bold
                ),
              ),
              
              Padding(
                padding: EdgeInsets.only(bottom: 30.0)
              ),
              Text('Net Amount',
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: variables.currentFont,
                  color: Colors.grey
                )
              ),
              new TextFormField(
                controller: netAmountController,
                keyboardType: TextInputType.number,
                enabled: false,
                autofocus: false,
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
              RaisedButton(
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(12),
                onPressed: () async {
                  // check if location is enabled
                  isLocationEnabled().then((onValue) async {
                    setState(() {
                      _isLocationOn = onValue;  
                    });
                    
                    // if location is not enabled, display a warning dailog
                    if (_isLocationOn == false) {
                      turnOnLocationPrompt(context);
                    } else {
                      final ConfirmAction confirmAction = await confirmationDialog(context, 'Create Sales Line?', 'Are you sure you want to perform this operation?');
                        
                      if (confirmAction.index == 1) {
                        setState(() {
                        _saving = true; 
                        });

                        Future<UserLocation> currentLocation = getLocation();
                        final prefs = await SharedPreferences.getInstance();
                        String hcmWorkerRecId = prefs.getString('hcmWorkerRecId');

                        currentLocation.then((onValue) async {
                          var latitude = onValue.latitude.toString();
                          var longitude = onValue.longitude.toString();
                          
                          codixutil.isAgentWithinRange(latitude, longitude, hcmWorkerRecId).then((value) async {
                            setState(() {
                            _saving = false; 
                            });
                            print(confirmAction.index);
                            setState(() {
                              _canAgentMakeTransaction = value;
                              if (confirmAction.index == 1) {
                                doSalesLineCreate(latitude, longitude);
                              }
                            });

                          });

                        });
                      }

                          
                    }

                  });

                },
                child: Text('Save', 
                  style: TextStyle(fontFamily: variables.currentFont, color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        )
    );
  }

  doSalesLineCreate(String latitude, String longitude) async {
  // if _canAgentMakeTransaction == true, agent can make transaction, else
  // display an out of territory range dialog to the user
  if (_canAgentMakeTransaction == true) {

    // display a yes/no confirmation dialog to the user
    
  SalesLineCreateObject salesLineCreate = new SalesLineCreateObject(
    itemId: _selectedProductNumber,
    salesAgentLatitude: latitude,
    salesAgentLongitude: longitude,
    salesId: widget.salesOrderHeaderNumber,
    salesQty: quantityDropDown,
    warehouse: _selectedWarehouse
  );

  var salesLineForSave = salesLineCreate.toMap();
  print(salesLineForSave);

  if (salesLineCreate.itemId == null || salesLineCreate.warehouse == null || salesLineCreate.salesQty == null) {
    emptyRequiredFields(context);
  } else {
    var salesLineCreateResponse = await createSalesLine(salesLineCreate.toMap());
    print(salesLineCreateResponse);

  }

  setState(() {
    _saving = false;
  });
  } else {
    outOfTerritoryDialog(context);
  }
  }

  @override
  Widget build(BuildContext context) {
    salesOrderNumberController.text = widget.salesOrderHeaderNumber;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Sales Line', style: TextStyle(fontFamily: variables.currentFont, fontWeight: FontWeight.bold),),
      ),
      body: ModalProgressHUD(
        child: salesLineCreateForm(),
        inAsyncCall: _saving,
      ),
    );
  }
}