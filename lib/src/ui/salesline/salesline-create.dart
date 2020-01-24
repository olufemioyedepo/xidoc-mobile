import 'dart:convert';

import 'package:codix_geofencing/src/helpers/util.dart';
import 'package:codix_geofencing/src/models/dtos/geolocationparameters.dart';

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
import 'package:permission_handler/permission_handler.dart';

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
  TextEditingController discountAmountController = new TextEditingController();
  TextEditingController discountPercentageController = new TextEditingController();
  TextEditingController netAmountController = new TextEditingController();
  
  UserLocation _currentLocation;
  String _selectedProduct, _selectedWarehouse;
  String _selectedProductNumber;
  String selectedValue;
  String dropdownValue = 'One';
  String locationCheckText = '';


  double _salesPrice, _netAmount;

  int quantityDropDown = 1;
  int _statusCodeResponse;
  
  bool _saving = false;
  bool _isLocationOn;
  bool _isLocationEnabled = false;
  bool _checkingTerritoryBoundaries = false;
  //bool _canAgentMakeTransaction;
  bool _productsLoaded = false, productsLoading = false;
  //bool _checkingTerritoryBoundaries = false;
  bool showOutOfBoundariesMessage = false;
  bool agentWithinRange = false, doneCheckingTerritoryMapping = false;
  
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
    locationSettingsCheck();
    //getReleasedProducts();
    //getWarehouses();
    initializeQuantities();
  }

  

  void initializeQuantities() {
    List<int> temp = List();
    
    //temp.clear();
    //quantities.clear();

    for (int i = 1; i <= 200; i++) {
      temp.add(i);
    }
    setState(() {
      quantities = temp;
      print(quantities);
    });
  }

  Future<void> getReleasedProducts() async {
    setState(() {
      productsLoading = true;
    });

    try {
      var res = await http.get(variables.baseUrl + 'products/released');
      var resBody = json.decode(res.body);

      if (this.mounted) {
        setState(() {
          releasedProducts = resBody;
          _productsLoaded = true;
          productsLoading = false;
        });
      }
    } catch (e) {
      if (this.mounted) {
        setState(() {
          productsLoading = false;
          _productsLoaded = true; 
        });
      }
      
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

  double calculateNetAmount(int quantity, double salesPrice, String discountAmount,  String discountPercentage) {
    //double netAmount = quantity * salesPrice;
    double netAmount;
    double discAmt = discountAmount.isNotEmpty ? double.parse(discountAmount) : 0.0;
    double discPercentage = discountPercentage.isNotEmpty ? double.parse(discountPercentage) : 0.0;

    print('Quantity: $quantity');
    print('Sales price: $salesPrice');
    print('Discount amount: $discAmt');
    print('Discount percentage: $discPercentage');

    netAmount = quantity * salesPrice;

    if (discAmt >= 0.0) {
      netAmount = (salesPrice - discAmt) * quantity;
      print('Net Amt: $netAmount');
    }

    if (discPercentage >= 0.0) {
      netAmount = netAmount - (netAmount * (discPercentage/100));
    }
    
    return netAmount;
  }

  Future<void> locationSettingsCheck() async{
    ServiceStatus serviceStatus = await PermissionHandler().checkServiceStatus(PermissionGroup.location);
    bool enabled = (serviceStatus == ServiceStatus.enabled);

    setState(() {
      _isLocationEnabled = enabled;
      // if location setting is on, check if sales rep is within range
      if (_isLocationEnabled == true)
      {
        //_checkingTerritoryBoundaries = true;
        print("User location settings: $_isLocationEnabled" );
        isAgentWithinRange();
      } else {
        // display 'Location is off' warning and ask them to try again
        
      }
    });
  }

  Future<void> isAgentWithinRange() async {
    setState(() {
      _checkingTerritoryBoundaries = true;
      print('Checking if sales rep can make transaction...');
    });
    
    RangeChecker agentWithinRangePayload = new RangeChecker();
    Future<UserLocation> currentLocation = codixutil.getLocation();

    final prefs = await SharedPreferences.getInstance();
    String employeeId = prefs.getString('staffpersonnelnumber');

    currentLocation.then((onValue) async {
      var latitude = onValue.latitude.toString();
      var longitude = onValue.longitude.toString();
      
      agentWithinRangePayload.employeeId = employeeId;
      agentWithinRangePayload.agentLatitude = latitude;
      agentWithinRangePayload.agentLongitude = longitude;

      print(agentWithinRangePayload.toMap());

      Dio dio = new Dio();
      
      try {
        Response response = await dio.post(variables.baseUrl + 'geolocation/agentwithinrange', data: agentWithinRangePayload.toMap(), options: Options(headers: {'Content-Type': 'application/json'}));
        var statusCode = response.statusCode;
        if (statusCode == 200) {
          setState(() {
            // _checkingTerritoryBoundaries = false;
            doneCheckingTerritoryMapping = true;
            _checkingTerritoryBoundaries = false;
            agentWithinRange = response.data;
            print('Is agent within sales territory: ' + agentWithinRange.toString());
            if (agentWithinRange == true) {
              // Get products, warehouses
                getReleasedProducts();
                getWarehouses();
            }
            if (agentWithinRange == false) {
              setState(() {
              _checkingTerritoryBoundaries = false;
              });
              // outOfTerritoryDialog(context);
            }
          });
          
        }
      } catch (error) {
        if (this.mounted) {
          setState(() {
            doneCheckingTerritoryMapping = true;
          });
        }
        
        print(error.toString());
        if (error.response == null) {
        } else if (error.response.statusCode == 400) {
        }
      }
    });
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
          _saving = false;
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
            double netAmount = calculateNetAmount(quantityDropDown, _salesPrice, discountAmountController.text, discountPercentageController.text);
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
              Visibility(
                visible: _isLocationEnabled == false,
                
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('Your Location setting is currently turned off, turn it on and retry...', 
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: variables.currentFont
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
              Visibility(
                visible: _checkingTerritoryBoundaries == true,
                child: Center(child: Column(
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
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.0),
                    ),
                  ],
                )),
              ),
              Visibility(
                visible: agentWithinRange == false && doneCheckingTerritoryMapping == true,
                child: Center(child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text('You are currently outside your sales territory...', style: TextStyle(fontFamily: variables.currentFont, color: Colors.red, fontSize: 15.0)),
                    Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                    ),
                  ],
                )),
              ),
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
                    visible: productsLoading,
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
                    _netAmount = calculateNetAmount(quantityDropDown, _salesPrice, discountAmountController.text, discountPercentageController.text);
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
                padding: EdgeInsets.only(bottom: 20.0)
              ),
              Row(
                children: <Widget>[
                  Text('Discount Amount',
                    style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: variables.currentFont,
                    color: Colors.grey
                    )
                  )
                ],
              ),
              new TextFormField(
                controller: discountAmountController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: false,
                decoration: new InputDecoration(
                ),
                style: TextStyle(
                  fontFamily: variables.currentFont,
                  fontWeight: FontWeight.bold
                ),
                onChanged: (discountAmount) {
                  print('print discount amt: $discountAmount');
                  _netAmount = calculateNetAmount(quantityDropDown, _salesPrice, discountAmountController.text, discountPercentageController.text);
                  String netAmountText = variables.currencySymbol + currencyFormatter.format(_netAmount);
                  netAmountController.text = netAmountText;
                },
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0)
              ),
              Row(
                children: <Widget>[
                  Text('Discount Percentage',
                    style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: variables.currentFont,
                    color: Colors.grey
                    )
                  )
                ],
              ),
              new TextFormField(
                controller: discountPercentageController,
                keyboardType: TextInputType.number,
                maxLength: 4,

                autofocus: false,
                decoration: new InputDecoration(
                ),
                style: TextStyle(
                  fontFamily: variables.currentFont,
                  fontWeight: FontWeight.bold
                ),
                onChanged: (discountPercentage) {
                  print('print percentage: $discountPercentage');
                  _netAmount = calculateNetAmount(quantityDropDown, _salesPrice, discountAmountController.text, discountPercentageController.text);
                  String netAmountText = variables.currencySymbol + currencyFormatter.format(_netAmount);
                  netAmountController.text = netAmountText;
                },
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
              AbsorbPointer(
                absorbing: agentWithinRange == false,
                child: RaisedButton(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(12),
                  onPressed: () async {
                    final ConfirmAction confirmAction = await confirmationDialog(context, 'Create Sales Line?', 'Are you sure you want to perform this operation?');
                          
                    if (confirmAction.index == 1) {
                      doSalesLineCreate();
                    }
                    

                  },
                  child: Text('Save', 
                    style: TextStyle(fontFamily: variables.currentFont, color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              
            ],
          ),
        )
    );
  }

  doSalesLineCreate() async {
    SalesLineCreateObject salesLineCreate = new SalesLineCreateObject(
      itemNumber: _selectedProductNumber,
      lineDiscountAmount: discountAmountController.text,
      lineDiscountPercentage: discountPercentageController.text,
      salesOrderNumber: widget.salesOrderHeaderNumber,
      orderedSalesQuantity: quantityDropDown,
      shippingWarehouseId: _selectedWarehouse
    );

    var salesLineForSave = salesLineCreate.toMap();
    print(salesLineForSave);

    if (salesLineCreate.itemNumber == null || salesLineCreate.shippingWarehouseId == null || salesLineCreate.orderedSalesQuantity == null) {
      emptyRequiredFields(context);
    } else {
      var salesLineCreateResponse = await createSalesLine(salesLineCreate.toMap());
      print(salesLineCreateResponse);

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