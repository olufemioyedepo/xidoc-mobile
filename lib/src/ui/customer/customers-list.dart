import 'dart:convert';

import 'package:codix_geofencing/src/helpers/variables.dart';
import 'package:codix_geofencing/src/models/customers.dart';
import 'package:codix_geofencing/src/models/dtos/personnelnumber.dart';
import 'package:codix_geofencing/src/ui/widgets/general.dart';
import 'package:flutter/material.dart';
import 'package:codix_geofencing/src/helpers/util.dart' as util;
import 'package:codix_geofencing/src/helpers/variables.dart' as variables;
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';

enum WhyFarther { harder, smarter, selfStarter, tradingCharter }

class CustomerListPage extends StatefulWidget {
  @override
  _CustomerListState createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerListPage> with AutomaticKeepAliveClientMixin<CustomerListPage>{
  ScrollController _scrollController = ScrollController();
  ProgressDialog pr;

  Future<CustomersList> _customersList;
  List<Customer> listOfCustomers;
  var customersList;
  int customersLength = 0;
  int myCustomersCount = 0, roundTrips = 0, currentTrip = 0;
  String staffPersonnelNumber, p;
  PersonnelNumber personnelNumber;
  bool customersLoaded = false;
  bool noCustomer = false;
  bool _loadingMore = false;
  String workerRecId;
  int customersCount = 0;
  

  @override
  void initState() {
    
    print('customer init');
    util.setCurrentTab('customerslist');
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (currentTrip <= roundTrips) {
          print('Scroll pixel: ' + _scrollController.position.pixels.toString());
          print('Getting more customers....');
          loadMoreCustomers(workerRecId);
        }
      }
    });
    
    util.getHcmWorkerRecIdFromSharedPrefs().then((onValue){
      setState(() {
       workerRecId = onValue; 
      });
      
      // Get customers count
      getCustomersCount(workerRecId);
      _customersList = getCustomers(workerRecId);
     
    });

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getCustomersCount(String hcmWorkerRecId) async {
    try {
      final response = await http.get(variables.baseUrl + 'customers/count/' + hcmWorkerRecId);
      final responseJson = json.decode(response.body);

      setState(() {
        myCustomersCount = responseJson;
        var trips = myCustomersCount/variables.customersPagePage;
        roundTrips = trips.ceil();
        roundTrips--;

        print('Total trips: ' + roundTrips.toString());
        print('My customers count: $myCustomersCount'); 
      });
    } catch (e) {
    }
  }

  Future<bool> removeCustomer(String customerAccount) async {
    bool operationResponse = false;
    try {
      var res = await http.delete(variables.baseUrl + 'customers/delete/' + customerAccount);
      var resBody = json.decode(res.body);

      if (resBody == true) {
        setState(() {
        operationResponse = true; 
        });
      }
    } catch (e) {
      
    }
    return operationResponse;
  }

  loadMoreCustomers(String hcmWorkerRecId) async {
    setState(() {
     _loadingMore = true;
    });

    try {
      print('Getting more customers for :' + hcmWorkerRecId);
      print('Current trip at loading more customers: $currentTrip');

      final response = await http.get(variables.baseUrl + 'customers/pagedstaffid/' + hcmWorkerRecId + '/' + currentTrip.toString());
      final responseJson = json.decode(response.body);

      setState(() {
        _loadingMore = false;
        customersCount = responseJson.length;
        customersList.addAll(responseJson);
        currentTrip++;

        print(customersList);
        if (customersCount == 0) {
          noCustomer = true;
        } else {
          noCustomer = false;
        }
      });

      print(customersCount);
      print(noCustomer);
      
      customersLoaded = true;
      return new CustomersList.fromJson(responseJson);
    } catch (e) {
      setState(() {
       _loadingMore = false; 
      });

    }
  }

  Future<CustomersList> getCustomers(String hcmWorkerRecId) async {
    setState(() {
      currentTrip = 0;
    });
    
    try {
      print('Current trip at initial getting customers: $currentTrip');
      final response = await http.get(variables.baseUrl + 'customers/pagedstaffid/' + hcmWorkerRecId + '/' + currentTrip.toString());
      //final response = await http.get(variables.baseUrl + 'customers/staffid/' + hcmWorkerRecId);
      final responseJson = json.decode(response.body);

      setState(() {

        customersCount = responseJson.length;
        customersList = responseJson;
        currentTrip++;
        //print(customersList);

        if (customersCount == 0) {
          noCustomer = true;
        } else {
          noCustomer = false;
        }
      });

      print(customersCount);
      print(noCustomer);
      
      customersLoaded = true;
      return new CustomersList.fromJson(responseJson);
    } catch (e) {
      if (e.osError.message == "No address associated with hostname") {
        couldNotConnectToServer(context);
        return null;
      }
    }
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
  
  
  Widget buildCustomerCard(var customer) {
    String customerAccount = customer['customerAccount'];
    String customerName = customer['organizationName'];

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
                        pr.show();

                        this.removeCustomer(customerAccount).then((deleteResponse){
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
                        });
                      }
                    }
                    
                  },
                  itemBuilder: (BuildContext context) => _popUpMenuItems,
              ),
                title: Text(
                  customer['organizationName'] ?? "",
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
                          Text(customer['customerAccount'] ?? "",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontFamily: variables.currentFont
                            ),
                          ),
                          
                        ],
                      ),
                      Row(children: <Widget>[
                        Text(customer['primaryContactPhone'] ?? "",
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
    
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
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
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
                          pr.show();

                          getCustomers(workerRecId).then((onValue){
                            pr.hide();
                          });
                        })
                      ),
                    )
                  ],
                ),
              ),
              visible: customersCount == 0 && customersLoaded == true
            ),
            Expanded(
              child: FutureBuilder(
              future: _customersList,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                //print(snapshot);
                return snapshot.connectionState == ConnectionState.done
                  ? customersLoaded == true
                    ? RefreshIndicator(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: customersList?.length ?? 0,
                        itemBuilder: (context, index) {
                          var customer = customersList[index];
                          //return Text(customer['organizationName']);
                          return buildCustomerCard(customer);
                        },
                      ), onRefresh: () async {
                        pr.show();

                        print ('refreshing customers list...');
                        
                        setState(() {
                          getCustomers(workerRecId).then((onValue){
                            pr.hide();
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Customers list refreshed', 
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
                                child: Text("Could not get customers, tap to retry!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: variables.currentFont
                                  ),
                                ),
                              ),
                              highlightColor: Colors.grey,
                              onTap: () => setState(() {
                                getCustomers(workerRecId);
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
            ),
          ],
        ),
      ),       
    );
  }

  @override
  bool get wantKeepAlive => true;
}

