// import 'package:codix_geofencing/'
import 'dart:convert';

import 'package:codix_geofencing/src/models/salesline.dart';
import 'package:codix_geofencing/src/models/salesorder.dart';
import 'package:codix_geofencing/src/helpers/variables.dart' as variables;
import 'package:codix_geofencing/src/helpers/util.dart' as codixutil;
import 'package:codix_geofencing/src/ui/salesline/salesline-create.dart';
import 'package:codix_geofencing/src/ui/widgets/general.dart';
import 'package:codix_geofencing/src/ui/widgets/salesline-list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:intl/intl.dart';

class SalesLineListPage extends StatefulWidget {
  final SalesOrder salesOrder;
  // In the constructor, require a sales order object.
  SalesLineListPage({ this.salesOrder });

  @override
  _SalesLineListState createState() => _SalesLineListState();
}

class _SalesLineListState extends State<SalesLineListPage> {
  final currencyFormatter = new NumberFormat("#,###");
  Future<SalesLineList> _salesLinesList;
  ProgressDialog pr;

  var salesLinesList;
  bool salesLinesLoaded = false;
  bool noSalesLine = false;
  var users;
  int usersListLength = 0;
  int salesLineCount = 0;


  Future<SalesLineList> getSalesLines(String orderNum) async {
    try {
      print('Getting sales lines for :' + orderNum);

      final response = await http.get(variables.baseUrl + 'salesLine/salesordernumber/' + orderNum);
      final responseJson = json.decode(response.body);

      setState(() {
        salesLineCount = responseJson.length;
        if (salesLineCount == 0) {
          noSalesLine = true;
        } else {
          noSalesLine = false;
        }
      });

      salesLinesList = responseJson;
      print(salesLineCount);
      print(noSalesLine);
      
      salesLinesLoaded = true;
      return new SalesLineList.fromJson(responseJson);
    } catch (e) {
      if (e.osError.message == "No address associated with hostname") {
        couldNotConnectToServer(context);
        return null;
      }
    }
    
  }

  @override
  void initState() { 
    super.initState();
    _salesLinesList = getSalesLines(widget.salesOrder.salesOrderNumber);
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.salesOrder.salesOrderNumber + " : " + widget.salesOrder.salesOrderName, style: TextStyle(fontFamily: variables.currentFont, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            
          Card(
            shape: RoundedRectangleBorder(),
            child: Padding(
              padding: new EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(widget.salesOrder.salesOrderName ?? "",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                  ),
                  new Text(widget.salesOrder.salesOrderNumber ?? "",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    ),
                  ),
                  new Text(widget.salesOrder.salesOrderStatus ?? "",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    ),
                  ),
                  new Text((codixutil.formatDateFromApiResponse(widget.salesOrder.createdOn)),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                      fontFamily: variables.currentFont
                    )
                  )
                ],
              )
            ),
          ),
          Visibility(
            visible: salesLineCount > 0,
            child:  Row( 
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Sales Lines', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15.0, fontFamily: variables.currentFont)),
                ),
              ],
            ),
          ),

         Visibility(
            visible: noSalesLine, //Default is true,
            child: Row( 
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
                ),
                Icon(Icons.info)
              ],
            ),
          ),

          Visibility(
            visible: noSalesLine, //Default is true,
            child: Row( 
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  //padding: EdgeInsets.all(10.0),
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                ),
                Text('No Sales line for this Sales Order', style: TextStyle(color: Colors.black, fontSize: 15.0, fontFamily: variables.currentFont)),
              ],
            ),
          ),
          
          Expanded(
            child: FutureBuilder(
              future: _salesLinesList,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                //print(snapshot);
                return snapshot.connectionState == ConnectionState.done
                  ? salesLinesLoaded == true
                    ? RefreshIndicator(
                      child: ListView.builder(
                        itemCount: salesLinesList?.length ?? 0,
                        itemBuilder: (context, index) {
                          var salesLine = salesLinesList[index];
                          return buildSalesLineCard(salesLine);
                        },
                      ), onRefresh: () async {
                        pr.show();
                        print ('refreshing sales lines list...');
                        setState(() {
                          getSalesLines(widget.salesOrder.salesOrderNumber).then((salesLines){
                            pr.hide();
                          }).catchError((onError){
                            pr.hide();
                          });
                        });
                      },
                    ):
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text("Could not get Sales Lines, Tap to retry!",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: variables.currentFont
                              ),
                            ),
                          ),
                          highlightColor: Colors.grey,
                          onTap: () => setState(() {
                            getSalesLines(widget.salesOrder.salesOrderNumber);
                          })
                        ),
                        
                      ],
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
          )
        ]
          
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
          onPressed: () { 
            Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SalesLineCreatePage(salesOrderHeaderNumber: widget.salesOrder.salesOrderNumber),
          ),
        );
          },
        ),
    );
  }

  Widget buildSalesLineCard(var salesLine) {
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
    
    pr.style(
      message: 'Refreshing...',
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

    return Container(
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(),
        child: Padding(
          padding: new EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(salesLine['productName'] ?? "",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: variables.currentFont
                ),
              ),
              // new Text(salesLine['itemNumber'] ?? "",
              //   style: TextStyle(
              //     color: Colors.black87,
              //     fontSize: 17.0,
              //     fontFamily: variables.currentFont
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
              ),

              Padding(
                padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.0),
              ),              
              Row( 
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new Text('Sales Order No.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont
                    ),
                  ),
                  new Text('Unit Price',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont
                    ),
                  ),
                ],
              ),
              Row( 
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new Text(salesLine['salesOrderNumber'].toString() ?? "",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont
                    ),
                  ),
                  new Text(variables.currencySymbol + currencyFormatter.format(salesLine['salesPrice'] ?? 0),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont
                    ),
                  )
                ],
              ),
              Padding(
                padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.0),
              ),
              Row( 
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new Text('Quantity',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont
                    ),
                  ),
                  new Text('Net Amount',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont
                    ),
                  ),
                ],
              ),
              Row( 
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new Text(salesLine['orderedSalesQuantity'].toString() ?? "",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont
                    ),
                  ),
                  new Text(variables.currencySymbol + currencyFormatter.format(salesLine['lineAmount'] ?? 0),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont
                    ),
                  ),
                ],
              ),
              
               
               Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 30.0),
                  ),
                  Text((codixutil.formatDateFromApiResponse(salesLine['createdOn'])),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                      fontFamily: variables.currentFont
                    )
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                 
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                      child: Text("Delete"),
                    ),
                    onTap: () {
                      int salesLineRecId = salesLine['salesLineRecId'];
                      deleteSalesLineConfirmation(context, salesLineRecId);
                    },
                  ),                  
                ],
              ),
            ],
          )
        ),
      ),
    );
  }
}


