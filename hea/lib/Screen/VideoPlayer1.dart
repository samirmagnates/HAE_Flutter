import 'dart:async';

import 'package:flutter/material.dart';

import 'dart:io';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hea/Model/AssessmentTasks.dart';
import 'package:hea/Utils/AppUtils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
class VideoPlayer1 extends StatefulWidget {

  VideoPlayer1({Key key, @required this.assessmentTask, @required this.assessmentUuid}) : super(key:key);
  AssessmentTasks assessmentTask;
  String assessmentUuid;
  @override
  _VideoPlayer1State createState() => _VideoPlayer1State();
}

class _VideoPlayer1State extends State<VideoPlayer1> {

  bool _isLoading = false;
  bool _isMaxDuration = false;
  AssessmentTasks currentAssessmentTask;
  String currentAssessmentUuid;
  ChewieController _chewieController;
  VideoPlayerController _videoPlayerController;
  final _flutterVideoCompress = FlutterVideoCompress();
  Subscription _subscription;

  final _loadingStreamController = StreamController<bool>.broadcast();

  @override
  void initState() { 
    super.initState();
    currentAssessmentTask = widget.assessmentTask;
    currentAssessmentUuid = widget.assessmentUuid;
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _subscription.unsubscribe();
    //_loadingStreamCtrl.close();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 300,
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          color: Colors.red
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
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
                            if (videoFile != null && mounted) {
                            _isLoading = true;
                            _loadingStreamController.sink.add(true);
                            
                            String taskFolder = await AppUtils.getAssessmentPath(this.currentAssessmentUuid);
                            if(this.currentAssessmentTask.assessmentTaskLocalFile.isNotEmpty){
                              
                              final file = new File('$docDirectory/$taskFolder/${this.currentAssessmentTask.assessmentTaskLocalFile}');
                              if (await file.exists()){
                                  await file.delete();
                                  this.currentAssessmentTask.assessmentTaskLocalFile = '';
                              }
                            }
                            
                            await AppUtils.getCreateFolder(taskFolder);
                            //String pathFolder = await AppUtils.getLocalPath(this.assessmentMetaData.assessmentUuid);
                            String fileExtesion = 'mp4';
                            if(this.currentAssessmentTask.assessmentTaskUploadFormat != null && this.currentAssessmentTask.assessmentTaskUploadFormat.isNotEmpty){
                                List<String> arrExtention = this.currentAssessmentTask.assessmentTaskUploadFormat.split(',');
                                fileExtesion = arrExtention.first;
                            } 
                            final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
                            final String filePath = '$taskFolder/${this.currentAssessmentTask.assessmentTaskUuid}_$currentTime.$fileExtesion';

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
                                  if(_videoPlayerController != null){
                                    _videoPlayerController.dispose();
                                    _videoPlayerController = null;
                                  }

                                  if(_chewieController != null){
                                    _chewieController.dispose();
                                    _chewieController = null;
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
                                          return VideoScaffold1(
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

   Widget _showCircularProgress(){
    return Center(child: CircularProgressIndicator());
  }
}

class VideoScaffold1 extends StatefulWidget {
  const VideoScaffold1({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _VideoScaffold1State();
}

class _VideoScaffold1State extends State<VideoScaffold1> {
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