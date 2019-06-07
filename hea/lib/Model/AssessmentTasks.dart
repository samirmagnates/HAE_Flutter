import 'package:hea/Model/QuestionOptions.dart';
import 'dart:convert';
class AssessmentTasks {
  String assessmentTaskUuid;
  String assessmentTaskType;
  String assessmentTaskCorrectResponseId;
  String assessmentTaskAnswerIdResponseId;
  String assessmentTaskCorrectResponseText;
  String assessmentTaskAnswerResponseText;
  String assessmentTaskAssetUrl;
  String score;
  String prompt;
  String result;
  String responses;
  //List<QuestionOptions> responses;
  //List<QuestionOptions> answers;
  String assessmentTaskUploadFormat;
  String assessmentTaskLocalFile;
  String assessmentUuid;
  String assessorUuid;




  AssessmentTasks(
      {this.assessmentTaskUuid,
      this.assessmentTaskType,
      this.assessmentTaskCorrectResponseId,
      this.assessmentTaskAnswerIdResponseId,
      this.assessmentTaskCorrectResponseText,
      this.assessmentTaskAnswerResponseText,
      this.assessmentTaskAssetUrl,
      this.score,
      this.prompt,
      this.result,
      this.responses,
      //this.answers,
      this.assessmentTaskUploadFormat,
      this.assessmentTaskLocalFile,
      this.assessmentUuid,
      this.assessorUuid}
  );

  AssessmentTasks.fromJSON(Map<String, dynamic> jsonRes) {
    assessmentTaskUuid = jsonRes['assessment_task_uuid'];
    assessmentTaskType = jsonRes['assessment_task_type'];
    assessmentTaskCorrectResponseId = jsonRes['assessment_task_correct_response_id'];
    assessmentTaskCorrectResponseText = jsonRes['assessment_task_correct_response_text'];
    assessmentTaskAssetUrl = jsonRes['assessment_task_asset_url'];
    score = jsonRes['score'];
    prompt = jsonRes['prompt'];
    //var jsonString = json.encode(jsonRes['responses']);
    var jsonString = jsonEncode(jsonRes['responses']);
    responses = jsonString;
    /*if (json['responses'] != null) {
      responses = new List<QuestionOptions>();
      List arr = json['responses'];
      arr.forEach((v) {
        responses.add(new QuestionOptions.fromJSON(v));
      });
    }*/

    assessmentTaskAnswerIdResponseId = jsonRes['assessment_task_answer_response_id'] != null ? jsonRes['assessment_task_answer_response_id']:'';
    assessmentTaskAnswerResponseText = jsonRes['assessment_task_answer_response_text'] != null ? jsonRes['assessment_task_answer_response_text']:'';
    result = jsonRes['result'] != null ? jsonRes['result']:'';
    assessmentTaskUploadFormat = jsonRes['assessment_task_upload_format'] != null ? jsonRes['assessment_task_upload_format']:'';
    assessmentTaskLocalFile = jsonRes['assessment_task_local_file'] != null ? jsonRes['assessment_task_local_file']:'';
    assessmentUuid = jsonRes['assessment_uuid'] != null ? jsonRes['assessment_uuid']:'';
    assessorUuid = jsonRes['assessor_uuid'] != null ? jsonRes['assessor_uuid']:'';
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['assessment_task_uuid'] = this.assessmentTaskUuid;
    data['assessment_task_type'] = this.assessmentTaskType;
    data['assessment_task_correct_response_id'] = this.assessmentTaskCorrectResponseId;
    data['assessment_task_correct_response_text'] = this.assessmentTaskCorrectResponseText;
    data['assessment_task_asset_url'] = this.assessmentTaskAssetUrl;
    data['score'] = this.score;
    data['prompt'] = this.prompt;
    data['responses'] = this.responses;
    /*if (this.responses != null) {
      data['responses'] = this.responses.map((v) => v.toJson()).toList();
    }*/
    data['assessment_task_answer_response_id'] = this.assessmentTaskAnswerIdResponseId;
    data['assessment_task_answer_response_text'] = this.assessmentTaskAnswerResponseText;
    data['result'] = this.result;
    data['assessment_task_upload_format'] = this.assessmentTaskUploadFormat;
    data['assessment_task_local_file'] = this.assessmentTaskLocalFile;
    data['assessment_uuid'] = this.assessmentUuid;
    data['assessor_uuid'] = this.assessorUuid;
    return data;
  }
}