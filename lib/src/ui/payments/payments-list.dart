import 'dart:convert';

import 'package:codix_geofencing/src/helpers/variables.dart';
import 'package:codix_geofencing/src/models/customerpayment.dart';
import 'package:codix_geofencing/src/models/customers.dart';
import 'package:codix_geofencing/src/ui/payments/payments-details.dart';
import 'package:codix_geofencing/src/ui/widgets/general.dart';
import 'package:flutter/material.dart';
import 'package:codix_geofencing/src/helpers/util.dart' as util;
import 'package:codix_geofencing/src/helpers/variables.dart' as variables;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';

class CustomerDepositPage extends StatefulWidget {
  @override
  _CustomerDepositsState createState() => _CustomerDepositsState();
}

class _CustomerDepositsState extends State<CustomerDepositPage> with AutomaticKeepAliveClientMixin<CustomerDepositPage> {
  @override
  bool get wantKeepAlive => true;

  String personnelNumber;
  ScrollController _scrollController = ScrollController();
  ProgressDialog pr;
  Future<CustomerPaymentsList> _customerPaymentsList;
  var customerPaymentsList;
  final currencyFormatter = new NumberFormat("#,###");
  int customerDepositsLength = 0;
  int myCustomerDepositCount = 0, roundTrips = 0, currentTrip = 0;
  bool customersDepositsLoaded = false;
  bool paymentDeposistLoaded, _loadingMore = false, noCustomerDeposits = false;

  @override
  void initState() { 
    print('customer deposits');
    util.setCurrentTab('customer deposits list');

    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (currentTrip <= roundTrips) {
          print('Scroll pixel: ' + _scrollController.position.pixels.toString());
          print('Getting more customers....');
          loadMoreCustomerDeposits(personnelNumber);
        }
      }
    });

    util.getUserPersonnelNumberFromSharedPrefs().then((onValue){
      if (this.mounted) {
        setState(() {
          personnelNumber = onValue.replaceAll('/', '-'); 
        });
      }

      getCustomerDepositsCount(personnelNumber);
      _customerPaymentsList = getCustomerDeposits(personnelNumber);
     
    });
  }

  Future<bool> removeCustomerDeposit(int customerDepositRecId) async {
    bool operationResponse = false;
    try {
      var res = await http.delete(variables.baseUrl + 'customerdeposit/delete/' + customerDepositRecId.toString());
      var resBody = json.decode(res.body);

      if (resBody == true) {
        print('customer deposit deleted...');

        setState(() {
          operationResponse = true; 
        });
      }
    } catch (e) {
      pr.hide();
    }
    return operationResponse;
  }

  Future<void> getCustomerDepositsCount(String personneNumber) async {
    String employeeId = personnelNumber.replaceAll('-', '/');

    try {
      final response = await http.get(variables.baseUrl + 'customerdeposit/count?employeeId=' + employeeId);
      final responseJson = json.decode(response.body);

      setState(() {
        myCustomerDepositCount = responseJson;
        var trips = myCustomerDepositCount / variables.paymentDepositsPerPage;
        roundTrips = trips.ceil();
        roundTrips--;

        print('Total trips: ' + roundTrips.toString());
        print('My customers deposits count: $myCustomerDepositCount'); 
      });
    } catch (e) {
      print('Could not get customers deposits count');
    }
  }

  loadMoreCustomerDeposits(String personnelNumber) async {
    setState(() {
     _loadingMore = true;
    });

    try {
      print('Getting more customers for : $personnelNumber');
      print('Current trip at loading more customers: $currentTrip');

      final response = await http.get(variables.baseUrl + 'customerdeposit/paged/' + currentTrip.toString() + '/' + personnelNumber);
      final responseJson = json.decode(response.body);

      setState(() {
        _loadingMore = false;
        myCustomerDepositCount = responseJson.length;
        customerPaymentsList.addAll(responseJson);
        currentTrip++;

        print(customerPaymentsList);
        if (myCustomerDepositCount == 0) {
          noCustomerDeposits = true;
        } else {
          noCustomerDeposits = false;
        }
      });

      print(myCustomerDepositCount);
      print(noCustomerDeposits);
      
      setState(() {
        customersDepositsLoaded = true;  
      });
      
      return new CustomersList.fromJson(responseJson);
    } catch (e) {
      setState(() {
       _loadingMore = false; 
      });

    }
  }

  final List<PopupMenuItem<String>> _popUpMenuItems = menuActions.map(
    (String value) => PopupMenuItem<String>(
      value: value,
      child: Text(value, 
        style: TextStyle(
        fontFamily: variables.currentFont,
        fontSize: 14.0,
        fontWeight: FontWeight.bold
      )),
    ),
  ).toList();

  Widget buildCustomerPaymentCard(var customerPaymentDetail) {
    String customerName = customerPaymentDetail['custName'] ?? "";
    double amountPaid = customerPaymentDetail['amountPaid'] ?? 0;
    String month = customerPaymentDetail['month'] ?? "";
    String fiscalYear = customerPaymentDetail['fiscalYear'] ?? "";
    String paymentDate = util.formatShortDateFromApiResponse(customerPaymentDetail['paymentDate']) ?? "";
    String processingStatus = customerPaymentDetail['processingStatus'] ?? "";
    String paymentMethod = customerPaymentDetail['pmtMethod'] ?? "";
    int recordId = customerPaymentDetail['recordId'];

    return Container(
      child: GestureDetector(
        child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(),
        child: Container(
          padding: new EdgeInsets.only(top: 5.0, bottom: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                trailing: new PopupMenuButton<String>(
                  onSelected: (String action) async {
                    if (action == "Delete") {
                      if (processingStatus != "In Review") {
                        cannotDeleteCustomerDepositDialog(context);
                      } else {
                        final ConfirmAction confirmAction = await confirmationDialog(context, 'Delete?', 'Are you sure you want to delete this customer deposit?');

                        if (confirmAction.index == 1) {
                         pr.show();

                         this.removeCustomerDeposit(recordId).then((deleteResponse){
                          if (deleteResponse == true) {
                            setState(() {
                            customerPaymentsList.removeWhere((customer) => customer['recordId'] == recordId);
                            pr.hide();

                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Customer deposit removed...', 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: variables.currentFont
                                  ),
                                ),
                              ),
                            );
                            // print(customerPaymentsList);
                          });
                          } else {
                            print('could not delete customer...');
                            couldNotDeleteCustomerDeposit(context);
                            pr.hide();
                          }
                        }); 
                      }
                      
                      }
                    }
                    
                  },
                  itemBuilder: (BuildContext context) => _popUpMenuItems,
              ),
                title: Text(
                  customerName,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: variables.currentFont
                  ),
                ),
                subtitle: Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 7.0)
                      ),
                      Row(
                        children: <Widget>[
                          Text(variables.currencySymbol + currencyFormatter.format(amountPaid),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontFamily: variables.currentFont
                            ),
                          ),
                        ],
                      ),
                      Row(children: <Widget>[
                        Text(month + ', ' + fiscalYear,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontFamily: variables.currentFont
                          ),
                        )
                      ]
                      ),
                      Row(children: <Widget>[
                        Text(processingStatus,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontFamily: variables.currentFont
                          ),
                        )
                      ]
                      ),
                      Row(
                        children: <Widget>[
                         Text(paymentMethod,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontFamily: variables.currentFont
                          ),
                         )
                       ]
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                      ),                      
                      Row(children: <Widget>[
                        Text(paymentDate,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontFamily: variables.currentFont
                          ),
                        ),
    
                      ]
                      ),
                      /* 
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          tooltip: 'Remove Customer Deposit',
                          onPressed: () {
                           setState(() {
                          });
                         },
                        ),
                          ],
                        ),*/
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        CustomerPayment customerPaymentInfo = CustomerPayment.fromJson(customerPaymentDetail);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetailsPage(customerPayment: customerPaymentInfo),
          ),
        );
      },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(
      message: 'Please wait...',
      borderRadius: 6.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 8.0,
      insetAnimCurve: Curves.easeInOut,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w600),
    );

    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
             Visibility(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 3.5)
                    ),
                    Center(
                      child: Icon(Icons.info),
                    ),
                    Center(
                      child: Text("You're yet to capture any customer deposit", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                          fontFamily: variables.currentFont
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Center(
                      child: Text('Tap on the + button to capture a customer deposit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                          fontFamily: variables.currentFont
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Center(
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Text("Tap here to refresh...",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: variables.currentFont
                            ),
                          ),
                        ),
                        highlightColor: Colors.grey,
                        onTap: () => setState(() {
                          pr.show();
                           getCustomerDeposits(personnelNumber).then((onValue){
                             pr.hide();
                           });
                        })
                      ),
                    )
                  ],
                ),
              ),
              visible: myCustomerDepositCount == 0 && paymentDeposistLoaded == true
            ), 
            Expanded(
              child: FutureBuilder(
              future: _customerPaymentsList,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                //print(snapshot);
                return snapshot.connectionState == ConnectionState.done
                  ? paymentDeposistLoaded == true
                    ? RefreshIndicator(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: customerPaymentsList?.length ?? 0,
                        itemBuilder: (context, index) {
                          var customerPayment = customerPaymentsList[index];
                          //return Text(customer['organizationName']);
                          return buildCustomerPaymentCard(customerPayment);
                        },
                      ), onRefresh: () async {
                        pr.show();

                        print ('refreshing customers payments list...');
                        setState(() {
                           getCustomerDeposits(personnelNumber).then((onValue){
                          pr.hide();
                             Scaffold.of(context).showSnackBar(
                               SnackBar(
                                 content: Text('Customers Deposits list refreshed', 
                                   style: TextStyle(
                                     fontWeight: FontWeight.bold,
                                     fontFamily: variables.currentFont
                                   ),
                                 ),
                               ),
                             );
                           //currentTrip = 0;

                           }).catchError((onError){
                             pr.hide();
                           });
                        });
                        // _scrollController.animateTo(_scrollController.position.minScrollExtent,
                        //   duration: Duration(milliseconds: 1000), curve: Curves.easeOut
                        // );

                      },
                    ):
                    Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.mood_bad),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10.0),
                            ),
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Text("Could not get customer deposits, tap to retry!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: variables.currentFont
                                  ),
                                ),
                              ),
                              highlightColor: Colors.grey,
                              onTap: () => setState(() {
                                getCustomerDeposits(personnelNumber);
                              })
                            )
                          ],
                        )
                      ),
                    )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: CircularProgressIndicator(),
                      )
                    ]
                  );
              },
            ),
            ),
            Visibility(
              visible: _loadingMore,
              //child: Center(child: CircularProgressIndicator()),
              child: Center(child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
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
                    padding: EdgeInsets.only(bottom: 10.0),
                  ),
                  Text('Loading more customer deposits...', style: TextStyle(fontFamily: variables.currentFont)),
                  Padding(
                    padding: EdgeInsets.only(bottom: 5.0),
                  ),
                ],
              )),
            ), 
          ],
        ),
      ),
    );
  }

  Future<CustomerPaymentsList> getCustomerDeposits(String personnelNumber) async {
     if (this.mounted) {
       setState(() {
         currentTrip = 0;
       });
    }
        
    try {
      print('Current trip at initial getting customer deposits: $currentTrip');
      //final response = await http.get(variables.baseUrl + 'customerdeposit/employeeid/?employeeId=' + personnelNumber);
      final response = await http.get(variables.baseUrl + 'customerdeposit/paged/' + currentTrip.toString() + '/' + personnelNumber);
      final responseJson = json.decode(response.body);

      // print(responseJson);
        setState(() {
         myCustomerDepositCount = responseJson.length;
         customerPaymentsList = responseJson;
         currentTrip++;

         if (myCustomerDepositCount == 0) {
           noCustomerDeposits = true;
         } else {
           noCustomerDeposits = false;
         }
      });

      print(myCustomerDepositCount);
      print(noCustomerDeposits);
      
      paymentDeposistLoaded = true;
      return new CustomerPaymentsList.fromJson(responseJson);
    } catch (e) {
      pr.hide();
      if (e.osError.message == "No address associated with hostname") {
        //couldNotConnectToServer(context);
        return null;
      }
    }
  }

}



