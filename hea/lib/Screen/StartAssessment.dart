import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hea/Model/AssessmentTasks.dart';
import 'package:hea/Model/AssessmentMetaData.dart';
import 'package:hea/Utils/AppUtils.dart';
import 'package:hea/Model/QuestionOptions.dart';
class StartAssessment extends StatefulWidget {
  @override

  StartAssessment({Key key,@required this.responsData}) : super(key: key);

  var responsData;

  _StartAssessmentState createState() => _StartAssessmentState();
}

class _StartAssessmentState extends State<StartAssessment> {

    static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();  
    TextEditingController txtAnswer = TextEditingController();
    List<AssessmentTasks> arrAssessmentTask;
    AssessmentMetaData assessmentMetaData;
    List<String> arrSelectedOption = List<String>();
    AssessmentTasks currentAssessmentTask;
    int totalTask;
    int currentTaskIndex;
    String noDataMessage;
    String candidateName = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.responsData != null){
      
      if(widget.responsData['assessment_meta'] != null){
        Map meta = widget.responsData['assessment_meta'];
        this.assessmentMetaData = AssessmentMetaData.fromJSON(meta);

        candidateName = this.assessmentMetaData.candidateName != null? this.assessmentMetaData.candidateName : '';
      }

      if(widget.responsData['assessment_tasks'] != null){
        currentTaskIndex = 0;
        Iterable list = widget.responsData['assessment_tasks'];
        this.arrAssessmentTask = list.map((model) => AssessmentTasks.fromJSON(model)).toList();
        totalTask = this.arrAssessmentTask.length;
        if(this.totalTask > 0){
            setState(() {
              this.currentAssessmentTask = this.arrAssessmentTask[currentTaskIndex];
            });
        } else {
            setState(() {
              noDataMessage = 'No data found';
            });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading:Container(
          padding: EdgeInsets.only(right: 10),
          width: 35,
          height: 35,
          child: IconButton(
            icon: Image.asset(ThemeImage.image_back),
            onPressed: () => Navigator.of(context).pop(),
        )
        ), 
        title: FittedBox(
          child: Text(
                          AppConstant.kTitle_AssessmentHeader,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: ThemeFont.font_pourceSanPro,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.right,
                        ),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                decoration: BoxDecoration(
                  color:ThemeColor.theme_dark 
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                          candidateName,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: ThemeFont.font_pourceSanPro,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.right,
                        ),
                  )
                ),
              ),
              this.currentAssessmentTask != null? getQuestionWidget():Container()
            ],
          ),
      ),
      ),
      bottomNavigationBar:this.currentAssessmentTask != null?Container(
        height: 60,
        decoration: BoxDecoration(
          color: ThemeColor.theme_blue
        ),
        child: FlatButton(
                          onPressed: () => _endAssessment(),
                          child: Center(
                            child: Text(
                                AppConstant.kTitle_EndAssessment,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: ThemeFont.font_pourceSanPro,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0),
                              ),
                          ),
                        ),
      ):SizedBox(
        width: 0.0,
        height: 0.0,
      ),
    );
  }

  /// End Assessment will complete assessment
  /// change its status in database
  void _endAssessment(){

  }

///  Get Widget as per task type
///  Like singele selection, multiple,text,video,audio etc
///  task type is string to chekc is it not null and not empty
///  if null or empty than show error messess with white screen  
  Widget getQuestionWidget(){
    String qustionType = this.currentAssessmentTask.assessmentTaskType;
    if(qustionType != null && qustionType.isNotEmpty){
        switch (qustionType) {
        case QuestionType.question_singleAnswer:
          return questionOptionAnswer();
          break;
        case QuestionType.question_multipleAnswer:
            return questionOptionAnswer();
          break;
        case QuestionType.question_boolAnswer:
          return questionOptionAnswer();
          break;
        case QuestionType.question_textAnswer:
          return questionTextInputAnswer();
        break;
        case QuestionType.question_intgerAnswer:
          return questionTextInputAnswer();
        break;
        default:
          return Container(
              child: Center(
                  child:Text(
                    'Remaining task is under development',
                    style: TextStyle(
                      color: ThemeColor.theme_blue,
                      fontFamily: ThemeFont.font_pourceSanPro,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
              ),
          );
      }
    } else {
      return Container(
        child: Center(
          child: Text(
                    AppMessage.kError_SomethingWentWrong,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: ThemeFont.font_pourceSanPro,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.right,
                  ),
        ),
      );
    }
  }

/// Next button is use for show next question
/// if task is last task than show result screen
/// else if increase current index set next task as current
/// clear arrSelectedOption array 
  void clickForNext(){
        this.currentTaskIndex++;
        if(this.currentAssessmentTask.assessmentTaskType == QuestionType.question_textAnswer || this.currentAssessmentTask.assessmentTaskType == QuestionType.question_intgerAnswer){
            this.txtAnswer.text = '';
        }
        setState(() {
          if(this.currentTaskIndex < this.arrAssessmentTask.length){
            this.arrSelectedOption.clear();
            this.currentAssessmentTask = this.arrAssessmentTask[this.currentTaskIndex];
          } else {

        }
          
      });
  }


  /// Check for result use for sumbit result
  /// if user not select any option than show error message
  /// else check user is pass or fail as per task type
  /// set result and selected answer propery to current task
  /// show reslul with correct or wornge answer
  /// hide check butten and show next button for next task
  void checkForResult(){

    if(this.currentAssessmentTask.result == null){
        switch (this.currentAssessmentTask.assessmentTaskType) {
        case QuestionType.question_singleAnswer:
              if(arrSelectedOption == null || arrSelectedOption.isEmpty){
                  AppUtils.showInSnackBar(_scaffoldKey, AppMessage.kError_QuestionSelecteError);
              } else {
                  List<String> arrCorrectAnswer =  this.currentAssessmentTask.assessmentTaskCorrectResponseId.split(',');
                  String result = 'pass';
                  for(String option in arrSelectedOption) {
                    if(arrCorrectAnswer.contains(option) == false){
                        result = 'fail';
                        break;
                    }
                  }
                  
                  setState(() {
                      this.currentAssessmentTask.result = result;
                      this.currentAssessmentTask.assessmentTaskAnswerIdResponseId = arrSelectedOption.join(',');
                      this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
                  });
              }
              
          break;
          case QuestionType.question_multipleAnswer:
              if(arrSelectedOption == null || arrSelectedOption.isEmpty){
                  AppUtils.showInSnackBar(_scaffoldKey, AppMessage.kError_QuestionSelecteError);
              } else {
                  List<String> arrCorrectAnswer =  this.currentAssessmentTask.assessmentTaskCorrectResponseId.split(',');
                  String result = 'pass';
                  for(String option in arrSelectedOption) {
                    if(arrCorrectAnswer.contains(option) == false){
                        result = 'fail';
                        break;
                    }
                  }
                  
                  setState(() {
                      this.currentAssessmentTask.result = result;
                      this.currentAssessmentTask.assessmentTaskAnswerIdResponseId = arrSelectedOption.join(',');
                      this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
                  });
              }
          break;
          case QuestionType.question_boolAnswer:
              if(arrSelectedOption == null || arrSelectedOption.isEmpty){
                  AppUtils.showInSnackBar(_scaffoldKey, AppMessage.kError_QuestionSelecteError);
              } else {
                  List<String> arrCorrectAnswer =  this.currentAssessmentTask.assessmentTaskCorrectResponseId.split(',');
                  String result = 'pass';
                  for(String option in arrSelectedOption) {
                    if(arrCorrectAnswer.contains(option) == false){
                        result = 'fail';
                        break;
                    }
                  }
                  setState(() {
                      this.currentAssessmentTask.result = result;
                      this.currentAssessmentTask.assessmentTaskAnswerIdResponseId = arrSelectedOption.join(',');
                      this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
                  });
              }
          break;
          case QuestionType.question_textAnswer:
              if(arrSelectedOption == null || arrSelectedOption.isEmpty){
                  AppUtils.showInSnackBar(_scaffoldKey, AppMessage.kError_QuestionSelecteError);
              } else {
                  String arrCorrectAnswer =  this.currentAssessmentTask.assessmentTaskCorrectResponseText;
                  String result = 'fail';
                  String answer = '';
                  if (arrSelectedOption.length > 0){
                      answer = arrSelectedOption[0];

                      if(answer.toLowerCase() == arrCorrectAnswer.toLowerCase()){
                        result = 'pass';
                      }
                  }
                  setState(() {
                      this.currentAssessmentTask.result = result;
                      this.currentAssessmentTask.assessmentTaskAnswerIdResponseId = answer;
                      this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
                  });
              }
          break;
          case QuestionType.question_intgerAnswer:
              if(arrSelectedOption == null || arrSelectedOption.isEmpty){
                  AppUtils.showInSnackBar(_scaffoldKey, AppMessage.kError_QuestionSelecteError);
              } else {
                  String arrCorrectAnswer =  this.currentAssessmentTask.assessmentTaskCorrectResponseText;
                  String result = 'fail';
                  String answer = '';
                  if (arrSelectedOption.length > 0){
                      answer = arrSelectedOption[0];

                      if(answer.toLowerCase() == arrCorrectAnswer.toLowerCase()){
                        result = 'pass';
                      }
                  }
                  setState(() {
                      this.currentAssessmentTask.result = result;
                      this.currentAssessmentTask.assessmentTaskAnswerIdResponseId = answer;
                      this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
                  });
              }
          break;

        default:
      }
    }

    
    
  }

  /// ItemChnage method is array
  /// use to store use selected option as per type
  /// in single, multiple and bool task if option exsits than remove else add.
  ///  its take index as int parameter
  void itemChange(int index){
    QuestionOptions questionOptione = this.currentAssessmentTask.responses[index];
    setState(() {
      //inputs[index] = val;
      if(this.currentAssessmentTask.assessmentTaskType == QuestionType.question_singleAnswer || this.currentAssessmentTask.assessmentTaskType == QuestionType.question_boolAnswer){
        arrSelectedOption = [questionOptione.id];
      } else if(this.currentAssessmentTask.assessmentTaskType == QuestionType.question_multipleAnswer){
        if(arrSelectedOption.contains(questionOptione.id)){
          arrSelectedOption.remove(questionOptione.id);
        }else {
          arrSelectedOption.add(questionOptione.id);
        }
          
      } else {

      }
      
    });
  }

  /// questionOptionAnswer return widget for single, multiple and bool selection type.
  /// it show lisview with option with single and multiple selection
  /// check button for submit resut and next button for go to next task

  Widget questionOptionAnswer(){

    bool isSubmitAnswer = this.currentAssessmentTask.result != null?true:false;
    return Expanded(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    Text(
                      'Question ${this.currentTaskIndex + 1}',
                        style: TextStyle(
                          color: ThemeColor.theme_blue,
                          fontFamily: ThemeFont.font_pourceSanPro,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600
                        ),
                        textAlign: TextAlign.right,
                    ),
                    Text(
                      '${this.currentTaskIndex + 1}/${this.totalTask}',
                        style: TextStyle(
                          color: ThemeColor.theme_dark,
                          fontFamily: ThemeFont.font_pourceSanPro,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600
                        ),
                        textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Container(
                  
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                            this.currentAssessmentTask.prompt!=null?this.currentAssessmentTask.prompt:'',
                            style: TextStyle(
                              color: ThemeColor.theme_dark,
                              fontFamily: ThemeFont.font_pourceSanPro,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600
                            ),
                            textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                            'Answer',
                              style: TextStyle(
                                color: ThemeColor.theme_blue,
                                fontFamily: ThemeFont.font_pourceSanPro,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ), 
                          
                          SizedBox(
                            height: 10,
                          ),
                        ]),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemExtent: 50,
                                itemCount: this.currentAssessmentTask.responses.length,
                                itemBuilder: (BuildContext context, i){
                                  return buildQuestionTiles(context, i);
                                  //return Text('Hello');
                                },
                              )
                          ],
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                              SizedBox(
                                height: 40,
                                child: Container(
                                ),
                              ),
                              Container(
                                height: 50,
                                margin: const EdgeInsets.symmetric(horizontal: 100),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  color: ThemeColor.theme_blue,
                                ),
                                child: FlatButton(
                                  onPressed: () => isSubmitAnswer?clickForNext():checkForResult(),
                                  child: Center(
                                    child: Text(
                                        isSubmitAnswer?AppConstant.kTitle_Next:AppConstant.kTitle_Check,
                                        style: TextStyle(
                                            fontFamily: ThemeFont.font_pourceSanPro,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0),
                                      ),
                                  ),
                                ),
                              ),
                          ]
                        )
                      )
                    ],
                  ),
                  
                ),
              )
          ],
        ),
      ),
    );
    
  }
  /// buildQuestionTiles return tile for listview
  /// Tile have single ticke, and check anc uncheck icon
  Widget buildQuestionTiles(BuildContext context, index){
    QuestionOptions questionOptione = this.currentAssessmentTask.responses[index];

      bool isSubmitAnswer = this.currentAssessmentTask.result != null?true:false;
      if(isSubmitAnswer == false){

          Color select_color = ThemeColor.theme_dark;
          Widget selected_icon = SizedBox(width: 0,height: 0,);
          if(arrSelectedOption.contains(questionOptione.id)){
            select_color = ThemeColor.theme_blue;
            if(this.currentAssessmentTask.assessmentTaskType == QuestionType.question_singleAnswer || this.currentAssessmentTask.assessmentTaskType == QuestionType.question_boolAnswer){
              selected_icon = Container(
                  padding: EdgeInsets.only(right: 10),
                  width: 35,
                  height: 35,
                  child: Image.asset(ThemeImage.image_Bluetick),
                );
             
            } else {
              selected_icon = Container(
                  padding: EdgeInsets.only(right: 10),
                  width: 35,
                  height: 35,
                  child: Image.asset(ThemeImage.image_check),
                );
              
            }
              
              
          } else {
              select_color = ThemeColor.theme_dark;
              if(this.currentAssessmentTask.assessmentTaskType == QuestionType.question_singleAnswer || this.currentAssessmentTask.assessmentTaskType == QuestionType.question_boolAnswer){
                selected_icon = SizedBox(width: 0,height: 0,);
            } else {
              selected_icon = Container(
                  padding: EdgeInsets.only(right: 10),
                  width: 35,
                  height: 35,
                  child: Image.asset(ThemeImage.image_uncheck),
                );
              
            }
          }

          return Container(
          
          child:ListTile(
            title: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: ThemeColor.theme_borderline_gray
                    )
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                            questionOptione.text,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: ThemeFont.font_pourceSanPro,
                                color: select_color,
                                fontWeight: FontWeight.w600,
                                fontSize: 20.0),
                      ),
                    )
                    ,
                    selected_icon,
                  ],
                ),
              ),
            onTap: (){
              itemChange(index);
            },
            //controlAffinity: ListTileControlAffinity.trailing,
            //onChanged:(bool val){ItemChange(val, index);}
          )
        );
      } else{
          bool isSelectedAnswer = false;
          bool isCorrectAnswer = false;
          Color select_color = ThemeColor.theme_dark;
          Widget selected_icon = SizedBox(width: 0,height: 0,);
          if(this.currentAssessmentTask.assessmentTaskAnswerIdResponseId.split(',').contains(questionOptione.id)){
            isSelectedAnswer = true;
          }

          if(this.currentAssessmentTask.assessmentTaskCorrectResponseId.split(',').contains(questionOptione.id)){
            isCorrectAnswer = true;
          }

          if(isSelectedAnswer == true){
            if(isCorrectAnswer == true){
                select_color = ThemeColor.ans_green;
                selected_icon = Container(
                  padding: EdgeInsets.only(right: 10),
                  width: 35,
                  height: 35,
                  child: Image.asset(ThemeImage.image_yes),
                ); 
            } else {
              select_color = ThemeColor.ans_Red;
              selected_icon = Container(
                  padding: EdgeInsets.only(right: 10),
                  width: 35,
                  height: 35,
                  child: Image.asset(ThemeImage.image_no),
                );
            }
          }
          return Container(
            decoration: BoxDecoration(
              
            ),
            child:ListTile(
              title:Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: ThemeColor.theme_borderline_gray
                    )
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                    questionOptione.text,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontFamily: ThemeFont.font_pourceSanPro,
                        color: select_color,
                        fontWeight: FontWeight.w600,
                        fontSize: 20.0)
                    ),
                    )
                    ,
                    selected_icon,
                  ],
                ),
              ),

              //controlAffinity: ListTileControlAffinity.trailing,
              //onChanged:(bool val){ItemChange(val, index);}
            )
        );
      }
  }

  /// questionOptionAnswer return widget for single, multiple and bool selection type.
  /// it show lisview with option with single and multiple selection
  /// check button for submit resut and next button for go to next task

  Widget questionTextInputAnswer(){

    bool isSubmitAnswer = this.currentAssessmentTask.result != null?true:false;

    Color select_color = ThemeColor.theme_blue;
    Widget selected_icon = SizedBox(width: 0,height: 0,);
    bool isEnable = true;
    if(isSubmitAnswer == true){
        isEnable = false;
        if(this.currentAssessmentTask.result == 'pass'){
          select_color = ThemeColor.ans_green;
          selected_icon = Container(
            padding: EdgeInsets.only(right: 10),
            width: 35,
            height: 35,
            child: Image.asset(ThemeImage.image_yes),
          );
        } else {
          select_color = ThemeColor.ans_Red;
          selected_icon = Container(
            padding: EdgeInsets.only(right: 10),
            width: 35,
            height: 35,
            child: Image.asset(ThemeImage.image_no),
          );
        }

    }
    
    return Expanded(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    Text(
                      'Question ${this.currentTaskIndex + 1}',
                        style: TextStyle(
                          color: ThemeColor.theme_blue,
                          fontFamily: ThemeFont.font_pourceSanPro,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600
                        ),
                        textAlign: TextAlign.right,
                    ),
                    Text(
                      '${this.currentTaskIndex + 1}/${this.totalTask}',
                        style: TextStyle(
                          color: ThemeColor.theme_dark,
                          fontFamily: ThemeFont.font_pourceSanPro,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600
                        ),
                        textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Container(
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                            this.currentAssessmentTask.prompt!=null?this.currentAssessmentTask.prompt:'',
                            style: TextStyle(
                              color: ThemeColor.theme_dark,
                              fontFamily: ThemeFont.font_pourceSanPro,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600
                            ),
                            textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                            'Answer',
                              style: TextStyle(
                                color: ThemeColor.theme_blue,
                                fontFamily: ThemeFont.font_pourceSanPro,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ), 
                          
                          SizedBox(
                            height: 20,
                          ),
                        ]),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: TextField(
                                          controller: txtAnswer,
                                          enabled: isEnable,
                                          onChanged: (value){
                                            arrSelectedOption = [value.trim()];
                                          },
                                          onSubmitted: (value){
                                            arrSelectedOption = [value.trim()];
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                          },
                                          autofocus: true,
                                          keyboardType: this.currentAssessmentTask.assessmentTaskType == QuestionType.question_textAnswer?TextInputType.text:TextInputType.number,
                                          textInputAction: TextInputAction.done,
                                          autocorrect: false,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: select_color,
                                            fontFamily: ThemeFont.font_pourceSanPro,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600
                                          ),
                                          cursorColor: ThemeColor.theme_blue,
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: ThemeColor.theme_dark
                                              )
                                            ),
                                            hintText: "Type Answer",
                                            hintStyle: TextStyle(
                                              fontFamily: ThemeFont.font_pourceSanPro,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w600,
                                              color: ThemeColor.theme_borderline_gray
                                            ),
                                            
                                          ),
                                        ),
                                      )
                                  ),
                                  selected_icon
                                ],
                              ),
                            )
                              
                          ],
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                              SizedBox(
                                height: 40,
                                child: Container(
                                ),
                              ),
                              Container(
                                height: 50,
                                margin: const EdgeInsets.symmetric(horizontal: 100),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  color: ThemeColor.theme_blue,
                                ),
                                child: FlatButton(
                                  onPressed: () => isSubmitAnswer?clickForNext():checkForResult(),
                                  child: Center(
                                    child: Text(
                                        isSubmitAnswer?AppConstant.kTitle_Next:AppConstant.kTitle_Check,
                                        style: TextStyle(
                                            fontFamily: ThemeFont.font_pourceSanPro,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0),
                                      ),
                                  ),
                                ),
                              ),
                          ]
                        )
                      )
                    ],
                  ),
                  
                ),
              )
          ],
        ),
      ),
    );
    
  }
}