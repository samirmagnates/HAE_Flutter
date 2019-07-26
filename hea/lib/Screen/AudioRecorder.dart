import 'package:flutter/material.dart';
import '../Model/AssessmentTasks.dart';
//import 'package:medcorder_audio/medcorder_audio.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../Utils/AppUtils.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;

class AudioRecorder extends StatefulWidget {
  @override

  AudioRecorder({Key key,@required this.task,@required this.assessmentUuid,@required this.filePath}):super(key:key);

  AssessmentTasks task;
  String assessmentUuid;
  String filePath;
  
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {

  //FlutterSound audioSound;
  bool isAlredyRecorde = false;
  String appDocumentPath = '';
  String filepath = "";
  String file = '';

  bool _isRecording = false;
  bool _isPlaying = false;
  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  FlutterSound flutterSound;

  //String _recorderTxt = '00:00:00';
  //String _playerTxt = '00:00:00';
  double _dbLevel;

  double recorederPosition = 0.0;

  get recordDurationText =>
      recorederPosition != null ? Duration(milliseconds:recorederPosition.toInt()).toString().split('.').first : '';

  double slider_current_position = 0.0;
  double max_duration = 0.0;
  double position = 0.0;

  get positionText =>
      position != null ? Duration(milliseconds:position.toInt()).toString().split('.').first : '';
  get durationText =>
      max_duration != null ? Duration(milliseconds:max_duration.toInt()).toString().split('.').first : '';

  @override
  initState() {
    super.initState();
    filepath = widget.filePath;
    //getFilePath();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
  }

  

  @override
  void setState(fn) {
    // TODO: implement setState
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    
    this.stopPlayer();
    this._stopRecord();
    flutterSound = null;
    //audioModule.stopRecord();
    //audioModule.stopPlay();
    //audioModule = null;
  }

  /*Future _initSettings() async {
    final String result = await audioModule.checkMicrophonePermissions();
    if (result == 'OK') {
      await audioModule.setAudioSettings();
      setState(() {
        canRecord = true;
      });
    }
    return;
  }*/


Future _startRecord() async {
    /*try {
      await audioModule.setAudioSettings();
      final String result = await audioModule.startRecord(file);
      setState(() {
        isRecord = true;
      });
      AppUtils.onPrintLog('startRecord: ' + result);
    } catch (e) {
      file = "";
      AppUtils.onPrintLog('startRecord: fail >> ${e.toString()}');
    }*/
    try {

      appDocumentPath = await AppUtils.getDocumentPath();
      this.file = '$appDocumentPath/$filepath';
      String path = await flutterSound.startRecorder(this.file);
      AppUtils.onPrintLog('startRecorder: $path');

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        /*DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
        String txt = DateFormat('hh:mm:ss', 'en_GB').format(date);*/
        recorederPosition = e.currentPosition;

        this.setState(() {
           max_duration = e.currentPosition;
          //this._recorderTxt = txt.substring(0, 8);
        });
      });
      _dbPeakSubscription =
          flutterSound.onRecorderDbPeakChanged.listen((value) {
            AppUtils.onPrintLog("got update -> $value");
            setState(() {
              this._dbLevel = value;
            });
          });

      this.setState(() {
        this._isRecording = true;
      });
    } catch (err) {
      AppUtils.onPrintLog('startRecorder error: $err');
    }
  }

  Future _stopRecord() async {
    /*try {
      final String result = await audioModule.stopRecord();
      AppUtils.onPrintLog('stopRecord: ' + result);
      setState(() {
        isRecord = false;
        isAlredyRecorde = true;
      });
    } catch (e) {
      AppUtils.onPrintLog('stopRecord: fail');
      setState(() {
        isRecord = false;
      });
    }*/
    try {
      String result = await flutterSound.stopRecorder();
      AppUtils.onPrintLog('stopRecorder: $result');

      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
      if (_dbPeakSubscription != null) {
        _dbPeakSubscription.cancel();
        _dbPeakSubscription = null;
      }

      this.setState(() {
        this._isRecording = false;
        this.isAlredyRecorde = true;
      });
    } catch (err) {
      AppUtils.onPrintLog('stopRecorder error: $err');
    }
  }

  Future startPlayer() async {
    /*if (isPlay) {
      await audioModule.stopPlay();
    } else {
      await audioModule.startPlay({
        "file": file,
        "position": 0.0,
      });
    }*/
    String path = await flutterSound.startPlayer(this.file);
    await flutterSound.setVolume(1.0);
    AppUtils.onPrintLog('startPlayer: $path');
    try {
      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
            slider_current_position = e.currentPosition;
            position = e.currentPosition;
            if (flutterSound.isPlaying == true) {
              this.setState(() {
                this._isPlaying = true;
                //this._playerTxt = txt.substring(0, 8);
                max_duration = e.duration;
              });
            } else if (flutterSound.isPlaying == false) {
              onComplete();
              
            }

          
          /*DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt(),
              isUtc: true);
          String txt = DateFormat('hh:mm:ss', 'en_GB').format(date);*/
          
        }
      });
    } catch (err) {
      AppUtils.onPrintLog('error: $err');
    }
  }

  void onComplete() {
    setState(() {
      this._isPlaying = false;
      slider_current_position =  0.0;
      position = 0.0;
    });
    //stop();
    //setState(() => playerState = PlayerState.stopped);
  }

  void stopPlayer() async{
    try {
      String result = await flutterSound.stopPlayer();
      AppUtils.onPrintLog('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }

      this.setState(() {
        this._isPlaying = false;
      });
    } catch (err) {
      AppUtils.onPrintLog('error: $err');
    }
  }

  void pausePlayer() async{
    String result = await flutterSound.pausePlayer();
    AppUtils.onPrintLog('pausePlayer: $result');
  }

  void resumePlayer() async{
    String result = await flutterSound.resumePlayer();
    AppUtils.onPrintLog('resumePlayer: $result');
  }

  void seekToPlayer(int milliSecs) async{
    String result = await flutterSound.seekToPlayer(milliSecs);
    AppUtils.onPrintLog('seekToPlayer: $result');
  }

  /*void _onEvent(dynamic event) {
    if (event['code'] == 'recording') {
      double power = event['peakPowerForChannel'];
      setState(() {
        recordPower = (60.0 - power.abs().floor()).abs();
        recordPosition = event['currentTime'];
        recordedDuration = Duration(seconds: recordPosition.toInt());
        position =  Duration(seconds: 0);
        duration =  Duration(seconds: recordPosition.toInt());
      });
    }
    if (event['code'] == 'playing') {
      String url = event['url'];
      AppUtils.onPrintLog('url >>> $url');
      setState(() {
        playPosition = event['currentTime'];
        fileDuration = event['duration'];
        position =  Duration(seconds: playPosition.toInt());
        duration =  Duration(seconds: fileDuration.toInt());
        isPlay = true;
      });
    }
    if (event['code'] == 'audioPlayerDidFinishPlaying') {
      setState(() {
        playPosition = 0.0;
        position =  Duration(seconds: 0);
        isPlay = false;
      });
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Material(
            color: Colors.white,
            child: new Center(
              child:Stack(
                children: <Widget>[
                  Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                            child: Container(
                              alignment: Alignment.topRight,
                              decoration: BoxDecoration(
                              ),
                              child: IconButton(
                                icon: Image.asset(ThemeImage.image_rerecord),
                                onPressed: () async {
                                  await this._stopRecord();
                                  await this.stopPlayer();
                                  
                                 setState(()  {
                                    _isPlaying = false;
                                    _isRecording = false;
                                    isAlredyRecorde = false;
                                    //_recorderTxt = '00:00:00';
                                    //_playerTxt = '00:00:00';
                                    max_duration = 0.0;
                                    slider_current_position = 0.0;
                                    position = 0.0;
                                    recorederPosition = 0.0;
                                  });

                                },
                              ),
                            ),
                          ),
                    new Material(child: isAlredyRecorde?_buildAudioPlayer():_buildAudioRecorder()),
                    
                  ]),
                  
                ],
              )
            )
        )
      );
  }

  Widget _buildAudioPlayer() => new Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      padding: new EdgeInsets.all(16.0),
      child : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        child: Slider(
                          activeColor: ThemeColor.theme_blue,
                          inactiveColor: ThemeColor.theme_dark,
                          value: slider_current_position,
                          min: 0.0,
                          max: max_duration,
                          onChanged: (double value) async{
                            //await flutterSound.seekToPlayer(value.toInt());
                          },
                        ),
                      ),
                      Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            Text(
                                this.positionText,
                                style: TextStyle(
                                    fontFamily: ThemeFont.font_pourceSanPro,
                                    color: ThemeColor.theme_dark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20.0),
                            ),
                            Text(
                                durationText,
                                style: TextStyle(
                                    fontFamily: ThemeFont.font_pourceSanPro,
                                    color: ThemeColor.theme_dark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20.0),
                            )
                          ]
                        ),
                      ),
                      
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        height: 100.0,
                        child: ClipOval(
                          child: FlatButton(
                            onPressed: () {
                              if (!this._isRecording && !this._isPlaying && file.length > 0) {
                                this.startPlayer();
                              } else {
                                this.pausePlayer();
                              }
                            },
                            padding: EdgeInsets.all(8.0),
                            child: _isPlaying?Image.asset(ThemeImage.image_pause):Image.asset(ThemeImage.image_play),
                          ),
                        ),
                      ),

                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
               ]
            ),
        );

  Widget _buildAudioRecorder() => new Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      padding: new EdgeInsets.all(16.0),
      child : Stack(
        children: <Widget>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 24.0, bottom:16.0),
                  child:Text(
                      this.recordDurationText,
                      style: TextStyle(
                          fontFamily: ThemeFont.font_pourceSanPro,
                          color: ThemeColor.theme_dark,
                          fontWeight: FontWeight.w600,
                          fontSize: 25.0),
                  ),
                  
                ),
                IconButton(
                  onPressed: _isRecording ? () => this._stopRecord() : () => this._startRecord(),
                  iconSize: 100.0,
                  icon: _isRecording?Image.asset(ThemeImage.image_stop):Image.asset(ThemeImage.image_mic),
                  color: Colors.cyan)
              ],
            ),
          
            
          ]
          ),
    );
}