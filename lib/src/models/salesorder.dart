class SalesOrdersList {
  List<SalesOrder> salesOrders;

  SalesOrdersList({this.salesOrders});

  factory SalesOrdersList.fromJson(List<dynamic> json){
    //print(json);
    List<SalesOrder> salesOrderList = new List<SalesOrder>();
    salesOrderList = json.map((i) => SalesOrder.fromJson(i)).toList();
    return new SalesOrdersList(
      salesOrders: salesOrderList
    );
  }
}

class SalesOrder {
  String salesOrderNumber;
  String salesOrderName;
  String invoiceCustomerAccountNumber;
  String salesAgentLongitude;
  String salesAgentLatitude;
  String createdOn;
  String salesOrderStatus;
  String workflowStatus;
  String totalDiscountPercentage;

  SalesOrder({
    this.salesOrderNumber,
    this.salesOrderName,
    this.invoiceCustomerAccountNumber,
    this.salesAgentLongitude,
    this.salesAgentLatitude,
    this.createdOn,
    this.salesOrderStatus,
    this.workflowStatus,
    this.totalDiscountPercentage
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return new SalesOrder(
      salesOrderNumber: json['salesOrderNumber'],
      salesOrderName: json['salesOrderName'],
      invoiceCustomerAccountNumber: json['invoiceCustomerAccountNumber'],
      salesAgentLongitude: json['salesAgentLongitude'],
      salesAgentLatitude: json['salesAgentLatitude'],
      createdOn: json['createdOn'],
      salesOrderStatus: json['salesOrderStatus'],
      workflowStatus: json['workflowStatus']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['salesOrderNumber'] = this.salesOrderNumber;
    data['salesOrderName'] = this.salesOrderName;
    data['invoiceCustomerAccountNumber'] = this.invoiceCustomerAccountNumber;
    data['salesAgentLongitude'] = this.salesAgentLongitude;
    data['salesAgentLatitude'] = this.salesAgentLatitude;
    data['createdOn'] = this.createdOn;
    data['salesOrderStatus'] = this.salesOrderStatus;
    data['totalDiscountPercentage'] = this.totalDiscountPercentage;
    return data;
  }
}