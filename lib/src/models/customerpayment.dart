class CustomerPaymentsList {
  List<CustomerPayment> customerPaymentList;

  CustomerPaymentsList({this.customerPaymentList});

  factory CustomerPaymentsList.fromJson(List<dynamic> json){
    List<CustomerPayment> customersList = new List<CustomerPayment>();
    customersList = json.map((i) => CustomerPayment.fromJson(i)).toList();
    return new CustomerPaymentsList(
      customerPaymentList: customersList
    );
  }
}

class CustomerPayment {
  String fiscalYear;
  String month;
  double amountPaid;
  String pmtMethod;
  String processingStatus;
  String custName;
  String paymentDate;
  String dateTimeCreated;

  CustomerPayment({
    this.fiscalYear,
    this.month,
    this.amountPaid,
    this.pmtMethod,
    this.processingStatus,
    this.custName,
    this.paymentDate,
    this.dateTimeCreated
  });

  factory CustomerPayment.fromJson(Map<String, dynamic> json) {
    return new CustomerPayment(
      fiscalYear: json['fiscalYear'],
      month: json['month'],
      amountPaid: json['amountPaid'],
      pmtMethod: json['pmtMethod'],
      processingStatus: json['processingStatus'],
      custName: json['custName'],
      paymentDate: json['paymentDate'],
      dateTimeCreated: json['dateTimeCreated'],
    );
  }
}