import 'dart:convert';

import 'package:codix_geofencing/src/helpers/variables.dart';
import 'package:codix_geofencing/src/models/customerpayment.dart';
import 'package:codix_geofencing/src/models/customers.dart';
import 'package:codix_geofencing/src/models/dtos/personnelnumber.dart';
import 'package:codix_geofencing/src/ui/widgets/general.dart';
import 'package:flutter/material.dart';
import 'package:codix_geofencing/src/helpers/util.dart' as util;
import 'package:codix_geofencing/src/helpers/variables.dart' as variables;
import 'package:http/http.dart' as http;
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
  Future<CustomerPaymentsList> _customerPaymentsList;
  var customerPaymentsList;
  bool paymentDeposistLoaded;

  @override
  void initState() { 
    super.initState();
    print('customer deposits');
    util.setCurrentTab('customer deposits list');

    util.getUserPersonnelNumberFromSharedPrefs().then((onValue){
      if (this.mounted) {
        setState(() {
          personnelNumber = onValue.replaceAll('/', '-'); 
        });
      }
      
      // Get customers count
      // getCustomersCount(personnelNumber);
      _customerPaymentsList = getCustomerDeposits(personnelNumber);
     
    });
  }

  final List<PopupMenuItem<String>> _popUpMenuItems = menuActions.map(
    (String value) => PopupMenuItem<String>(
      value: value,
      child: Text(value, style: TextStyle(
        fontFamily: variables.currentFont,
        fontSize: 14.0,
        fontWeight: FontWeight.bold
      )),
    ),
  ).toList();

  Widget buildCustomerPaymentCard(var customerPayment) {
    String customerName = customerPayment['custName'] ?? "";
    double amountPaid = customerPayment['amountPaid'] ?? 0;
    String month = customerPayment['month'] ?? "";

    return Container(
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
                      final ConfirmAction confirmAction = await confirmationDialog(context, 'Delete Customer?', 'Are you sure you want to remove $customerName?');

                      if (confirmAction.index == 1) {
                        // pr.show();

                        /* this.removeCustomer(customerAccount).then((deleteResponse){
                          if (deleteResponse) {
                            setState(() {
                            customersList.removeWhere((customer) => customer['customerAccount'] == customerAccount);
                            pr.hide();

                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$customerName' + ' removed', 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: variables.currentFont
                                  ),
                                ),
                              ),
                            );
                            print(customersList);
                          });
                          } else {
                            print('could not delete customer...');
                            couldNotDeleteCustomer(context);
                            pr.hide();
                          }
                        }); */
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
                          Text(amountPaid.toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontFamily: variables.currentFont
                            ),
                          ),
                          
                        ],
                      ),
                      Row(children: <Widget>[
                        Text(month,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontFamily: variables.currentFont
                          ),
                        )
                      ]
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            /* Visibility(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 2.9)
                    ),
                    Center(
                      child: Icon(Icons.info),
                    ),
                    Center(
                      child: Text("You're yet to create any Customer", 
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
                      child: Text('Tap on the + button to create a Customer',
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
                          //pr.show();

                          // getCustomers(workerRecId).then((onValue){
                          //   pr.hide();
                          // });
                        })
                      ),
                    )
                  ],
                ),
              ),
              // visible: customersCount == 0 && customersLoaded == true
            ), */
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
                        //pr.show();

                        print ('refreshing customers payments list...');
                        
                        setState(() {
                          // getCustomers(workerRecId).then((onValue){
                          //   // pr.hide();
                          //   Scaffold.of(context).showSnackBar(
                          //     SnackBar(
                          //       content: Text('Customers list refreshed', 
                          //         style: TextStyle(
                          //           fontWeight: FontWeight.bold,
                          //           fontFamily: variables.currentFont
                          //         ),
                          //       ),
                          //     ),
                          //   );
                          //   //currentTrip = 0;

                          // }).catchError((onError){
                          //   //pr.hide();
                          // });
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
                                child: Text("Could not get customers, tap to retry!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: variables.currentFont
                                  ),
                                ),
                              ),
                              highlightColor: Colors.grey,
                              onTap: () => setState(() {
                                // getCustomers(workerRecId);
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
            /* Visibility(
              // visible: _loadingMore,
              //child: Center(child: CircularProgressIndicator()),
              child: Center(child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                  ),
                  CircularProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                  ),
                  Text('Loading more customers...', style: TextStyle(fontFamily: variables.currentFont)),
                  Padding(
                    padding: EdgeInsets.only(bottom: 5.0),
                  ),
                ],
              )),
            ), */
          ],
        ),
      ),
    );
  }

  Future<CustomerPaymentsList> getCustomerDeposits(String personnelNumber) async {
    // if (this.mounted) {
    //   setState(() {
    //     currentTrip = 0;
    //   });
    // }
        
    try {
      // print('Current trip at initial getting customers: $currentTrip');
      final response = await http.get(variables.baseUrl + 'customerdeposit/employeeid/?employeeId=' + personnelNumber);
      //final response = await http.get(variables.baseUrl + 'customers/staffid/' + hcmWorkerRecId);
      final responseJson = json.decode(response.body);
      customerPaymentsList = responseJson;
      print(responseJson);
        //setState(() {

        // customersCount = responseJson.length;
        // customersList = responseJson;
        // currentTrip++;
        //print(customersList);

        // if (customersCount == 0) {
        //   noCustomer = true;
        // } else {
        //   noCustomer = false;
        // }
      //});

      // print(customersCount);
      // print(noCustomer);
      
      paymentDeposistLoaded = true;
      return new CustomerPaymentsList.fromJson(responseJson);
    } catch (e) {
      if (e.osError.message == "No address associated with hostname") {
        //couldNotConnectToServer(context);
        return null;
      }
    }
  }

}



