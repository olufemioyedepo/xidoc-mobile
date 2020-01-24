import 'package:codix_geofencing/src/models/customerpayment.dart';
import 'package:flutter/material.dart';
import 'package:codix_geofencing/src/helpers/variables.dart' as variables;
import 'package:codix_geofencing/src/helpers/util.dart' as util;
import 'package:intl/intl.dart';

class PaymentDetailsPage extends StatefulWidget {
  final CustomerPayment customerPayment;
  // In the constructor, require a sales order object.
  PaymentDetailsPage({ this.customerPayment });

  
  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  @override
  void initState() { 
    super.initState();
    print(widget.customerPayment.journalNum);
  }
  final currencyFormatter = new NumberFormat("#,###");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customerPayment.custName, style: TextStyle(fontFamily: variables.currentFont, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: <Widget>[
          Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            
            Card(
              shape: RoundedRectangleBorder(),
              child: Padding(
                padding: new EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(widget.customerPayment.custName ?? "" ,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: variables.currentFont
                    ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 9.0),
                    ),
                    new Text(
                     'Amount Paid',
                     style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                    new Text(
                     variables.currencySymbol + currencyFormatter.format(widget.customerPayment.amountPaid).toString() ?? 0,
                     style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Padding(
                     padding: EdgeInsets.only(bottom: 9.0),
                   ),
                   new Text(
                     'WHT Deducted',
                     style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Text(
                     variables.currencySymbol + currencyFormatter.format(widget.customerPayment.whtDeducted).toString() ?? 0,
                     style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Padding(
                     padding: EdgeInsets.only(bottom: 9.0),
                   ),
                   new Text(
                     'Fiscal Month/Year',
                     style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Text(
                    widget.customerPayment.month + ', ' + widget.customerPayment.fiscalYear,
                     style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                    new Padding(
                     padding: EdgeInsets.only(bottom: 9.0),
                   ),
                   new Text(
                     'Processing Status',
                     style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Text(widget.customerPayment.processingStatus ?? "",
                     style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                    new Padding(
                     padding: EdgeInsets.only(bottom: 9.0),
                   ),
                   new Text(
                     'Payment Method',
                     style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Text(widget.customerPayment.pmtMethod ?? "N/A",
                     style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Padding(
                     padding: EdgeInsets.only(bottom: 9.0),
                   ),
                   new Text(
                     'Bank',
                     style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Text(widget.customerPayment.bankName ?? "N/A",
                     style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Padding(
                     padding: EdgeInsets.only(bottom: 9.0),
                   ),
                   new Text(
                     'Currency',
                     style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Text(widget.customerPayment.currency ?? "N/A",
                     style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Padding(
                     padding: EdgeInsets.only(bottom: 9.0),
                   ),
                   new Text(
                     'Journal Number',
                     style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Text(widget.customerPayment.journalNum,
                     style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Padding(
                     padding: EdgeInsets.only(bottom: 9.0),
                   ),
                   new Text(
                     'Posted With Journal Number',
                     style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Text(widget.customerPayment.postedWithJournalNum,
                     style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Padding(
                     padding: EdgeInsets.only(bottom: 9.0),
                   ),
                   new Text(
                     'Sys Bank Account',
                     style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                   new Text(widget.customerPayment.sysBankAccount,
                     style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),
                    Padding(
                    padding: EdgeInsets.only(bottom: 9.0),
                   ),
                   new Text(
                     'Created On',
                     style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   ),

                   new Text(util.formatShortDateFromApiResponse(widget.customerPayment.paymentDate) ?? "",
                     style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontFamily: variables.currentFont
                    )
                   )
                  ],
                ),
              ),
            )
          ],
        )
        ],
        
      ),
    );
  }
}