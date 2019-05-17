class QuestionOptions {
  String id;
  String text;

  QuestionOptions({this.id, this.text});

  QuestionOptions.fromJSON(Map<String, dynamic> json) {
    id = json['id'];
    text = json['#text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['#text'] = this.text;
    return data;
  }
}