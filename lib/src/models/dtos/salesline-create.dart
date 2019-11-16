//import 'dart:ffi';

class SalesLineCreateObject {
  final String salesId;
  final int salesQty;
  final String warehouse;
  final String itemId;
  final String salesAgentLongitude;
  final String salesAgentLatitude;

  SalesLineCreateObject({this.salesId, this.salesQty, this.warehouse, this.itemId, this.salesAgentLongitude, this.salesAgentLatitude});

  factory SalesLineCreateObject.fromJson(Map<String, dynamic> json) {
    return SalesLineCreateObject(
      salesId: json['salesId'],
      salesQty: json['salesQty'],
      warehouse: json['warehouse'],
      itemId: json['itemId'],
      salesAgentLongitude: json['salesAgentLongitude'],
      salesAgentLatitude: json['salesAgentLatitude']
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["salesId"] = salesId;
    map["salesQty"] = salesQty;
    map["warehouse"] = warehouse;
    map["itemId"] = itemId;
    map["salesAgentLongitude"] = salesAgentLongitude;
    map["salesAgentLatitude"] = salesAgentLatitude;
 
    return map;
  }
}



class SalesLineCreateObjectResponse {
  final String salesId;
  final int salesQty;
  final int lineDisc;
  final String dateTimeCreated;
  final String warehouse;
  final String itemId;
  final String staffPersonnelNumber;
  final String salesAgentLongitude;
  final String salesAgentLatitude;

  SalesLineCreateObjectResponse({this.lineDisc, this.dateTimeCreated, this.staffPersonnelNumber, this.salesId, this.salesQty, this.warehouse, this.itemId, this.salesAgentLongitude, this.salesAgentLatitude});

  factory SalesLineCreateObjectResponse.fromJson(Map<dynamic, dynamic> json) {
    return SalesLineCreateObjectResponse(
      dateTimeCreated: json['dateTimeCreated'],
      staffPersonnelNumber: json['staffPersonnelNumber'],
      salesId: json['salesId'],
      lineDisc :json['lineDisc'],
      salesQty: json['salesQty'],
      warehouse: json['warehouse'],
      itemId: json['itemId'],
      salesAgentLongitude: json['salesAgentLongitude'],
      salesAgentLatitude: json['salesAgentLatitude']
      );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["dateTimeCreated"] = dateTimeCreated;
    map["staffPersonnelNumber"] = staffPersonnelNumber;
    map["salesId"] = salesId;
    map["salesQty"] = salesQty;
    map["warehouse"] = warehouse;
    map["itemId"] = itemId;
    map["salesAgentLongitude"] = salesAgentLongitude;
    map["salesAgentLatitude"] = salesAgentLatitude;

    return map;
  }
}