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
  double whtDeducted;
  int recordId;
  String journalNum;
  String bankName;
  String postedWithJournalNum;
  String sysBankAccount;
  String currency;
  String pmtMethod;
  String processingStatus;
  String custName;
  String paymentDate;
  String dateTimeCreated;

  CustomerPayment({
    this.fiscalYear,
    this.month,
    this.amountPaid,
    this.whtDeducted,
    this.recordId,
    this.journalNum,
    this.bankName,
    this.postedWithJournalNum,
    this.sysBankAccount,
    this.currency,
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
      whtDeducted: json['whtDeducted'],
      recordId: json['recordId'],
      journalNum: json['journalNum'],
      bankName: json['bankName'],
      postedWithJournalNum: json['postedWithJournalNum'],
      sysBankAccount: json['sysBankAccount'],
      currency: json['currency'],
      pmtMethod: json['pmtMethod'],
      processingStatus: json['processingStatus'],
      custName: json['custName'],
      paymentDate: json['paymentDate'],
      dateTimeCreated: json['dateTimeCreated'],
    );
  }
}