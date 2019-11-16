import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void deleteSalesLineConfirmation(BuildContext context, int salesLineRecId) {
    Widget yesButton = FlatButton(
      child: Text("Yes"),
      onPressed: () { 
        // pass sales line rec id to the sales line cancel api endpoint
        print("Delete " + salesLineRecId.toString() + "?");
      },
    );
    Widget noButton = FlatButton(
      child: Text("No"),
      onPressed: () { 
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    AlertDialog alert = AlertDialog(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      title: Text("Delete?", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text('Are you sure you want to remove this line?'),
      actions: [
        yesButton,
        noButton
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

