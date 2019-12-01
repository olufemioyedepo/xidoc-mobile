import 'package:codix_geofencing/src/ui/customer/customer-create.dart';
import 'package:codix_geofencing/src/ui/customer/customers-list.dart';
import 'package:codix_geofencing/src/ui/payments/payments-create.dart';
import 'package:codix_geofencing/src/ui/widgets/general.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:codix_geofencing/src/ui/salesorder/salesorders-list.dart';
import 'package:codix_geofencing/src/helpers/variables.dart' as variables;
import 'package:codix_geofencing/src/helpers/util.dart' as codixutil;
import 'package:codix_geofencing/src/helpers/page-transition.dart';
import 'package:codix_geofencing/src/ui/salesorder/salesorders-create.dart';

/* class DashboardTabPage extends StatelessWidget {
  
  Future<Item> getItem() async {
    final response = await http.get("https://jsonplaceholder.typicode.com/photos/1");
    final responseJson = json.decode(response.body);
    return Item.fromJson(responseJson);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            bottom: TabBar(
              labelStyle: TextStyle(
                fontFamily: variables.currentFont,
                fontSize: 13,
                fontWeight: FontWeight.bold
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.monetization_on), 
                  text: 'Sales Orders'
                ),
                Tab(
                  icon: Icon(Icons.people), 
                  text: 'Customers'
                ),
                Tab(
                  icon: Icon(Icons.payment), 
                  text: 'Payments'
                ),
                // Tab(icon: Icon(Icons.directions_bike)),
              ],
            ),
            title: Text('Dashboard', style: TextStyle(fontFamily: variables.currentFont)),
          ),
          body: TabBarView(
            children: [
              Scaffold(
                body: Center(
                  child: SalesOrdersPage(),
                ),
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add),
                  backgroundColor: Colors.blue,
                  onPressed: (){
                    Navigator.push(context,
                    PageTransition(type: 
                    PageTransitionType.leftToRightWithFade, child: SalesOrderCreatePage()));
                  },
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              ),
              Scaffold(
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.person_add),
                  backgroundColor: Colors.blue,
                  onPressed: (){
                    Navigator.push(context,
                    PageTransition(type: 
                    PageTransitionType.leftToRightWithFade, child: CustomerCreatePage()));
                  },
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              ),
              Scaffold(
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.payment),
                  backgroundColor: Colors.blue,
                  onPressed: (){

                  },
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              )
              //Icon(Icons.directions_car),
              //Icon(Icons.directions_transit),
              // Icon(Icons.directions_bike),
            ],
          ),
          drawer: Drawer(
            // Add a ListView to the drawer. This ensures the user can scroll
            // through the options in the drawer if there isn't enough vertical
            // space to fit everything.
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Text('Drawer Header', style: TextStyle(fontFamily: variables.currentFont)),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Profile', style: TextStyle(fontFamily: variables.currentFont)),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    // Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings', style: TextStyle(fontFamily: variables.currentFont)),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    // Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About', style: TextStyle(fontFamily: variables.currentFont)),
                  onTap: () {
                    
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Logout', style: TextStyle(fontFamily: variables.currentFont)),
                  onTap: () {
                    // clears the sharedprefs and redirects user back to login page
                    codixutil.clearSharedPrefs().then((prefcleard)
                    {
                      print(prefcleard);
                      Navigator.of(context).pushNamedAndRemoveUntil('/login-page', (Route<dynamic> route) => false);
                    });                                      
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} */

class NewDashboardTabPage extends StatefulWidget {
  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<NewDashboardTabPage> with AutomaticKeepAliveClientMixin<NewDashboardTabPage> {
  String activeTab, email = '', name = '';
  
  @override
  bool get wantKeepAlive => true;


  @override
  void initState() { 
    super.initState();
    var nameEmail = codixutil.getNameEmailFromSharedPrefs().then((onValue){
      setState(() {
        email = onValue.email;
        name = onValue.fullName;
      });
    });

    print(nameEmail);
  }
 
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          
          appBar: AppBar(
            actions: <Widget>[
              new IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // get current tab so as to know which dialog prompt to present to the user
                codixutil.getActiveTab().then((currentTab){
                  setState(() {
                  activeTab =  currentTab;
                  });
                });
              },
            ),
            ],
            backgroundColor: Colors.blueAccent,
            bottom: TabBar(
              labelStyle: TextStyle(
                fontFamily: variables.currentFont,
                fontSize: 13,
                fontWeight: FontWeight.bold
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.monetization_on), 
                  text: 'Sales Orders'
                ),
                Tab(
                  icon: Icon(Icons.people), 
                  text: 'Customers'
                ),
                Tab(
                  icon: Icon(Icons.payment), 
                  text: 'Deposits'
                ), 
                // Tab(icon: Icon(Icons.directions_bike)),
              ],
            ),
            title: Text('XIDOC', style: TextStyle(fontFamily: variables.currentFont),
            ),
          ),
          body: TabBarView(
            children: [
              Scaffold(
                body: Center(
                  child: SalesOrdersPage(),
                ),
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add),
                  backgroundColor: Colors.blue,
                  onPressed: (){
                    Navigator.push(context,
                    PageTransition(type: 
                    PageTransitionType.leftToRightWithFade, child: SalesOrderCreatePage()));
                  },
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              ),
              Scaffold(
                body: Center(
                  child: CustomerListPage()
                ),
                floatingActionButton: FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.person_add),
                  backgroundColor: Colors.blue,
                  onPressed: (){
                    Navigator.push(context,
                      PageTransition(type: 
                      PageTransitionType.leftToRight, child: CustomerCreatePage()
                      )
                    );                    
                  },
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              ),
              Scaffold(
                floatingActionButton: FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.payment),
                  backgroundColor: Colors.blue,
                  onPressed: (){
                    Navigator.push(context,
                      PageTransition(type: 
                      PageTransitionType.leftToRight, child: PaymentsCreatePage()
                      )
                    );
                  },
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              )
              //Icon(Icons.directions_car),
              //Icon(Icons.directions_transit),
              // Icon(Icons.directions_bike),
            ],
          ),
          drawer: Drawer(
            // Add a ListView to the drawer. This ensures the user can scroll
            // through the options in the drawer if there isn't enough vertical
            // space to fit everything.
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                // DrawerHeader(
                //   child: Text(name, style: TextStyle(fontFamily: variables.currentFont, fontSize: 15.0, fontWeight: FontWeight.bold)),
                //   decoration: BoxDecoration(
                //     color: Colors.blue,
                //   ),
                // ),
                new UserAccountsDrawerHeader(
                accountName: new Text(
                  name, style: new TextStyle(
                   fontSize: 18.0, fontFamily: variables.currentFont, fontWeight: FontWeight.bold
                  ),
                ),
                accountEmail: new Text(
                  email, style: new TextStyle(
                    fontSize: 13.0, fontFamily: variables.currentFont, fontWeight: FontWeight.bold),
                )),
                ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Profile', style: TextStyle(fontFamily: variables.currentFont, fontSize: 15.0, fontWeight: FontWeight.bold)),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    // Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings', style: TextStyle(fontFamily: variables.currentFont, fontSize: 15.0, fontWeight: FontWeight.bold)),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    // Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About', style: TextStyle(fontFamily: variables.currentFont, fontSize: 15.0, fontWeight: FontWeight.bold)),
                  onTap: () {
                    
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Logout', style: TextStyle(fontFamily: variables.currentFont, fontSize: 15.0, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    final ConfirmAction confirmAction = await confirmationDialog(context, 'Logout?', 'Are you sure you logout from XIDOC?');
                    if (confirmAction.index == 1) {
                      // clears sharedprefs and redirects the user to the loging page
                      codixutil.clearSharedPrefs().then((prefcleard)
                      {
                        Navigator.of(context).pushNamedAndRemoveUntil('/login-page', (Route<dynamic> route) => false);
                      });                                                          
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class Item {
  final String title, image;

  Item(this.title, this.image);

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(json['title'], json['thumbnailUrl']);
  }
}