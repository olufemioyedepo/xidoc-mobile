class CustomerForSave {
  String custGroup;
  String name;
  String currency;
  String personnelNumber;
  String hcmWorkerRecId;
  String phone;
  String location;
  String city;
  String state;

  CustomerForSave({
    this.custGroup,
    this.name,
    this.currency,
    this.personnelNumber,
    this.hcmWorkerRecId,
    this.phone,
    this.location,
    this.city,
    this.state
  });

  Map toMap() {
    var map = new Map<String, dynamic>();

    map["custGroup"] = custGroup;
    map["name"] = name;
    map["currency"] = currency;
    map["personnelNumber"] = personnelNumber;
    map["hcmWorkerRecId"] = hcmWorkerRecId;
    map["phone"] = phone;
    map["location"] = location;
    map["city"] = city;
    map["state"] = state;

    return map;
  }
}