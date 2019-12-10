class CustomerDeposit {
  double amountPaid;
  String bankName;
  String currency;
  String fiscalYear;
  String custId;
  String custName;
  String depositorName;
  String employeeId;
  String employeeName;
  String month;
  String paymentDate;
  String pmtMethod;
  String processingStatus;
  double wHTDeducted;

  CustomerDeposit(
    { 
      this.amountPaid, this.bankName, this.currency, this.fiscalYear, this.custId,
      this.custName, this.depositorName, this.employeeId, this.employeeName, this.month,
      this.paymentDate, this.pmtMethod, this.processingStatus, this.wHTDeducted
    }
  );

  factory CustomerDeposit.fromJson(Map<String, dynamic> json) {
    return new CustomerDeposit(
      amountPaid: json['amountPaid'],
      bankName: json['bankName'],
      currency: json['currency'],
      fiscalYear: json['fiscalYear'],
      custId: json['custId'],
      custName: json['custName'],
      depositorName: json['depositorName'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      month: json['month'],
      paymentDate: json['paymentDate'],
      pmtMethod: json['pmtMethod'],
      processingStatus: json['processingStatus'],
      wHTDeducted: json['wHTDeducted']
    );
  }

  Map toMap() {
    var map = new Map<dynamic, dynamic>();
    map["amountPaid"] = amountPaid;
    map["bankName"] = bankName;
    map["currency"] = currency;
    map["fiscalYear"] = fiscalYear;
    map["custId"] = custId;
    map["custName"] = custName;
    map["depositorName"] = depositorName;
    map["employeeId"] = employeeId;
    map["employeeName"] = employeeName;
    map["month"] = month;
    map["paymentDate"] = paymentDate;
    map["pmtMethod"] = pmtMethod;
    map["processingStatus"] = processingStatus;
    map["wHTDeducted"] = wHTDeducted;

    return map;
  }
}