class SalesOrderForSave {
  String dateTimeCreated;
  String custAccount;
  String staffPersonnelNumber;
  String salesName;
  String salesType;
  String salesAgentLongitude;
  String salesAgentLatitude;
  String totalDiscountPercentage;

  SalesOrderForSave({
    this.dateTimeCreated,
    this.custAccount,
    this.staffPersonnelNumber,
    this.salesName,
    this.salesType,
    this.salesAgentLongitude,
    this.salesAgentLatitude,
    this.totalDiscountPercentage
  });

  factory SalesOrderForSave.fromJson(Map<String, dynamic> json) {
    return new SalesOrderForSave(
      dateTimeCreated: json['dateTimeCreated'],
      custAccount: json['custAccount'],
      staffPersonnelNumber: json['staffPersonnelNumber'],
      salesName: json['salesName'],
      salesType: json['salesType'],
      salesAgentLongitude: json['salesAgentLongitude'],
      salesAgentLatitude: json['salesAgentLatitude'],
      totalDiscountPercentage: json['totalDiscountPercentage']
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["dateTimeCreated"] = dateTimeCreated;
    map["custAccount"] = custAccount;
    map["staffPersonnelNumber"] = staffPersonnelNumber;
    map["salesName"] = salesName;
    map["salesType"] = salesType;
    map["salesAgentLongitude"] = salesAgentLongitude;
    map["salesAgentLatitude"] = salesAgentLatitude;
    map["totalDiscountPercentage"] = totalDiscountPercentage;
 
    return map;
  }
}

class SalesOrderForSaveResponse {
  String dateTimeCreated;
  String custAccount;
  String staffPersonnelNumber;
  String salesName;
  String salesType;
  String salesAgentLongitude;
  String salesAgentLatitude;

  SalesOrderForSaveResponse({
    this.dateTimeCreated,
    this.custAccount,
    this.staffPersonnelNumber,
    this.salesName,
    this.salesType,
    this.salesAgentLongitude,
    this.salesAgentLatitude
  });

  factory SalesOrderForSaveResponse.fromJson(Map<String, dynamic> json) {
    return new SalesOrderForSaveResponse(
      dateTimeCreated: json['dateTimeCreated'],
      custAccount: json['custAccount'],
      staffPersonnelNumber: json['staffPersonnelNumber'],
      salesName: json['salesName'],
      salesType: json['salesType'],
      salesAgentLongitude: json['salesAgentLongitude'],
      salesAgentLatitude: json['salesAgentLatitude']
    );
  }

  Map toMap() {
    var salesOrderCreateResponse = new Map<String, dynamic>();
    salesOrderCreateResponse["dateTimeCreated"] = dateTimeCreated;
    salesOrderCreateResponse["custAccount"] = custAccount;
    salesOrderCreateResponse["staffPersonnelNumber"] = staffPersonnelNumber;
    salesOrderCreateResponse["salesName"] = salesName;
    salesOrderCreateResponse["salesType"] = salesType;
    salesOrderCreateResponse["salesAgentLongitude"] = salesAgentLongitude;
    salesOrderCreateResponse["salesAgentLatitude"] = salesAgentLatitude;
 
    return salesOrderCreateResponse;
  }
}