import 'dart:convert';

import 'package:codix_geofencing/src/helpers/util.dart';
import 'package:codix_geofencing/src/models/customerdeposit.dart';
import 'package:codix_geofencing/src/ui/widgets/general.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:codix_geofencing/src/helpers/variables.dart' as variables;
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:codix_geofencing/src/helpers/util.dart' as codixutil;

class PaymentsCreatePage extends StatefulWidget {
  @override
  _PaymentsCreatePageState createState() => _PaymentsCreatePageState();
}

class _PaymentsCreatePageState extends State<PaymentsCreatePage> {
  final _formKey = new GlobalKey<FormState>();
  TextEditingController fiscalYearController = new TextEditingController();
  TextEditingController amountPaidController = new TextEditingController();
  TextEditingController bankNameController = new TextEditingController();
  TextEditingController whtDeductedController = new TextEditingController();
  

  List customersList = List();
  List currencies = List();
  List<DropdownMenuItem> customersDropdown = [];
  List<String> _months, _paymentMethods;

  var currentSelectedValue;

  bool _saving = false;
  bool _customersLoaded = false;
  final dateFormat = DateFormat("dd-M-yyyy");
  String _selectedCustomer, _selectCustomerAccount, _selectedMonth, _selectedPaymentMethod, _selectedCurrency;
  String dropdownValue = 'Select Month';
  String employeeId = '', employeeName = '', paymentDate = 'Select Payment Date...';

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2018),
        lastDate: new DateTime(2050)
    );
    if(picked != null)
    setState(() {
      paymentDate = codixutil.formatSelectedDate(picked.toString());
      print(paymentDate);
    });
  }
  
  getEmployeeFullName() async {
    codixutil.getUserFullNameFromSharedPrefs().then((onValue) {
      setState(() {
        employeeName = onValue;        
      });
    });
  }
  
  getEmployeePersonnelNumber() async {
    codixutil.getUserPersonnelNumberFromSharedPrefs().then((onValue) {
      setState(() {
        employeeId = onValue;        
      });
    });
  }
  Future<void> getCustomers() async {
    try {
      var res = await http.get(variables.baseUrl + 'customers');
      var resBody = json.decode(res.body);

      if (this.mounted) {
        setState(() {
          customersList = resBody;
          _customersLoaded = true;
        });
      }

      } catch (e) {
        setState(() {
         _customersLoaded = true; 
        });
      }
    }

  getCurrencies() async {
    try {
      var res = await http.get(variables.baseUrl + 'currencies');
      var resBody = json.decode(res.body);

      if (this.mounted) {
        setState(() {
          currencies = resBody;
          // _currenciesLoaded = true;
        });
      }

      if (res.statusCode != 200) {
        setState(() {
        // _currenciesLoaded = true; 
        });
      }  
    } catch (e) {
      // _currenciesLoaded = true;
    }
  }
  @override
  void initState() {    
    super.initState();
    getEmployeeFullName();
    getEmployeePersonnelNumber();
    getCurrencies();

    fiscalYearController.text = codixutil.getCurrentYear();
    

    setState(() {
      _months = codixutil.getMonths();
      _paymentMethods = codixutil.getPaymentMethods();
    });
    
    getCustomers();
  }

  doPaymentDepositCreate(var customerDepositPayload) async {
  setState(() {
    _saving = true; 
  });

  Dio dio = new Dio();
    
  try {
    Response response = await dio.post(variables.baseUrl + 'customerdeposit', data: customerDepositPayload, options: Options(headers: {'Content-Type': 'application/json'}));
    var statusCode = response.statusCode;
    
    if (statusCode == 201) {
      print('saved....');
      //customer deposit created successfully
      setState(() {
        _saving = false;
      });
      resourceCreatedDialog(context, 'Customer Deposit entry');
    }
  } catch (error) {
    if (error.response == null) {
      couldNotConnectToServer(context);
    } else if (error.response.statusCode == 400) {
      // Customer deposit create request failed
      setState(() {
        // _statusCodeResponse  = error.response.statusCode;
      });
      couldNotCreateResource(context, 'customer deposit');
    }
  }
  

  setState(() {
    _saving = false;
  });

  }

  Widget customersSearchable() {
    customersDropdown.clear();

    for (var item in customersList) {
      customersDropdown.add(new DropdownMenuItem(
        child: new Text(item["name"] +  " [" + item["customerAccount"] + "]",
          style: new TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
              fontFamily: variables.currentFont,
            )
          ),
        value: item["name"] + " [" + item["customerAccount"] + "]",
      ));
    }

    return new SearchableDropdown(
      items: customersDropdown,
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
          _selectCustomerAccount = codixutil.extractAccNoFromCustNameAccount(value);
          print(_selectCustomerAccount);
        });
      },
    );
  }

   Widget paymentCreateForm() {
    return new Container(
      padding: EdgeInsets.all(15.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Customer',
                    style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: variables.currentFont,
                    color: Colors.grey
                    )
                  ),
                  requiredFieldWidget(),
                  Visibility(
                    child: Container(
                      height: 15.0,
                      width: 15.0,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    ),
                    visible: !_customersLoaded,
                  ),
                ],
              ),
              AbsorbPointer(
                absorbing: !_customersLoaded,
                child: customersSearchable(),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15.0),
              ),
              Row(
                children: <Widget>[
                  Text('Fiscal Year',
                    style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: variables.currentFont,
                    color: Colors.grey
                    )
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  new Flexible(
                    child: TextField(
                      controller: fiscalYearController,
                      enabled: false,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: variables.currentFont,
                        color: Colors.black
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15.0),
              ),
              Row(
                children: <Widget>[
                  Text('Payment Date',
                    style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: variables.currentFont,
                    color: Colors.grey
                    )
                  ),
                  requiredFieldWidget(),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child:
                    new RaisedButton(
                      onPressed: _selectDate, child: new Text(paymentDate, style: TextStyle(fontFamily: variables.currentFont, fontWeight: FontWeight.bold)),
                    )
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15.0),
              ),
              Row(
                children: <Widget>[
                  Text('Month',
                    style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: variables.currentFont,
                    color: Colors.grey
                    )
                  ),
                  requiredFieldWidget(),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text("Select Month"),
                      value: _selectedMonth,
                      isExpanded: true,
                      elevation: 16,
                      //isDense: true,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedMonth = newValue;
                        });
                        print(_selectedMonth);
                      },
                      items: _months.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: inputTextStyle()),
                        );
                      }).toList(),
                    )
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15.0),
              ),
              Row(
                children: <Widget>[
                  Text('Payment Method',
                    style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: variables.currentFont,
                    color: Colors.grey
                    )
                  ),
                  requiredFieldWidget(),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text("Select Payment Method"),
                      value: _selectedPaymentMethod,
                      isExpanded: true,
                      elevation: 16,
                      //isDense: true,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedPaymentMethod = newValue;
                        });
                        print(_selectedPaymentMethod);
                      },
                      items: _paymentMethods.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: inputTextStyle()),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15.0),
              ),
              Row(
                children: <Widget>[
                  Text('Bank Name', style: labelTextStyle())
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: bankNameController,
                      keyboardType: TextInputType.text,
                      style: inputTextStyle(),
                      maxLength: 50,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
              ),
              Row(
                children: <Widget>[
                  Text('Transaction Currency', style: labelTextStyle()),
                  requiredFieldWidget(),
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
                padding: EdgeInsets.only(bottom: 15.0),
              ),
              Row(
                children: <Widget>[
                  Text('Amount Paid', style: labelTextStyle()),
                  requiredFieldWidget(),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      maxLength: 6,
                      controller: amountPaidController,
                      keyboardType: TextInputType.number,
                      style: inputTextStyle()
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15.0),
              ),
              Row(
                children: <Widget>[
                  Text('WHT Deducted', style: labelTextStyle()),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      maxLength: 6,
                      controller: whtDeductedController,
                      keyboardType: TextInputType.number,
                      style: inputTextStyle()
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15.0),
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
                  final ConfirmAction confirmAction = await confirmationDialog(context, 'Capture Customer Deposit?', 'Are you sure you want to perform this operation?');

                    if (confirmAction.index == 1) {
                      CustomerDeposit customerDeposit = new CustomerDeposit();

                      customerDeposit.amountPaid = double.parse(amountPaidController.text.trim() ?? 0);
                      customerDeposit.bankName = bankNameController.text.trim();
                      customerDeposit.currency = _selectedCurrency;
                      customerDeposit.custName = codixutil.extractNameFromCustNameAccount(_selectedCustomer);
                      customerDeposit.custId = codixutil.extractAccNoFromCustNameAccount(_selectedCustomer);
                      //customerDeposit.depositorName = 
                      customerDeposit.employeeId = employeeId;
                      customerDeposit.employeeName = employeeName;
                      customerDeposit.fiscalYear = fiscalYearController.text;
                      customerDeposit.month = _selectedMonth;
                      customerDeposit.paymentDate = codixutil.formatSelectedDate(paymentDate);   //.getTodaysDate();
                      customerDeposit.pmtMethod = _selectedPaymentMethod;
                      customerDeposit.processingStatus = "InReview";
                      customerDeposit.wHTDeducted = whtDeductedController.text == "" ? 0.0 : double.parse(whtDeductedController.text.trim());

                      print(customerDeposit.toMap());
                      doPaymentDepositCreate(customerDeposit.toMap());
                    }
                  
                },
              )
            ]
        )
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
        title: Text('Capture Deposit', style: TextStyle(fontFamily: variables.currentFont, color: Colors.white, fontWeight: FontWeight.bold),),
      ),
      body: ModalProgressHUD(
        child: Center( child: paymentCreateForm()), 
        inAsyncCall: _saving,
      ),
    );
  }
}