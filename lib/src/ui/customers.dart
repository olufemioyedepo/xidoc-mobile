import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:codix_geofencing/src/helpers/variables.dart' as variables;

class CustomersPage extends StatefulWidget {
  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customers', style: TextStyle(fontFamily: variables.currentFont, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Text('Customers Page'),
      ),
    );
  }
}