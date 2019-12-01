import 'dart:convert';

import 'package:codix_geofencing/src/helpers/variables.dart';
import 'package:codix_geofencing/src/models/salesorder.dart';
import 'package:codix_geofencing/src/ui/salesline/salesline-list.dart';
import 'package:codix_geofencing/src/ui/widgets/general.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:async_loader/async_loader.dart';
import 'package:http/http.dart' as http;

import 'package:codix_geofencing/src/helpers/util.dart' as codixutil;
import 'package:codix_geofencing/src/helpers/variables.dart' as variables;
import 'package:progress_dialog/progress_dialog.dart';

class SalesOrdersPage extends StatefulWidget {
  @override
  _SalesOrdersPageState createState() => _SalesOrdersPageState();
}

class _SalesOrdersPageState extends State<SalesOrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListBody(),
    );
  }
}

class ListBody extends StatefulWidget {
  @override
  ListBodyState createState() => ListBodyState();
}

class ListBodyState extends State<ListBody> with AutomaticKeepAliveClientMixin<ListBody>{
  final GlobalKey<AsyncLoaderState> asyncLoaderState = new GlobalKey<AsyncLoaderState>();
  ScrollController _scrollController = ScrollController();
  ProgressDialog pr;
  String _hcmWorkerRecId;

  Future<SalesOrdersList> _salesOrdersList;
  
  //var _loadedSalesOrders;
  var salesOrderList;
  //bool _showCircularProgressBar = true,
  bool _loadingMore = false, salesOrdersLoaded = false;
  bool noCustomer = false;
  int roundTrips = 0, currentTrip = 0, salesOrdersCount = 0;

  @override
  void initState() {
    codixutil.setCurrentTab('salesorderslist');

    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (currentTrip <= roundTrips) {
          print('Reached end of listview...');
          loadMoreSalesOrders(_hcmWorkerRecId);
        }
      }
    });

     codixutil.getHcmWorkerRecIdFromSharedPrefs().then((onValue){
      setState(() {
       _hcmWorkerRecId = onValue; 
      });
      
      // Get sales orders count count
      getSalesOrdersCount(_hcmWorkerRecId);
      _salesOrdersList = fetchSalesOrders(_hcmWorkerRecId);
     
    });

  }

  Future<void> getSalesOrdersCount(String hcmWorkerRecId) async {
    try {
      final response = await http.get(variables.baseUrl + 'salesorder/count/' + hcmWorkerRecId);
      final responseJson = json.decode(response.body);

      setState(() {
        salesOrdersCount = responseJson;
        var trips = salesOrdersCount / variables.salesOrdersPagePage;
        roundTrips = trips.ceil();
        roundTrips--;

        print('Total trips: ' + roundTrips.toString());
        print('My sales orders count: $salesOrdersCount'); 
      });
    } catch (e) {
    }
  }

  @override
  void dispose() { 
    _scrollController.dispose();
    super.dispose();
  }

  final List<PopupMenuItem<String>> _popUpMenuItems = menuActions.map(
    (String value) => PopupMenuItem<String>(
      enabled: false,
      value: value,
      child: Text(value, style: TextStyle(
        fontFamily: variables.currentFont,
        fontSize: 14.0,
        fontWeight: FontWeight.bold
      )),
    ),
  ).toList();

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
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 2.9)  //EdgeInsets.only(top: 50.0),
                    ),
                    Center(
                      child: Icon(Icons.info),
                    ),
                    Center(
                      child: Text("You're yet to create any Sales Order", 
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
                      child: Text('Tap on the + button to create a  Sales Order',
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

                          fetchSalesOrders(_hcmWorkerRecId).then((onValue){
                            pr.hide();
                          });
                        })
                      ),
                    )
                  ],
                ),
              ),
              visible: salesOrdersCount == 0 && salesOrdersLoaded == true
            ),
            Expanded(
              child: FutureBuilder(
              future: _salesOrdersList,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return snapshot.connectionState == ConnectionState.done
                  ? salesOrdersLoaded == true
                    ? RefreshIndicator(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: salesOrderList?.length ?? 0,
                        itemBuilder: (context, index) {
                          var salesOrder = salesOrderList[index];
                          SalesOrder salesOrderInfo = SalesOrder.fromJson(salesOrder);

                          return GestureDetector(
                            onTap: () {
                              print(salesOrder);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SalesLineListPage(salesOrder: salesOrderInfo),
                                ),
                              );
                            },
                            child: buildSalesOrderItemCard(salesOrder),
                          );
                          // return buildSalesOrderItemCard(salesOrder);
                        },
                      ), onRefresh: () async {
                        pr.show();

                        print ('refreshing sales orders list...');
                        
                        setState(() {
                           fetchSalesOrders(_hcmWorkerRecId).then((onValue){
                            pr.hide();
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sales Orders list refreshed', 
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
                    )
                    : Scaffold(
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
                                child: Text("Could not get Sales orders, tap to retry!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: variables.currentFont
                                  ),
                                ),
                              ),
                              highlightColor: Colors.grey,
                              onTap: () => setState(() {
                                //getCustomers(workerRecId);
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
                  Text('Loading more Sales orders...', style: TextStyle(fontFamily: variables.currentFont)),
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

  loadMoreSalesOrders(String hcmWorkerRecId) async{
    setState(() {
     _loadingMore = true; 
    });

    try {
      print('Getting more sales orders for $hcmWorkerRecId');
      print('Current trip loading more sales orders: $currentTrip');

      final response = await http.get(variables.baseUrl + 'salesorder/paged/' + currentTrip.toString() + '/' + hcmWorkerRecId.toString());
      final responseJson = json.decode(response.body);

      setState(() {
        _loadingMore = false;
        salesOrderList.addAll(responseJson);
        currentTrip++;
      });

      salesOrdersLoaded = true;

      print('Customers found at trip: $currentTrip');
      print(responseJson);
      
      return new SalesOrdersList.fromJson(responseJson);
    } catch (e) {
      setState(() {
       _loadingMore = false; 
      });
    }
  }

  Future<SalesOrdersList> fetchSalesOrders(String hcmWorkerRecId) async {
    setState(() {
      currentTrip = 0;
    });
    
    try {
      print('Getting initial sales orders for :' + hcmWorkerRecId);
      print('Current trip at initial getting sales orders: $currentTrip');
      final response = await http.get(variables.baseUrl + 'salesorder/paged/' +currentTrip.toString() +'/'+ hcmWorkerRecId);
      //final response = await http.get(variables.baseUrl + 'customers/staffid/' + hcmWorkerRecId);
      final responseJson = json.decode(response.body);

      setState(() {

        salesOrdersCount = responseJson.length;
        salesOrderList = responseJson;
        currentTrip++;
        
        print('Initial sales orders count: $salesOrdersCount');

        if (salesOrdersCount == 0) {
          noCustomer = true;
        } else {
          noCustomer = false;
        }
        salesOrdersLoaded = true;
      });
      
      return new SalesOrdersList.fromJson(responseJson);
    } catch (e) {
      // if (e.osError.message == "No address associated with hostname") {
      //   couldNotConnectToServer(context);
      //   return null;
      // }
    }
  }

  Future<SalesOrdersList> getSalesOrders() async {
    final response = await http.get(variables.baseUrl + 'salesOrder/employeerecid/' + _hcmWorkerRecId);

    print(_hcmWorkerRecId);

    final responseJson = json.decode(response.body);
    print('Here is the response ');
    print(responseJson);
    
    salesOrdersLoaded = true;
    return new SalesOrdersList.fromJson(responseJson);
  }


  buildAppBarTitle(String title) {
    return new Padding(
      padding: new EdgeInsets.all(10.0),
      child: new Text(title),
    );
  }

  Widget getNoConnectionWidget(var error){
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 60.0,
          child: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage('assets/images/no-wifi.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 40.0
        ),
        new Text("No Internet Connection"),
        new FlatButton(
            color: Colors.red,
            child: new Text("Retry", style: TextStyle(color: Colors.white),),
            onPressed: () => asyncLoaderState.currentState.reloadState())
      ],
    );
  }

  
  Widget salesOrdersListView(SalesOrdersList salesOrdersList){
    final salesOrdersCount = salesOrdersList.salesOrders.length;

    if (salesOrdersCount > 0) {
      return new ListView.builder(
        itemCount: salesOrdersList.salesOrders.length,
        itemBuilder: (context, index) =>
        new SalesOrderListItem(salesOrdersList.salesOrders[index])
      );
    } else {
      print('No sales order to display!');
      return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 60.0,
          child: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage('assets/images/info.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        new Text("You're yet create any Sales order!", style: TextStyle(fontFamily: variables.currentFont, fontSize: 17.0)),
        new Text("Tap the + button create a Sales order.", style: TextStyle(fontFamily: variables.currentFont, fontSize: 15.0)),
        SizedBox(
          height: 40.0,
        )
        // new FlatButton(
        //     color: Colors.blueAccent,
        //     child: new Text("Retry", style: TextStyle(color: Colors.white),),
        //     onPressed: () => asyncLoaderState.currentState.reloadState()
        // )
      ],
    ); 
    }
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildSalesOrderItemCard(var salesOrder) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(),
        elevation: 3.0,
        child: Padding(
          padding: new EdgeInsets.all(1.0),
          child: Container(
            padding: new EdgeInsets.only(top: 5.5, bottom: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                   trailing: new PopupMenuButton<String>(
                    onSelected: (String action) async {
                      final ConfirmAction confirmAction = await confirmationDialog(context, 'Remove Sales Order?', 'Are you sure you want to remove this sales order?'  + '?');
                      print(confirmAction);
                    },
                    itemBuilder: (BuildContext context) => _popUpMenuItems,
                  ),
                  title: Text(salesOrder['salesOrderName'] ?? "",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont
                    ),
                  ),
                  subtitle: Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                        ),
                        Row(
                          children: <Widget>[
                            new Text(salesOrder['salesOrderNumber'] ?? "",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontFamily: variables.currentFont
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            new Text(salesOrder['salesOrderStatus'] ?? "",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontFamily: variables.currentFont
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            new Text(salesOrder['workflowStatus'] ?? "",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontFamily: variables.currentFont
                              )
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            new Padding(
                              padding: EdgeInsets.only(bottom: 5.0)
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            new Text(codixutil.formatDateFromApiResponse((salesOrder['createdOn'])),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                                fontFamily: variables.currentFont
                              )
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}

class SalesOrderListItem extends StatelessWidget{
  final SalesOrder salesOrder;
  SalesOrderListItem(this.salesOrder);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SalesLineListPage(salesOrder: this.salesOrder),
          ),
        );
      },
      child: buildSalesOrderItemCardy(context),
    );
    
  }

  final List<PopupMenuItem<String>> _popUpMenuItems = menuActions.map(
    (String value) => PopupMenuItem<String>(
      enabled: false,
      value: value,
      child: Text(value, style: TextStyle(
        fontFamily: variables.currentFont,
        fontSize: 14.0,
        fontWeight: FontWeight.bold
      )),
    ),
  ).toList();

  Widget buildSalesOrderItemCardy(BuildContext context) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(),
        elevation: 3.0,
        child: Padding(
          padding: new EdgeInsets.all(1.0),
          child: Container(
            padding: new EdgeInsets.only(top: 5.5, bottom: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  trailing: new PopupMenuButton<String>(
                    onSelected: (String action) async {
                      final ConfirmAction confirmAction = await confirmationDialog(context, 'Delete Customer?', 'Are you sure you want to remove this sales order?'  + '?');
                      
                    },
                    itemBuilder: (BuildContext context) => _popUpMenuItems,
                  ),
                  title: Text(salesOrder.salesOrderName ?? "",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont
                    ),
                  ),
                  subtitle: Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                        ),
                        Row(
                          children: <Widget>[
                            new Text(salesOrder.salesOrderNumber ?? "",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontFamily: variables.currentFont
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            new Text(salesOrder.salesOrderStatus ?? "",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontFamily: variables.currentFont
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            new Text(codixutil.formatDateFromApiResponse((salesOrder.createdOn)),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                                fontFamily: variables.currentFont
                              )
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}