class SalesLineList {
  List<SalesLine> salesLines;

  SalesLineList({this.salesLines});

  factory SalesLineList.fromJson(List<dynamic> json) {
    List<SalesLine> salesLineList = new List<SalesLine>();
    salesLineList = json.map((i) => SalesLine.fromJson(i)).toList();

    return new SalesLineList(
      salesLines: salesLineList
    );
  }
}


class SalesLine {
  String productName;
  String itemNumber;
  String salesOrderNumber;
  String shippingWarehouseId;
  String salesUnitSymbol;
  //String requestedReceiptDate;
  String createdOn;
  double salesPrice;
  double lineAmount;
  int orderedSalesQuantity;
  int salesLineRecId;

  SalesLine({
    this.productName,
    this.itemNumber,
    this.salesOrderNumber,
    this.shippingWarehouseId,
    this.salesUnitSymbol,
    this.createdOn,
    this.salesPrice,
    this.lineAmount,
    this.orderedSalesQuantity,
    this.salesLineRecId
  });

  factory SalesLine.fromJson(Map<String, dynamic> json) {
    return new SalesLine(
      productName: json['productName'],
      itemNumber: json['itemNumber'],
      salesOrderNumber: json['salesOrderNumber'],
      shippingWarehouseId: json['shippingWarehouseId'],
      salesUnitSymbol: json['salesUnitSymbol'],
      createdOn: json['createdOn'],
      salesPrice: json['salesPrice'],
      lineAmount: json['lineAmount'],
      orderedSalesQuantity: json['orderedSalesQuantity'],
      salesLineRecId: json['salesLineRecId'],
    );
  }
}