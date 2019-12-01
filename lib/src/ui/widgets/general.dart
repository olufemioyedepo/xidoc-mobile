import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


void couldNotConnectToServer(BuildContext context){
    Widget okButton = FlatButton(
      child: Text("OK", 
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
          color: Colors.black
        )
      ),
      onPressed: () { 
        //Navigator.of(context).pop();
        //Navigator.of(context, rootNavigator: true).pop(result)
        //Navigator.pop(context);
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      elevation: 10,
      title: Text("Error!", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text('Could not connect to server. Please check your internet connection!'),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

void couldNotDeleteCustomer(BuildContext context){
    Widget okButton = FlatButton(
      child: Text("OK", 
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
          color: Colors.black
        )
      ),
      onPressed: () { 
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      elevation: 10,
      title: Text("Error!", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text('Could not delete customer!'),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

void turnOnLocationPrompt(BuildContext context){
    Widget okButton = FlatButton(
      child: Text("OK", 
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
          color: Colors.black
        )
      ),
      onPressed: () { 
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      elevation: 10,
      title: Text("Warning!", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text('You need to turn on your location before you can proceed!'),
      actions: [
        okButton,
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

void couldNotCreateResource(BuildContext context, String resourceName){
  Widget okButton = FlatButton(
    child: Text("OK", 
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15.0,
        color: Colors.black
      )
    ),
    onPressed: () { 
      Navigator.of(context, rootNavigator: true).pop('dialog');
    },
  );

  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15))
    ),
    elevation: 10,
    title: Text("Error!", style: TextStyle(fontWeight: FontWeight.bold)),
    content: Text('Could not create ' + resourceName),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void submittedToWorkflow(BuildContext context, String resourceName){
  Widget okButton = FlatButton(
    child: Text("OK", 
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15.0,
        color: Colors.black
      )
    ),
    onPressed: () { 
      Navigator.of(context, rootNavigator: true).pop('dialog');
    },
  );

  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15))
    ),
    elevation: 10,
    title: Text("Success", style: TextStyle(fontWeight: FontWeight.bold)),
    content: Text(resourceName + ' submitted to workflow.'),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void couldNotSubmitToWorkflow(BuildContext context){
  Widget okButton = FlatButton(
    child: Text("OK", 
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15.0,
        color: Colors.black
      )
    ),
    onPressed: () { 
      Navigator.of(context, rootNavigator: true).pop('dialog');
    },
  );

  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15))
    ),
    elevation: 10,
    title: Text("Error!", style: TextStyle(fontWeight: FontWeight.bold)),
    content: Text('Could not submit to workflow. Please try again'),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void couldNotCreateSalesLine(BuildContext context){
  Widget okButton = FlatButton(
    child: Text("OK", 
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15.0,
        color: Colors.black
      )
    ),
    onPressed: () { 
      Navigator.of(context, rootNavigator: true).pop('dialog');
    },
  );

  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15))
    ),
    elevation: 10,
    title: Text("Warning!", style: TextStyle(fontWeight: FontWeight.bold)),
    content: Container(
        height: 80.0,
        child: Column(
          children: <Widget>[
            // Text('Could not add Sales line!               '),
            // SizedBox(height: 10.0),
            Text('This Sales order has already been submitted to the workflow.')
          ],
        ),
      ),
    //content: Text('Could not add Sales Line. This Sales order has already been submitted to the workflow.'),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void showInvalidLoginCredentialsDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child:Text("OK", 
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
          color: Colors.black
        )
      ),
      onPressed: () { 
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      elevation: 10,
      title: Text("Access denied!"),
      content: Text('Invalid Login Credentials'),
      actions: [
        okButton,
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

void emptyRequiredFields(BuildContext context){
  Widget okButton = FlatButton(
    child: Text("OK", 
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15.0,
        color: Colors.black
      )
    ),
    onPressed: () { 
      Navigator.of(context, rootNavigator: true).pop('dialog');
    },
  );

  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15))
    ),
    elevation: 10,
    title: Text("Warning!", style: TextStyle(fontWeight: FontWeight.bold)),
    content: Text('One of the fields marked in red is empty!'),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void requiredFieldDialog(BuildContext context, String field){
  Widget okButton = FlatButton(
    child: Text("OK", 
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15.0,
        color: Colors.black
      )
    ),
    onPressed: () { 
      Navigator.of(context, rootNavigator: true).pop('dialog');
    },
  );

  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15))
    ),
    elevation: 10,
    title: Text("Warning!", style: TextStyle(fontWeight: FontWeight.bold)),
    content: Text(field + ' is a required field!'),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void outOfTerritoryDialog(BuildContext context){
  Widget okButton = FlatButton(
    child: Text("OK", 
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15.0,
        color: Colors.blue
      )
    ),
    onPressed: () { 
      Navigator.of(context, rootNavigator: true).pop('dialog');
    },
  );

  AlertDialog alert = AlertDialog(
    
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15))
    ),
    elevation: 10,
    title: Text("Warning!", style: TextStyle(fontWeight: FontWeight.bold)),
    content: Text('You are currently outside of your sales region!'),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void resourceCreatedDialog(BuildContext context, String resource){
  Widget okButton = FlatButton(
    child: Text("Ok", 
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15.0,
        color: Colors.green
      )
    ),
    onPressed: () { 
      Navigator.of(context, rootNavigator: true).pop('dialog');
    },
  );

  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15))
    ),
    elevation: 10,
    title: Text("Success!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text(resource + ' created successfully!')
        ],
      ),
    ),
    actions: [
      okButton
    ],
  );

  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

enum ConfirmAction { NO, YES }
 
Future<ConfirmAction> confirmationDialog(BuildContext context, String titleText, String bodyText) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))
        ),
        title: Text(titleText, 
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(bodyText),
        actions: <Widget>[
          FlatButton(
            child: const Text('No', 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              
            ),
          ),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.NO);
            },
          ),
          FlatButton(
            child: const Text('Yes', 
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.YES);
              //print('clicked on YES');
            },
          )
        ],
      );
    },
  );
}


  Future<void> handleBackButton(BuildContext context) async {
    Widget noButton = FlatButton(
      child: Text("No",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14.0
        )
      ),
      onPressed: () { 
        Navigator.of(context).pop(false);
      },
    );

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      elevation: 10,
      title: Text("Exit?", 
        style: TextStyle(fontWeight: FontWeight.bold)
      ),
      content: Text('Are you sure you  want to exit XIDOC?'),
      actions: [
        noButton,
        //yesButton
         
        new GestureDetector(
          onTap: () => Navigator.pop(context,true),
          child: FlatButton(
            child: Text('Yes'),
            onPressed: () {
              print('exityyy');
              Navigator.of(context).pop(true);
            },
          ),
        ),
        
      ],
    );

    // show the dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
