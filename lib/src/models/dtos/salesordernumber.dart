class SalesOrderNumber {
  final String orderNumber;

  SalesOrderNumber({ this.orderNumber });

  factory SalesOrderNumber.fromJson(Map<String, dynamic> json) {
    return SalesOrderNumber(
      orderNumber: json['orderNumber']
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["orderNumber"] = orderNumber;

    return map;
  }
}