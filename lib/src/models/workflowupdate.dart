class WorkflowUpdate {
  String salesId;
  String workflowStatusAction;

  WorkflowUpdate({ this.salesId, this.workflowStatusAction });

  Map toMap() {
    var map = new Map<String, dynamic>();

    map["salesId"] = salesId;
    map["workflowStatusAction"] = workflowStatusAction;

    return map;
  }
}