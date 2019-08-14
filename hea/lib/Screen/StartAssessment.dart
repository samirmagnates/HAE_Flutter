import 'dart:async';
import 'dart:io';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Model/AssessmentTasks.dart';
import '../Model/AssessmentMetaData.dart';
import '../Model/QuestionOptions.dart';
import '../Utils/AppUtils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'AudioPlayer.dart';
import 'VideoPlayer.dart';
import '../Screen/YoutubeVideoPlayer.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../Screen/AudioRecorder.dart';
import '../Screen/ResultScreen.dart';
import '../Model/Assessment.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:hea/Utils/DbManager.dart';


class StartAssessment extends StatefulWidget {
  @override

  StartAssessment({Key key,@required this.resMetadata,@required this.resAssessmentTask,@required this.resAssessment}) : super(key: key);

  //var responsData;
  AssessmentMetaData resMetadata;
  List<AssessmentTasks> resAssessmentTask;
  Assessment resAssessment;

  _StartAssessmentState createState() => _StartAssessmentState();
}

class _StartAssessmentState extends State<StartAssessment> {

  static final GlobalKey<ScaffoldState> _scaffoldKeyStartAssess = new GlobalKey<ScaffoldState>();  
  TextEditingController txtAnswer = TextEditingController();
  List<AssessmentTasks> arrAssessmentTask;
  AssessmentMetaData assessmentMetaData;
  List<String> arrSelectedOption = List<String>();
  List<QuestionOptions> arrTaskOption = List<QuestionOptions>();
  AssessmentTasks currentAssessmentTask;
  Assessment assessment;
  int totalTask;
  int currentTaskIndex;
  String noDataMessage;
  String candidateName = '';
  bool _isEndAssessmentTapped = false;
  bool _isLoading = false;

  AudioRecorder audiorecorder;

  // for camera redod

  //bool _isLoading = false;
  bool _isMaxDuration = false;
  //String currentAssessmentUuid;
  ChewieController _chewieController;
  VideoPlayerController _videoPlayerController;
  final _flutterVideoCompress = FlutterVideoCompress();
  Subscription _subscription;

  final _loadingStreamController = StreamController<bool>.broadcast();
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
        currentTaskIndex = 0;
        this.arrAssessmentTask = widget.resAssessmentTask;
        totalTask = this.arrAssessmentTask.length;
        if(this.totalTask > 0){
            setState(() {
              this.currentAssessmentTask = this.arrAssessmentTask[currentTaskIndex];
              if(this.currentAssessmentTask.responses != null) {
                AppUtils.onPrintLog('this.currentAssessmentTask.responses >> ${this.currentAssessmentTask.responses}');
                var jsonString = jsonDecode(this.currentAssessmentTask.responses);
                AppUtils.onPrintLog('arr >> $jsonString');
                List arr = jsonDecode(jsonString);
                 arr.forEach((v) {
                   this.arrTaskOption.add(new QuestionOptions.fromJSON(v));
                 });
              }
            });
        } else {
            setState(() {
              noDataMessage = 'No data found';
            });
        }
    }
    /*if(widget.responsData != null){
      
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
              if(this.currentAssessmentTask.responses != null) {
                List arr = json.decode(this.currentAssessmentTask.responses);
                arr.forEach((v) {
                  this.arrTaskOption.add(new QuestionOptions.fromJSON(v));
                });
              }
            });
        } else {
            setState(() {
              noDataMessage = 'No data found';
            });
        }
      }
    }*/
  }

  @override
   void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    txtAnswer.dispose();
    /*if(_videoPlayerController != null){
      _videoPlayerController.dispose();
      _videoPlayerController = null;
    }

    if(_chewieController != null){
      _chewieController.dispose();
      _chewieController = null;
    }*/
    
    
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
                final String  assessorPath =  await AppUtils.getAssessorPath();
                await AppUtils.deleteLocalFolder('$assessorPath/${this.assessment.ASSESSMENT_UUID}');
              } catch (e){
                AppUtils.onPrintLog('back res >>> ${e.toString()}');
              }
              AppUtils.onPrintLog("pop  >> 10");
              Navigator.pop(context);//Navigator.of(context).pop(),
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
        child: Container(
          child: Stack(
            children: <Widget>[
              Column(
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
              //_isLoading?_showCircularProgress() : SizedBox(height: 0.0, width: 0.0,),
            ],
          )
      ),
      ),
      bottomNavigationBar:this.currentAssessmentTask != null?SafeArea(
        child:Container(
        height: 60,
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
      ):SizedBox(
        width: 0.0,
        height: 0.0,
      ),
    );
  }

  /// End Assessment will complete assessment
  /// change its status in database
  void _endAssessment(){
    setState((){
              _isLoading = true;
              _isEndAssessmentTapped = true;
       });
       AppUtils.onPrintLog("pop  >> 11");
    Navigator.of(context).pop();
  }

  Widget _showCircularProgress(){
    return Center(child: CircularProgressIndicator());
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
        case QuestionType.question_imageViewAnswer:
          return questionImageViewAnswer();
        break;
        case QuestionType.question_audioPlayAnswer:
          return questionAudioPlayerAnswer();
        break; 
        case QuestionType.question_videoPlayAnswer:
          return questionVideoPlayerAnswer();
        break;
        case QuestionType.question_imageCaptureAnswer:
          return questionCaptureImageViewAnswer();
        break;
        case QuestionType.question_audioRecordAnswer:
          return questionRecordAudioViewAnswer();
        break;
        case QuestionType.question_videoRecordAnswer:
          return questionRecordVideoViewAnswer();
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
        if(this.currentTaskIndex < this.arrAssessmentTask.length){
          setState(() {
            this.arrSelectedOption.clear();
            this.currentAssessmentTask = this.arrAssessmentTask[this.currentTaskIndex];
            this.arrTaskOption.clear();
            if(this.currentAssessmentTask.responses != null) {
                var jsonString = jsonDecode(this.currentAssessmentTask.responses);
                if (jsonString != null){
                  List arr = jsonDecode(jsonString);
                  if(arr != null){
                    arr.forEach((v) {
                    this.arrTaskOption.add(new QuestionOptions.fromJSON(v));
                    });
                  }
                 
                }
                
              }
          });
          
        } else {
          goToResultScreen();
        }
  }
  
  goToResultScreen() async {
    audiorecorder = null;
    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResultScreen(resMetadata: this.assessmentMetaData,resAssessmentTask: this.arrAssessmentTask,resAssessment: this.assessment)));
   AppUtils.onPrintLog("pop  >> 12");
    Navigator.pop(context,result);
  }


  /// Check for result use for sumbit result
  /// if user not select any option than show error message
  /// else check user is pass or fail as per task type
  /// set result and selected answer propery to current task
  /// show reslul with correct or wornge answer
  /// hide check butten and show next button for next task
  void checkForResult(){

    if(this.currentAssessmentTask.result == null || this.currentAssessmentTask.result.isEmpty){
        switch (this.currentAssessmentTask.assessmentTaskType) {
        case QuestionType.question_singleAnswer:
              if(arrSelectedOption == null || arrSelectedOption.isEmpty){
                  AppUtils.showInSnackBar(_scaffoldKeyStartAssess, AppMessage.kError_QuestionSelecteError);
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
                  AppUtils.showInSnackBar(_scaffoldKeyStartAssess, AppMessage.kError_QuestionSelecteError);
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
                  AppUtils.showInSnackBar(_scaffoldKeyStartAssess, AppMessage.kError_QuestionSelecteError);
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
              if(arrSelectedOption == null || arrSelectedOption.isEmpty || txtAnswer.text.isEmpty){
                  AppUtils.showInSnackBar(_scaffoldKeyStartAssess, AppMessage.kError_QuestionInputError);
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
                      this.currentAssessmentTask.assessmentTaskAnswerResponseText = answer;
                      this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
                  });
              }
          break;
          case QuestionType.question_intgerAnswer:
              if(arrSelectedOption == null || arrSelectedOption.isEmpty || txtAnswer.text.isEmpty){
                  AppUtils.showInSnackBar(_scaffoldKeyStartAssess, AppMessage.kError_QuestionInputError);
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
                      this.currentAssessmentTask.assessmentTaskAnswerResponseText = answer;
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
    QuestionOptions questionOptione = this.arrTaskOption[index];
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

  /// Pass button is use when task is senario base like image,audio,video
  /// As per candidate answer assessor diside pass or fail
  void clickPassFail(bool isPass) async{
      
      bool isGoAhed = true;
      String result = isPass?'pass':'fail';
      if(this.currentAssessmentTask.result == null || this.currentAssessmentTask.result.isEmpty){
        AssessmentTasks task = await DBManager.db.getAssessementsTask(this.currentAssessmentTask.assessmentTaskUuid,this.currentAssessmentTask.assessmentUuid, this.currentAssessmentTask.assessorUuid);
        switch (this.currentAssessmentTask.assessmentTaskType) {
        case QuestionType.question_imageViewAnswer:
              setState(() {
                  this.currentAssessmentTask.result = result;
                  this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
              });
              
          break;
          case QuestionType.question_audioPlayAnswer:
              
              setState(() {
                  this.currentAssessmentTask.result = result;
                  this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
              });
          break;
          case QuestionType.question_videoPlayAnswer:
              setState(() {
                  this.currentAssessmentTask.result = result;
                  this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
              });
          break;
          case QuestionType.question_imageCaptureAnswer:
                if(this.currentAssessmentTask.assessmentTaskLocalFile == null || this.currentAssessmentTask.assessmentTaskLocalFile.isEmpty){
                    isGoAhed = false;
                    AppUtils.showInSnackBar(_scaffoldKeyStartAssess, AppMessage.kError_captureImage);
                } else {
                  setState(() {
                    this.currentAssessmentTask.result = result;
                    this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
                });
              }
                
                
          break;
          case QuestionType.question_audioRecordAnswer:
              
              if(audiorecorder.isRecorded != true ){
                isGoAhed = false;
                AppUtils.showInSnackBar(_scaffoldKeyStartAssess, AppMessage.kError_recoredAudio);
              } else {
                setState(() {
                  this.currentAssessmentTask.result = result;
                  this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
                });
              }
              /*if(task.assessmentTaskLocalFile == null || task.assessmentTaskLocalFile.isEmpty){
                
              } else {
                
              }*/
              
              
          break;
          case QuestionType.question_videoRecordAnswer:
              if(_videoPlayerController != null){
                //_videoPlayerController.dispose();
                //_videoPlayerController = null;
              }

              if(_chewieController != null){
                //_chewieController.dispose();
                //_chewieController = null;
              }
              if(this.currentAssessmentTask.assessmentTaskLocalFile == null || this.currentAssessmentTask.assessmentTaskLocalFile.isEmpty){
                    isGoAhed = false;
                    AppUtils.showInSnackBar(_scaffoldKeyStartAssess, AppMessage.kError_recoredVideo);
                } else {
                  setState(() {
                  this.currentAssessmentTask.result = result;
                  this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
                });
              }
              
              
          break;

        default:
      }
    }
    if(isGoAhed == true){
      this.currentTaskIndex++;
      if(this.currentAssessmentTask.assessmentTaskType == QuestionType.question_textAnswer || this.currentAssessmentTask.assessmentTaskType == QuestionType.question_intgerAnswer){
          this.txtAnswer.text = '';
      }
      if(this.currentTaskIndex < this.arrAssessmentTask.length){
        setState(() {
          this.arrSelectedOption.clear();
          this.currentAssessmentTask = this.arrAssessmentTask[this.currentTaskIndex];
        });
        
      } else {
        //Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResultScreen(resMetadata: this.assessmentMetaData,resAssessmentTask: this.arrAssessmentTask,resCandidate: this.candidate)));
        goToResultScreen();
      }
    }
      
    }

  /// questionOptionAnswer return widget for single, multiple and bool selection type.
  /// it show lisview with option with single and multiple selection
  /// check button for submit resut and next button for go to next task

  Widget questionOptionAnswer(){

    bool isSubmitAnswer = this.currentAssessmentTask.result != null && this.currentAssessmentTask.result.isNotEmpty?true:false;
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
                                itemCount: this.arrTaskOption.length,
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
                                height: 30,
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
                              SizedBox(
                                height: 20,
                                child: Container(
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
    QuestionOptions questionOptione = this.arrTaskOption[index];

      bool isSubmitAnswer = this.currentAssessmentTask.result != null && this.currentAssessmentTask.result.isNotEmpty?true:false;
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

    bool isSubmitAnswer = this.currentAssessmentTask.result != null && this.currentAssessmentTask.result.isNotEmpty?true:false;

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
                                height: 30,
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
                                )
                              ),
                              SizedBox(
                                height: 20,
                                child: Container(
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

  /// Question ImageView return widget show image from url.
  /// pass and fail button for submit resut and  go to next task

  Widget questionImageViewAnswer(){

    bool isSubmitAnswer = this.currentAssessmentTask.result != null && this.currentAssessmentTask.result.isNotEmpty?true:false;
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
                      'Scenario',
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
                            height: 20,
                          ),
                        ]),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: 100
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: this.currentAssessmentTask.assessmentTaskAssetUrl,
                                  placeholder: (context,url) => Center(
                                    child: _showCircularProgress()
                                  ),
                                )
                              )
                            )
                          ],
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                              SizedBox(
                                height: 30,
                                child: Container(
                                ),
                              ),
                              Container(
                                height: 50,
                                child: buttonPassFail()
                              ),
                              SizedBox(
                                height: 20,
                                child: Container(
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

  /// Question ImageView return widget show image from url.
  /// pass and fail button for submit resut and  go to next task

  Widget questionAudioPlayerAnswer(){

    bool isSubmitAnswer = this.currentAssessmentTask.result != null && this.currentAssessmentTask.result.isNotEmpty?true:false;

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
                      'Scenario',
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
                            height: 50,
                          ),
                        ]),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: 100
                                ),
                                child: CustomAudioPlayer(url:this.currentAssessmentTask.assessmentTaskAssetUrl,assessmentUuid:this.assessment.ASSESSMENT_UUID),
                              )
                            )
                          ],
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                              SizedBox(
                                height: 30,
                                child: Container(
                                ),
                              ),
                              Container(
                                height: 50,
                                child: buttonPassFail()
                              ),
                              SizedBox(
                                height: 20,
                                child: Container(
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

  /// Question ImageView return widget show image from url.
  /// pass and fail button for submit resut and  go to next task

  Widget questionVideoPlayerAnswer(){

    bool isSubmitAnswer = this.currentAssessmentTask.result != null && this.currentAssessmentTask.result.isNotEmpty?true:false;

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
    bool isYoutubeURL = false;
    if(this.currentAssessmentTask.assessmentTaskAssetUrl.contains('https://youtu.be/')){
        isYoutubeURL = true;
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
                      'Scenario',
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
                            height: 50,
                          ),
                        ]),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            AspectRatio(
                            aspectRatio: 1.5 / 1,
                            child: new Container(
                              decoration: new BoxDecoration(
                                shape: BoxShape.rectangle,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: 100
                                ),
                                child: isYoutubeURL?YoutubeVideoPlayer(url:this.currentAssessmentTask.assessmentTaskAssetUrl):customVideoPlayer(url:this.currentAssessmentTask.assessmentTaskAssetUrl,isLocal: false)
                                
                              )
                              ),
                            ),
                            
                          ],
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                              SizedBox(
                                height: 30,
                                child: Container(
                                ),
                              ),
                              Container(
                                height: 50,
                                child: buttonPassFail()
                              ),
                              SizedBox(
                                height: 20,
                                child: Container(
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

   Future<String> compressImage(File image) async {
      String docDirectory = await AppUtils.getDocumentPath();
      String taskFolder = await AppUtils.getAssessmentPath(this.assessment.ASSESSMENT_UUID);
    //if(this.currentAssessmentTask.assessmentTaskLocalFile.isNotEmpty){
      final file = new File('$docDirectory/$taskFolder/${this.currentAssessmentTask.assessmentTaskLocalFile}');
      if (await file.exists()){
          await file.delete();
          this.currentAssessmentTask.assessmentTaskLocalFile = '';
      }
    //}
    
    //await AppUtils.getCreateFolder(taskFolder);
    
    String fileExtesion = 'jpeg';
    if(this.currentAssessmentTask.assessmentTaskUploadFormat != null && this.currentAssessmentTask.assessmentTaskUploadFormat.isNotEmpty){
        List<String> arrExtention = this.currentAssessmentTask.assessmentTaskUploadFormat.split(',');
        fileExtesion = arrExtention.first;
    } 
    //final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    //final String filePath = '$taskFolder/${this.currentAssessmentTask.assessmentTaskUuid}_$currentTime.$fileExtesion';
    final String filePath = '$taskFolder/${this.currentAssessmentTask.assessmentTaskUuid}.$fileExtesion';
    var res2 = await image.copy('$docDirectory/$filePath');
    AppUtils.onPrintLog('res2 >> $res2');
    image.delete();

    /*//final file1 = new File('$docDirectory/$filePath');
    Im.Image image1 = Im.decodeImage(image.readAsBytesSync());
    Im.Image smallerImage = Im.copyResize(image1,width: 512,height: 512); // choose the size here, it will maintain aspect ratio
    var decodedImageFile = File('$docDirectory/$filePath');
    decodedImageFile.writeAsBytesSync(Im.encodeJpg(smallerImage, quality: 50));
    //decodedImageFile.writeAsBytes(Im.encodeJpg(smallerImage, quality: 50));*/
    return filePath;
    
  }

  

  /// Question ImageView return widget show image from url.
  /// pass and fail button for submit resut and  go to next task

  Widget questionCaptureImageViewAnswer(){

    bool isSubmitAnswer = this.currentAssessmentTask.result != null && this.currentAssessmentTask.result.isNotEmpty?true:false;

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
                      'Capture',
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
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  decoration: BoxDecoration(
                                  ),
                                  child: IconButton(
                                    icon: Image.asset(ThemeImage.image_camera),
                                    onPressed: () async {
                                      getPermision(Permission.camera);
                                      //CameraCapture();
                                      var picture = await ImagePicker.pickImage(
                                        source: ImageSource.camera,
                                        maxWidth: 512,
                                        maxHeight: 512
                                      );
                                      if(picture != null){
                                        setState((){
                                          _isLoading = true;
                                        });
                                        //var path = await compute(compressImage,picture);
                                        var path = await compressImage(picture);
                                        String filePath = path.toString();

                                        setState(() {
                                            _isLoading = false;
                                            this.currentAssessmentTask.assessmentTaskLocalFile = filePath;
                                            this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              this.currentAssessmentTask.assessmentTaskLocalFile.isEmpty?SizedBox(
                            width: 10,
                          ):Padding(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                            child: Container(
                              alignment: Alignment.topLeft,
                              decoration: BoxDecoration(
                              ),
                              child: IconButton(
                                icon: Image.asset(ThemeImage.image_edit),
                                onPressed: () async {
                                  String docDirectory = await AppUtils.getDocumentPath();
                                  String fileFullPath = '$docDirectory/${this.currentAssessmentTask.assessmentTaskLocalFile}';
                                  final File file =  File(fileFullPath);
                                  File croppedFile = await ImageCropper.cropImage(
                                    sourcePath: file.path,
                                    toolbarTitle: 'Cropper',
                                    toolbarColor: Colors.blue,
                                    toolbarWidgetColor: Colors.white, 
                                  );
                                  if(croppedFile != null){
                                    setState((){
                                      _isLoading = true;
                                    });
                                    //var path = await compute(compressImage,picture);
                                    var path = await compressImage(croppedFile);
                                    String filePath = path.toString();
                                    croppedFile.delete();
                                    setState(() {
                                        _isLoading = false;
                                        this.currentAssessmentTask.assessmentTaskLocalFile = filePath;
                                        this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),   
                            ],
                          ),
                          
                          
                        ]),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),

                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: 100
                                ),
                                child: this.currentAssessmentTask.assessmentTaskLocalFile.isEmpty?
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  height: 200,
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey
                                        ),
                                        
                                      ),
                                      Center(child: Text(
                                        'Photo',
                                        style: TextStyle(
                                            color: ThemeColor.theme_dark,
                                            fontFamily: ThemeFont.font_pourceSanPro,
                                            fontSize: 30.0,
                                            fontWeight: FontWeight.bold
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      _isLoading? Container(
                                                height: MediaQuery.of(context).size.height,
                                                width: MediaQuery.of(context).size.width,
                                                child: Center(
                                                  child: _showCircularProgress(),
                                                ),
                                              ) : SizedBox(height: 0.0, width: 0.0,),
                                    ],
                                  ),
                                ):
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  //height: 200,
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                        ),
                                      ),
                                      Center(
                                        child: FutureBuilder(
                                          future: AppUtils.getDocumentPath(),
                                          builder: (BuildContext context,AsyncSnapshot snapShot){
                                            String docDirectory = snapShot.data as String;
                                            if(snapShot.hasData){
                                              if(this.currentAssessmentTask.assessmentTaskLocalFile.isEmpty){
                                                return Container(
                                                height: MediaQuery.of(context).size.height,
                                                width: MediaQuery.of(context).size.width,
                                                child: Center(
                                                  child: _showCircularProgress(),
                                                ),
                                              );
                                              } else {
                                                  return Image.file(File('${docDirectory.toString()}/${this.currentAssessmentTask.assessmentTaskLocalFile}'));
                                              }
                                              
                                            } else {
                                              return Container(
                                                height: MediaQuery.of(context).size.height,
                                                width: MediaQuery.of(context).size.width,
                                                child: Center(
                                                  child: _showCircularProgress(),
                                                ),
                                              );
                                            }
                                          },
                                        )
                                        
                                      ),
                                      _isLoading?_showCircularProgress() : SizedBox(height: 0.0, width: 0.0,),
                                    ],
                                  ),
                                )
                              )
                            )
                          ],
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                              SizedBox(
                                height: 30,
                                child: Container(
                                ),
                              ),
                              Container(
                                height: 50,
                                //child: this.currentAssessmentTask.assessmentTaskLocalFile.isEmpty?SizedBox():buttonPassFail()
                                child: buttonPassFail()
                              ),
                              SizedBox(
                                height: 20,
                                child: Container(
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

  getPermision(String type) async {

      switch(type) { 
        case Permission.camera: { 
            await PermissionHandler().requestPermissions([PermissionGroup.camera]);
        } 
        break; 
        
        case Permission.microphone: { 
            //statements; 
            await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
        } 
        break; 
            
        default: { 
            //statements;  
        }
        break; 
      } 
      
  }

  /// Question ImageView return widget show image from url.
  /// pass and fail button for submit resut and  go to next task

     getAudioFilePath(AssessmentTasks task) async {
      String taskFolder = await AppUtils.getAssessmentPath(this.assessment.ASSESSMENT_UUID);
      String docDirectory = await AppUtils.getDocumentPath();
      //String pathFolder =  await AppUtils.getLocalPath(this.assessmentMetaData.assessmentUuid);

      if(this.currentAssessmentTask.assessmentTaskLocalFile.isNotEmpty){
          
        final file = new File('$docDirectory/$taskFolder/${this.currentAssessmentTask.assessmentTaskLocalFile}');
        if (await file.exists()){
            await file.delete();
            this.currentAssessmentTask.assessmentTaskLocalFile = '';
        }
      }

      String fileExtesion = 'mp3';
      if(task.assessmentTaskUploadFormat != null && task.assessmentTaskUploadFormat.isNotEmpty){
          List<String> arrExtention = task.assessmentTaskUploadFormat.split(',');
          fileExtesion = arrExtention.first;
      } 
      if(Platform.isIOS){
        fileExtesion = 'm4a'; 
      }
      //final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
      //final String filePath = '$taskFolder/${task.assessmentTaskUuid}_$currentTime.$fileExtesion';
      final String filePath = '$taskFolder/${task.assessmentTaskUuid}.$fileExtesion';

      /*final file = new File('$docDirectory/$filePath');
      if ( await file.exists()){
          await file.delete();
          this.currentAssessmentTask.assessmentTaskLocalFile = '';
      }*/
      
      AppUtils.onPrintLog('res2 >> $filePath');
      this.currentAssessmentTask.assessmentTaskLocalFile = filePath;
      this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
      
      return filePath;
  }
  Widget questionRecordAudioViewAnswer()  {

    return FutureBuilder(
      future: getAudioFilePath(this.currentAssessmentTask),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.hasData){
          String filePath = snapshot.data as String;

          audiorecorder = AudioRecorder(task:this.currentAssessmentTask,assessmentUuid:this.assessment.ASSESSMENT_UUID,filePath: filePath);
          getPermision(Permission.microphone);
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
                            'Record',
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
                              ]),
                            ),
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),

                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: 100
                                      ),
                                      child: this.currentAssessmentTask.assessmentTaskLocalFile.isEmpty?Container(
                                        height: MediaQuery.of(context).size.height,
                                        width: MediaQuery.of(context).size.width,
                                        child: Center(
                                          child: _showCircularProgress(),
                                        ),
                                      ):audiorecorder
                                    )
                                  )
                                ],
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                    SizedBox(
                                      height: 30,
                                      child: Container(
                                      ),
                                    ),
                                    Container(
                                      height: 50,
                                      child: buttonPassFail()
                                    ),
                                    SizedBox(
                                      height: 20,
                                      child: Container(
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
        } else {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: _showCircularProgress(),
            ),
          );
        }
      },
    );
  }

  
  /// Question ImageView return widget show image from url.
  /// pass and fail button for submit resut and  go to next task

  Widget questionRecordVideoViewAnswer(){

    bool isSubmitAnswer = this.currentAssessmentTask.result != null && this.currentAssessmentTask.result.isNotEmpty?true:false;
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
                      'Capture',
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
                        ]),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            //VideoPlayer1(assessmentTask: this.currentAssessmentTask,assessmentUuid: this.assessmentMetaData.assessmentUuid,),
                            getCameraRecorder()
                          ]
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                              SizedBox(
                                height: 30,
                                child: Container(
                                ),
                              ),
                              Container(
                                height: 50,
                                child: buttonPassFail()
                              ),
                              SizedBox(
                                height: 20,
                                child: Container(
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

  Widget questionRecordVideoViewAnswer1(){

    bool isSubmitAnswer = this.currentAssessmentTask.result != null && this.currentAssessmentTask.result.isNotEmpty?true:false;
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
                      'Capture',
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
                        ]),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Padding(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                            child: Container(
                              alignment: Alignment.topLeft,
                              decoration: BoxDecoration(
                              ),
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Image.asset(ThemeImage.image_camera),
                                    onPressed: () async {
                                      
                                      getPermision(Permission.camera);
                                      
                                      String docDirectory = await AppUtils.getDocumentPath();
                                      await ImagePicker.pickVideo(source: ImageSource.camera).then((File videoFile) async {

                                      setState(() {
                                        _isLoading = true;
                                      });
                                      if (videoFile != null && mounted) {
                                        String taskFolder = await AppUtils.getAssessmentPath(this.assessment.ASSESSMENT_UUID);
                                        if(this.currentAssessmentTask.assessmentTaskLocalFile.isNotEmpty){
                                          
                                          final file = new File('$docDirectory/$taskFolder/${this.currentAssessmentTask.assessmentTaskLocalFile}');
                                          if (await file.exists()){
                                              await file.delete();
                                              this.currentAssessmentTask.assessmentTaskLocalFile = '';
                                          }
                                        }
                                        
                                        
                                        //await AppUtils.getCreateFolder(taskFolder);
                                        //String pathFolder = await AppUtils.getLocalPath(this.assessmentMetaData.assessmentUuid);
                                        String fileExtesion = 'mp4';
                                        if(this.currentAssessmentTask.assessmentTaskUploadFormat != null && this.currentAssessmentTask.assessmentTaskUploadFormat.isNotEmpty){
                                            List<String> arrExtention = this.currentAssessmentTask.assessmentTaskUploadFormat.split(',');
                                            fileExtesion = arrExtention.first;
                                        } 
                                        //final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
                                        //final String filePath = '$taskFolder/${this.currentAssessmentTask.assessmentTaskUuid}_$currentTime.$fileExtesion';
                                        final String filePath = '$taskFolder/${this.currentAssessmentTask.assessmentTaskUuid}.$fileExtesion';

                                        String fileFullPath = '$docDirectory/$filePath'; 
                                        var res2 = await videoFile.copy(fileFullPath);
                                        AppUtils.onPrintLog('res2 >> $res2');
                                         var del = await videoFile.delete();
                                        AppUtils.onPrintLog('del >> $del');
                                        setState(() {
                                          this.currentAssessmentTask.assessmentTaskLocalFile = filePath;
                                          this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
                                           _isLoading = false;
                                        });
                                      }
                                    });
                                     /* var picture = await ImagePicker.pickVideo(
                                        source: ImageSource.camera,
                                      );*/
                                      
                                      },
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 15),
                                    child: Text(
                                      'Maximum 2 minitues of video recroding allow',
                                      style: TextStyle(
                                        color: ThemeColor.theme_dark,
                                        fontFamily: ThemeFont.font_pourceSanPro,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),

                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: 100

                                ),
                                child: this.currentAssessmentTask.assessmentTaskLocalFile.isEmpty?
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  height: 200,
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey
                                        ),
                                        
                                      ),
                                      Center(child: Text(
                                        'Video',
                                        style: TextStyle(
                                          color: ThemeColor.theme_dark,
                                          fontFamily: ThemeFont.font_pourceSanPro,
                                          fontSize: 30.0,
                                          fontWeight: FontWeight.bold
                                        ),
                                        textAlign: TextAlign.center,
                                      ),),
                                      _isLoading?_showCircularProgress():SizedBox()
                                    ],
                                  ),
                                ):
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  height: 300,
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                        ),
                                      ),
                                      Center(
                                        child: customVideoPlayer(url:this.currentAssessmentTask.assessmentTaskLocalFile,isLocal: true)
                                        
                                      )
                                    ],
                                  ),
                                )
                              )
                            )
                          ],
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                              SizedBox(
                                height: 30,
                                child: Container(
                                ),
                              ),
                              Container(
                                height: 50,
                                child: buttonPassFail()
                              ),
                              SizedBox(
                                height: 20,
                                child: Container(
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

  Widget buttonPassFail(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: ThemeColor.theme_blue
          ),
          child: FlatButton(
            onPressed: () => clickPassFail(false),
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
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: ThemeColor.theme_blue
          ),
          child: FlatButton(
            onPressed: () => clickPassFail(true),
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
      
    );
  }

// Get Camera redord view
Widget getCameraRecorder() {
    return Container(
        height: 300,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0),
              child: Container(
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Image.asset(ThemeImage.image_camera),
                      onPressed: () async {
                        
                        getPermision(Permission.camera);
                        
                        String docDirectory = await AppUtils.getDocumentPath();
                        await ImagePicker.pickVideo(source: ImageSource.camera).then((File videoFile) async {
                            if (videoFile != null && mounted) {
                            _isLoading = true;
                            _loadingStreamController.sink.add(true);
                            
                            String taskFolder = await AppUtils.getAssessmentPath(this.assessment.ASSESSMENT_UUID);
                            if(this.currentAssessmentTask.assessmentTaskLocalFile.isNotEmpty){
                              
                              final file = new File('$docDirectory/$taskFolder/${this.currentAssessmentTask.assessmentTaskLocalFile}');
                              if (await file.exists()){
                                  await file.delete();
                                  this.currentAssessmentTask.assessmentTaskLocalFile = '';
                              }
                            }
                            
                            //await AppUtils.getCreateFolder(taskFolder);
                            //String pathFolder = await AppUtils.getLocalPath(this.assessmentMetaData.assessmentUuid);
                            String fileExtesion = 'mp4';
                            if(this.currentAssessmentTask.assessmentTaskUploadFormat != null && this.currentAssessmentTask.assessmentTaskUploadFormat.isNotEmpty){
                                List<String> arrExtention = this.currentAssessmentTask.assessmentTaskUploadFormat.split(',');
                                fileExtesion = arrExtention.first;
                            } 
                            //final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
                            //final String filePath = '$taskFolder/${this.currentAssessmentTask.assessmentTaskUuid}_$currentTime.$fileExtesion';
                            final String filePath = '$taskFolder/${this.currentAssessmentTask.assessmentTaskUuid}.$fileExtesion';

                            String fileFullPath = '$docDirectory/$filePath'; 

                            //_loadingStreamCtrl.sink.add(true);
                            _isMaxDuration = await isMaxVideoDuaration(videoFile);
                            _isLoading = false;
                            if(_isMaxDuration == false){
                                final info = await videoCompresor(videoFile);
                                AppUtils.onPrintLog('info 11>> $info');
                                 if(info != null && info.file != null){
                                  //await _file.delete();
                                  await info.file.copy(fileFullPath);
                                  await info.file.delete();
                                  await videoFile.delete();
                                  if(_videoPlayerController != null){
                                    //_videoPlayerController.dispose();
                                    //_videoPlayerController = null;
                                  }

                                  if(_chewieController != null){
                                    //_chewieController.dispose();
                                    //_chewieController = null;
                                  }
                                  
                                 //videoFile.copy(fileFullPath);
                                  File compressFile = File(fileFullPath);
                                  AppUtils.onPrintLog('compressFile >> $compressFile');
                                    //_subscription.unsubscribe();
                                   _videoPlayerController =  VideoPlayerController.file(compressFile)..setVolume(1.0);
                                  _chewieController =  ChewieController(
                                    videoPlayerController: _videoPlayerController,
                                    //aspectRatio: 3 / 2,
                                    autoPlay: false,
                                    looping: false,
                                    showControls: true,
                                    materialProgressColors: ChewieProgressColors(
                                      playedColor: ThemeColor.theme_blue,
                                      handleColor: ThemeColor.theme_dark,
                                      backgroundColor: Colors.grey,
                                      bufferedColor: Colors.lightGreen,
                                    ),
                                    placeholder: Container(
                                      color: Colors.white,
                                    ),
                                    autoInitialize: true,
                                    routePageBuilder: (BuildContext context, Animation<double> animation,
                                        Animation<double> secondAnimation, provider) {
                                      return AnimatedBuilder(
                                        animation: animation,
                                        builder: (BuildContext context, Widget child) {
                                          return VideoScaffold2(
                                            child: Scaffold(
                                              resizeToAvoidBottomPadding: false,
                                              body: Container(
                                                alignment: Alignment.center,
                                                color: Colors.black,
                                                child: provider,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                    // Try playing around with some of these other options:
                                  );
                                  this.currentAssessmentTask.assessmentTaskLocalFile = filePath;
                                  this.arrAssessmentTask[this.currentTaskIndex] = this.currentAssessmentTask;
                                  _loadingStreamController.sink.add(false);
                                } else {
                                  _loadingStreamController.sink.add(false);
                                }
                                
                            } else {
                              _loadingStreamController.sink.add(false);
                            }
                          }
                        });
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'Maximum 2 minitues of video recroding allow',
                        style: TextStyle(
                          color: ThemeColor.theme_dark,
                          fontFamily: ThemeFont.font_pourceSanPro,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
                          
            ),
            StreamBuilder(
              stream: _loadingStreamController.stream,
              builder: (context,AsyncSnapshot<bool> snapshot){
                if(snapshot.hasData){
                  if(snapshot.data == true){
                     return ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 100

                      ),
                      child :Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      height: 200,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey
                            ),
                            
                          ),
                          Center(child: Text(
                            'Video',
                            style: TextStyle(
                              color: ThemeColor.theme_dark,
                              fontFamily: ThemeFont.font_pourceSanPro,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.center,
                          ),),
                          _isLoading?_showCircularProgress():SizedBox()
                        ],
                      ),
                    ));
                  } else {
                    if(_isMaxDuration == true){
                      return ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 100
                      ),
                      child :Center(
                        child: Text(
                          'Maximum 2 minitues of video recroding allow',
                          style: TextStyle(
                            color: ThemeColor.theme_dark,
                            fontFamily: ThemeFont.font_pourceSanPro,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                        )
                      ));
                    } else {
                      if(_chewieController != null){
                        return Container(
                          //padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                          child: Expanded(
                            child: Center(
                              child: Chewie(
                                controller: _chewieController,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 200
                          ),
                          child :Center(
                            child: Text(
                              'Somthing went wrong. Please try again',
                              style: TextStyle(
                                color: ThemeColor.theme_dark,
                                fontFamily: ThemeFont.font_pourceSanPro,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.center,
                            )
                          )
                        );
                      }
                    }
                  }
                } else {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    height: 200,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey
                          ),
                          
                        ),
                        Center(child: Text(
                          'Video',
                          style: TextStyle(
                            color: ThemeColor.theme_dark,
                            fontFamily: ThemeFont.font_pourceSanPro,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                        ),),
                        _isLoading?_showCircularProgress():SizedBox()
                      ],
                    ),
                  );
                }

              },
            )
          ],
        ),
      );
    
    
  }

  

  isMaxVideoDuaration(File file) async{
    if(file != null){
      final info = await _flutterVideoCompress.getMediaInfo(file.path);
      double duration = info.duration;
      AppUtils.onPrintLog('duration >> $duration');
      AppUtils.onPrintLog('maxDuration >> ${AppUtils.maxVideoDuration}');
      if(duration > AppUtils.maxVideoDuration){
        AppUtils.onPrintLog('return >> true');
      return true;
      } else {
        AppUtils.onPrintLog('return >> false');
        return false;
      }
    }else{
      return true;
    }
  }

  videoCompresor(File file) async{
    final info = await _flutterVideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality, // default(VideoQuality.DefaultQuality)
      deleteOrigin: false, // default(false)
    );

    if(info != null && info.file != null){
      return info;
    } else {
      videoCompresor(file);
    }
  } 

  
  
}


class VideoScaffold2 extends StatefulWidget {
  const VideoScaffold2({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _VideoScaffold2State();
}

class _VideoScaffold2State extends State<VideoScaffold2> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    AutoOrientation.landscapeMode();
    super.initState();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    AutoOrientation.portraitMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

