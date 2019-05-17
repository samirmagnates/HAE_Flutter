import 'package:hea/Model/QuestionOptions.dart';

class AssessmentTasks {
  String assessmentTaskUuid;
  String assessmentTaskType;
  String assessmentTaskCorrectResponseId;
  String assessmentTaskAnswerIdResponseId;
  String assessmentTaskCorrectResponseText;
  String assessmentTaskAssetUrl;
  String score;
  String prompt;
  String result;
  List<QuestionOptions> responses;
  List<QuestionOptions> answers;

  AssessmentTasks(
      {this.assessmentTaskUuid,
      this.assessmentTaskType,
      this.assessmentTaskCorrectResponseId,
      this.assessmentTaskAnswerIdResponseId,
      this.assessmentTaskCorrectResponseText,
      this.assessmentTaskAssetUrl,
      this.score,
      this.prompt,
      this.result,
      this.responses,
      this.answers});

  AssessmentTasks.fromJSON(Map<String, dynamic> json) {
    assessmentTaskUuid = json['assessment_task_uuid'];
    assessmentTaskType = json['assessment_task_type'];
    assessmentTaskCorrectResponseId =
        json['assessment_task_correct_response_id'];
    assessmentTaskCorrectResponseText =
        json['assessment_task_correct_response_text'];
    assessmentTaskAssetUrl =
        json['assessment_task_asset_url'];
    score = json['score'];
    prompt = json['prompt'];
    if (json['responses'] != null) {
      responses = new List<QuestionOptions>();
      
      List arr = json['responses'];
      arr.forEach((v) {
        responses.add(new QuestionOptions.fromJSON(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['assessment_task_uuid'] = this.assessmentTaskUuid;
    data['assessment_task_type'] = this.assessmentTaskType;
    data['assessment_task_correct_response_id'] =
        this.assessmentTaskCorrectResponseId;
        data['assessment_task_correct_response_text'] =
        this.assessmentTaskCorrectResponseText;
        data['assessment_task_asset_url'] =
        this.assessmentTaskAssetUrl;
    data['score'] = this.score;
    data['prompt'] = this.prompt;
    if (this.responses != null) {
      data['responses'] = this.responses.map((v) => v.toJson()).toList();
    }
    return data;
  }
}