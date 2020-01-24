//import 'dart:ffi';

class SalesLineCreateObject {
  final String salesOrderNumber;
  final String lineDiscountPercentage;
  final String lineDiscountAmount;
  final int orderedSalesQuantity;
  final String shippingWarehouseId;
  final String itemNumber;
  

  SalesLineCreateObject({this.salesOrderNumber, this.lineDiscountPercentage, this.lineDiscountAmount, this.orderedSalesQuantity, this.shippingWarehouseId, this.itemNumber});

  factory SalesLineCreateObject.fromJson(Map<String, dynamic> json) {
    return SalesLineCreateObject(
      salesOrderNumber: json['salesOrderNumber'],
      lineDiscountPercentage: json['lineDiscountPercentage'],
      lineDiscountAmount: json['lineDiscountAmount'],
      orderedSalesQuantity: json['orderedSalesQuantity'],
      shippingWarehouseId: json['shippingWarehouseId'],
      itemNumber: json['itemNumber']
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["salesOrderNumber"] = salesOrderNumber;
    map["lineDiscountPercentage"] = lineDiscountPercentage;
    map["lineDiscountAmount"] = lineDiscountAmount;
    map["orderedSalesQuantity"] = orderedSalesQuantity;
    map["shippingWarehouseId"] = shippingWarehouseId;
    map["itemNumber"] = itemNumber;
 
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