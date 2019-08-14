class AssessmentMetaData {
  String assessorUuid;
  String assessorName;
  String candidateUuid;
  String candidateName;
  String assessmentUuid;
  String assessmentName;
  String assessmentIntroduction;
  String assessmentPassmark;
  String assessmentObtainmark;
  String assessmentResult;
  String assessmentComment;
  int assessmentPending;



  AssessmentMetaData(
      {this.assessorUuid,
      this.assessorName,
      this.candidateUuid,
      this.candidateName,
      this.assessmentUuid,
      this.assessmentName,
      this.assessmentIntroduction,
      this.assessmentPassmark,
      this.assessmentObtainmark,
      this.assessmentResult,
      this.assessmentComment,
      this.assessmentPending});

  /*
  convert json to AssessmentMetaData class 
  if specific value is not exist than set default value
  return AssessmentMetaData object.
  */

  AssessmentMetaData.fromJSON(Map<String, dynamic> json) {
    assessorUuid = json['assessor_uuid'];
    assessorName = json['assessor_name'];
    candidateUuid = json['candidate_uuid'];
    candidateName = json['candidate_name'];
    assessmentUuid = json['assessment_uuid'];
    assessmentName = json['assessment_name'];
    assessmentIntroduction = json['assessment_introduction'];
    assessmentPassmark = json['assessment_passmark'];
    assessmentObtainmark = json['assessment_obtainmark'] != null ? json['assessment_obtainmark']:'';
    assessmentResult = json['assessment_result'] != null ? json['assessment_result']:'';
    assessmentComment = json['assessment_comment'] != null ? json['assessment_comment']:'';
    assessmentPending = json['assessment_result_Is_pending'] != null ? json['assessment_result_Is_pending']:0;
  }

  /*
  convert AssessmentMetaData class to map
  if specific value is not exist than set default value
  return Map<String:dynamic>
  */
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['assessor_uuid'] = this.assessorUuid;
    data['assessor_name'] = this.assessorName;
    data['candidate_uuid'] = this.candidateUuid;
    data['candidate_name'] = this.candidateName;
    data['assessment_uuid'] = this.assessmentUuid;
    data['assessment_name'] = this.assessmentName;
    data['assessment_introduction'] = this.assessmentIntroduction;
    data['assessment_passmark'] = this.assessmentPassmark;
    data['assessment_obtainmark'] = this.assessmentObtainmark;
    data['assessment_result'] = this.assessmentResult;
    data['assessment_comment'] = this.assessmentComment;
    data['assessment_result_Is_pending'] = this.assessmentPending;
    return data;
  }
}