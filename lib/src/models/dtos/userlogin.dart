class UserLogin {
  final String email;
  final String password;
  // final int price;

  UserLogin({this.email, this.password});

  factory UserLogin.fromJson(Map<String, dynamic> json) {
    return UserLogin(
      email: json['email'],
      password: json['password']
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["email"] = email;
    map["password"] = password;
 
    return map;
  }
}

class LoginResponse {
  final int hcmWorkerRecId;
  final String personnelNumber;
  final String lastName;
  final String firstName;
  final String name;
  final String primaryContactEmail;
  final String salesAgentLongitude;
  final String salesAgentLatitude;
  final String isSalesAgent;
  final double coverageRadius;
  final double outOfCoverageLimit;
  final double commissionPercentageRate;
  final String agentLocation;

  LoginResponse({
    this.hcmWorkerRecId, this.personnelNumber, this.lastName, this.firstName, this.name, this.primaryContactEmail, 
    this.salesAgentLongitude, this.salesAgentLatitude, this.isSalesAgent, this.coverageRadius, this.outOfCoverageLimit, 
    this.commissionPercentageRate, this.agentLocation 
  });

  factory LoginResponse.fromJson(Map<String, dynamic> loginResponseJson) {
    return LoginResponse(
      hcmWorkerRecId: loginResponseJson['hcmWorkerRecId'],
      personnelNumber: loginResponseJson['personnelNumber'],
      lastName: loginResponseJson['lastName'],
      firstName: loginResponseJson['firstName'],
      name: loginResponseJson['name'],
      primaryContactEmail: loginResponseJson['primaryContactEmail'],
      salesAgentLongitude: loginResponseJson['salesAgentLongitude'],
      salesAgentLatitude: loginResponseJson['salesAgentLatitude'],
      isSalesAgent: loginResponseJson['isSalesAgent'],
      coverageRadius: loginResponseJson['coverageRadius'],
      outOfCoverageLimit: loginResponseJson['outOfCoverargeLimit'],
      commissionPercentageRate: loginResponseJson['commissionPercentageRate'],
      agentLocation: loginResponseJson['agentLocation'],
    );
  }

  Map toMap() {
    var loginResponseMap = new Map<String, dynamic>();

    loginResponseMap["hcmWorkerRecId"] = hcmWorkerRecId;
    loginResponseMap["personnelNumber"] = personnelNumber;
    loginResponseMap["lastName"] = lastName;
    loginResponseMap["firstName"] = firstName;
    loginResponseMap["name"] = name;
    loginResponseMap["primaryContactEmail"] = primaryContactEmail;
    loginResponseMap["salesAgentLongitude"] = salesAgentLongitude;
    loginResponseMap["salesAgentLatitude"] = salesAgentLatitude;
    loginResponseMap["isSalesAgent"] = isSalesAgent;
    loginResponseMap["coverageRadius"] = coverageRadius;
    loginResponseMap["outOfCoverargeLimit"] = outOfCoverageLimit;
    loginResponseMap["commissionPercentageRate"] = commissionPercentageRate;
    loginResponseMap["agentLocation"] = agentLocation;
 
    return loginResponseMap;
  }
}

class ProductResponse {
  final String id;

  ProductResponse({this.id});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
        id: json['id'],
      );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    return map;
  }
}
