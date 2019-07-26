import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:hea/Model/AssessmentTasks.dart';
import 'package:hea/Model/AssessmentMetaData.dart';
import 'package:hea/Utils/AppUtils.dart';
import 'package:hea/Model/Assessment.dart';
import 'package:hea/Utils/DbManager.dart';
class ResultScreen extends StatefulWidget {
  ResultScreen({Key key,@required this.resMetadata,@required this.resAssessmentTask,@required this.resAssessment}):super(key:key);
  AssessmentMetaData resMetadata;
  List<AssessmentTasks> resAssessmentTask;
  Assessment resAssessment;
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  static final GlobalKey<ScaffoldState> _scaffoldKeyStartAssess = new GlobalKey<ScaffoldState>();  
    TextEditingController txtComment = TextEditingController();
    String candidateName = '';
    String comment = '';
    String assessmentResult = '';
    List<AssessmentTasks> arrAssessmentTask;
    AssessmentMetaData assessmentMetaData;
    Assessment assessment;
    bool _isEndAssessmentTapped = false;
    bool _isLoading = false;
    
    bool isMarkCalaculating = true;
    int obtainMark = 0;
    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.resAssessment != null){
      this.assessment = widget.resAssessment;
    }
    if(widget.resMetadata != null){
      this.assessmentMetaData = widget.resMetadata;
      candidateName = this.assessmentMetaData.candidateName != null? this.assessmentMetaData.candidateName : '';
    }
    if(widget.resAssessmentTask != null){
        this.arrAssessmentTask = widget.resAssessmentTask;
    }

    calcualteMark();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    txtComment.dispose();
    super.dispose();
  }

  calcualteMark() async
  {
    if(this.arrAssessmentTask.length > 0){
        
       await this.arrAssessmentTask.forEach((task) async{
            if(task.result == 'pass'){
                if(task.score != '' && task.score != null){
                  obtainMark = obtainMark + int.parse(task.score);
                }
                
            } else {
              assessmentResult = 'fail';
            } 
        });
        if(this.assessmentMetaData.assessmentPassmark != 'all'){
          if(obtainMark > int.parse(this.assessmentMetaData.assessmentPassmark)){
            assessmentResult = 'pass';
          } 
        } 
        
        setState(() {
          isMarkCalaculating = false;
      });

    } else {
      setState(() {
          isMarkCalaculating = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyStartAssess,
      appBar: AppBar(
        leading:Container(
          padding: EdgeInsets.only(right: 10),
          width: 35,
          height: 35,
          child: IconButton(
            icon: Image.asset(ThemeImage.image_back),
            onPressed: () async {
              try {
              } catch (e){
                AppUtils.onPrintLog('back res >>> ${e.toString()}');
              }
              AppUtils.onPrintLog("pop  >> 8");
              Navigator.pop(context);
              //Navigator.popUntil(context, ModalRoute.withName(AppRoute.routeHomeScreen));
            }  
        )
        ), 
        title: FittedBox(
          child: Text(
            this.assessmentMetaData != null && this.assessmentMetaData.assessmentName != null?this.assessmentMetaData.assessmentName:AppConstant.kTitle_AssessmentHeader,
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
        child: isMarkCalaculating?Center(
          child: CircularProgressIndicator(),
        ) : Container(
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
                  getTaskResultList()
                ],
              ),
      ),
      ),
      bottomNavigationBar:SafeArea(
        child:isMarkCalaculating? SizedBox():Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.red,
          boxShadow: [BoxShadow(
            color: Colors.grey,
            blurRadius: 5.0,
          ),]
        ),
        child:Container(
            //height: 60,
            decoration: BoxDecoration(
              color: ThemeColor.theme_blue
            ),
            child: FlatButton(
              onPressed: () => _isEndAssessmentTapped?null:_endAssessment(),
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
          )
        )
      )
    );
  }
  Widget getTaskResultList(){
    return Expanded(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Container(
                child: ListView.builder(
                shrinkWrap: true,
                itemExtent: 50,
                //physics: NeverScrollableScrollPhysics(),
                itemCount: this.arrAssessmentTask.length,
                itemBuilder: (BuildContext context, i){
                  return buildQuestionTiles(context, i);
                  //return Text('Hello');
                },
              ),
              ),
            ),
            Container(
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                  ),]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Flexible(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: ThemeColor.theme_dark
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Center(
                          child: TextField(
                          controller: txtComment,
                          onChanged: (value){
                            comment = value.trim();
                          },
                          onSubmitted: (value){
                            comment = value.trim();
                            FocusScope.of(context).requestFocus(new FocusNode());
                          },
                          autofocus: false,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: ThemeColor.theme_dark,
                            fontFamily: ThemeFont.font_pourceSanPro,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600
                          ),
                          cursorColor: ThemeColor.theme_dark,
                          decoration: InputDecoration.collapsed(
                              hintText: "Assessor's Comments...",
                              hintStyle: TextStyle(
                              fontFamily: ThemeFont.font_pourceSanPro,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                              color: ThemeColor.theme_borderline_gray
                            ),
                          ),
                        ),
                        ),
                      )
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 50,
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            color: this.assessmentResult == 'fail'?ThemeColor.ans_Red:ThemeColor.theme_blue
                          ),
                          child: FlatButton(
                            onPressed: () => _resultFail(),
                            child: Center(
                              child: Text(
                                  AppConstant.kTitle_Fail,
                                  style: TextStyle(
                                      fontFamily: ThemeFont.font_pourceSanPro,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            color: ThemeColor.theme_blue
                          ),
                          child: FlatButton(
                            onPressed: () => _resultPending(),
                            child: Center(
                              child: Text(
                                  AppConstant.kTitle_Pending,
                                  style: TextStyle(
                                      fontFamily: ThemeFont.font_pourceSanPro,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            color: this.assessmentResult == 'pass'?ThemeColor.ans_green:ThemeColor.theme_blue
                          ),
                          child: FlatButton(
                            onPressed: () => _resultPass(),
                            child: Center(
                              child: Text(
                                  AppConstant.kTitle_Pass,
                                  style: TextStyle(
                                      fontFamily: ThemeFont.font_pourceSanPro,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                            ),
                          ),
                        )
                      ],
                      
                    ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                )
              )

          ],
        )
      ),
    );
    
  }
  Widget buildQuestionTiles(BuildContext context, index){
    AssessmentTasks task = this.arrAssessmentTask[index];
     bool isSelectedAnswer = false;
          bool isPass = false;
          Color select_color = ThemeColor.theme_dark;
          Widget selected_icon = SizedBox(width: 0,height: 0,);

          if(task.result == 'pass'){
            isPass = true;
          }

          select_color = ThemeColor.theme_blue;

          if(isPass == true){
                selected_icon = Container(
                  padding: EdgeInsets.only(right: 10),
                  width: 35,
                  height: 35,
                  child: Image.asset(ThemeImage.image_yes),
                ); 
            } else {
              selected_icon = Container(
                  padding: EdgeInsets.only(right: 10),
                  width: 35,
                  height: 35,
                  child: Image.asset(ThemeImage.image_no),
                );
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
                    'Task ${index + 1}',
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

  /// End Assessment will complete assessment
  /// change its status in database
  void _endAssessment() async {
    setState((){
      _isLoading = true;
      _isEndAssessmentTapped = true;
    });

    this.assessment.IS_END = 1;
    await DBManager.db.updateAssessmetns(this.assessment);
    this.assessmentMetaData.assessmentPassmark = '$obtainMark';
    this.assessmentMetaData.assessmentResult = this.assessmentResult;
    this.assessmentMetaData.assessmentComment = this.comment;
    await DBManager.db.updateAssessmetnsMetaData(this.assessmentMetaData);

    arrAssessmentTask.forEach((task)async {
        await DBManager.db.updateAssessmetnsTask(task);
    });

    AppUtils.onPrintLog("pop  >> 9");
    Navigator.pop(context,this.assessment);
    //Navigator.popUntil(context, ModalRoute.withName(AppRoute.routeHomeScreen));
  }

  void _resultFail(){
  }
  void _resultPass(){
  }
  void _resultPending(){
  }
}