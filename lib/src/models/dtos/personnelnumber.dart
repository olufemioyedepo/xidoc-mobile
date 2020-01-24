class PersonnelNumber {
  //final String value;
  String value;
  PersonnelNumber({ this.value });

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["value"] = value;

    return map;
  }
}