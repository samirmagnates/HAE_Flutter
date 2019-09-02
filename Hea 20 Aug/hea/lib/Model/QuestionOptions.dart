
//QuestionOptions is option for AssessmentTasks
class QuestionOptions {
  String id;
  String text;

  QuestionOptions({this.id, this.text});

  /*
  convert json to QuestionOptions class 
  if specific value is not exist than set default value
  return QuestionOptions object.
  */
  QuestionOptions.fromJSON(Map<String, dynamic> json) {
    id = json['id'];
    text = json['#text'];
  }

  /*
  convert QuestionOptions class to map
  if specific value is not exist than set default value
  return Map<String:dynamic>
  */

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['#text'] = this.text;
    return data;
  }
}