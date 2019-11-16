class CustomersList {
  List<Customer> customers;

  CustomersList({this.customers});

  factory CustomersList.fromJson(List<dynamic> json){
    //print(json);
    List<Customer> customersList = new List<Customer>();
    customersList = json.map((i) => Customer.fromJson(i)).toList();
    return new CustomersList(
      customers: customersList
    );
  }
}

class Customer {
  String customerAccount;
  String customerGroupId;
  String organizationName;
  String primaryContactPhone;
  

  Customer({
    this.customerAccount,
    this.customerGroupId,
    this.organizationName,
    this.primaryContactPhone
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return new Customer(
      customerAccount: json['customerAccount'],
      customerGroupId: json['customerGroupId'],
      organizationName: json['organizationName'],
      primaryContactPhone: json['primaryContactPhone']
    );
  }
}