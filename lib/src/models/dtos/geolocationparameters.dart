class AgentGeolocationParameter {
  String currentGeolocationLatitude;
  String currentGeolocationLongitude;
  String hcmWorkerRecId;
  // String agentLatitude;
  // String agentLongitude;
  // double radius;
  
  AgentGeolocationParameter({this.currentGeolocationLatitude, this.currentGeolocationLongitude, this.hcmWorkerRecId});

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["currentGeolocationLatitude"] = currentGeolocationLatitude;
    map["currentGeolocationLongitude"] = currentGeolocationLongitude;
    map["hcmWorkerRecId"] = hcmWorkerRecId;
    // map["agentLatitude"] = agentLatitude;
    // map["agentLongitude"] = agentLongitude;
    // map["radius"] = radius;
 
    return map;
  }
}

class RangeChecker {
  String agentLatitude;
  String agentLongitude;
  String employeeId;
  
  RangeChecker({this.agentLatitude, this.agentLongitude, this.employeeId});

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["agentLatitude"] = agentLatitude;
    map["agentLongitude"] = agentLongitude;
    map["employeeId"] = employeeId;
 
    return map;
  }
}