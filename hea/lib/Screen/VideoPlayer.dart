import 'package:auto_orientation/auto_orientation.dart';
import 'package:chewie/chewie.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../Utils/AppUtils.dart';
import 'dart:io';

class customVideoPlayer extends StatefulWidget {
  customVideoPlayer({Key key,@required this.url, @required this.isLocal}): super(key:key);
  String url;
  bool isLocal;
  @override
  _customVideoPlayerState createState() => _customVideoPlayerState();
}


class _customVideoPlayerState extends State<customVideoPlayer> {

// start
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  Subscription _subscription;
  bool isMaxDuration = false;

  final _flutterVideoCompress = FlutterVideoCompress();

  final _loadingStreamCtrl = StreamController<bool>.broadcast();
  File _file;
  String _fileFullPath;

  @override
  void initState() {
    super.initState();
    //getLocalVideo();
  }

  getVideoPlayer() async{
    if(widget.isLocal == false){
      return VideoPlayerController.network(widget.url);
    } else {
      final info = await videoCompresor();
      AppUtils.onPrintLog('info 11>> $info');
      //info.file.copy(_fileFullPath);
      //AppUtils.onPrintLog('info >> $info');
      //return VideoPlayerController.file(_file);
      if(info != null && info.file != null){
        //await _file.delete();
        info.file.copy(_fileFullPath);
        _file = info.file;
        AppUtils.onPrintLog('info >> $info');
          //_subscription.unsubscribe();
        return VideoPlayerController.file(info.file);
      } else {
        return null;
      }
      
    }
  }

  getLocalVideo() async {
    String docDirectory =  await AppUtils.getDocumentPath();
     _fileFullPath = '$docDirectory/${widget.url}'; 
    _file = new File(_fileFullPath);
    if(_file != null){
      //_loadingStreamCtrl.sink.add(true);
      isMaxDuration = await isMaxVideoDuaration();

      if(isMaxDuration == false){
        //_videoPlayerController = await getVideoPlayer();
        return await getVideoPlayer();
        /*if(_videoPlayerController != null){
          return _videoPlayerController;
        } else {
          return null;
        }*/
      
        //_loadingStreamCtrl.sink.add(false);
      } else {
        //_loadingStreamCtrl.sink.add(false);
        return null;
      }
    } else {
      //_loadingStreamCtrl.sink.add(false);
      return null;
    }
  }
  
  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _subscription.unsubscribe();
    //_loadingStreamCtrl.close();
    super.dispose();
  }

  isMaxVideoDuaration() async{
    if(widget.isLocal == true){
      if(_file != null){
        final info = await _flutterVideoCompress.getMediaInfo(_file.path);
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
        return false;
      }
    } else {
      AppUtils.onPrintLog('return else >> false');
      return false;
    }
  }

  videoCompresor() async{
    final info = await _flutterVideoCompress.compressVideo(
      _file.path,
      quality: VideoQuality.MediumQuality, // default(VideoQuality.DefaultQuality)
      deleteOrigin: false, // default(false)
    );

    if(info != null && info.file != null){
      return info;
    } else {
      videoCompresor();
    }
  } 

  videoProsessCompresor() async {
   //String docDirectory =  await AppUtils.getDocumentPath();
    //final file = new File('$docDirectory/${widget.url}');
    final info = await videoCompresor();
    AppUtils.onPrintLog('info 11>> $info');
    _subscription = _flutterVideoCompress.compressProgress$.subscribe((progress){
      debugPrint('progress: $progress');
      if(progress == 100){
        info.file.copy(_fileFullPath);
        AppUtils.onPrintLog('info >> $info');
        _subscription.unsubscribe();
        return true;
      }
    });
  }

  @override
  Widget build1(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _loadingStreamCtrl.stream,
      builder: (context, AsyncSnapshot<bool> snapshot){
          if(snapshot.data == false){
            if(_file == null){
              return Center(
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
                );
            } else{
              if(isMaxDuration == true){
                return Center(
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
                );
              } else {
                if(_chewieController != null){
                  return Center(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Center(
                            child: _chewieController != null?Chewie(
                              controller: _chewieController,
                            ):isMaxDuration?Center(
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
                                  ):Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.red
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ),
                        ),
                        /*FlatButton(
                          onPressed: () {
                            _chewieController.enterFullScreen();
                          },
                          child: Text('Fullscreen'),
                        ), //temp end*/
                      ],
                    ),
                  );
                } else {
                  return Center(
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
                    );
                }
              }
            }
          } else {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
          future:  getLocalVideo(),
          builder: (BuildContext contaxt, AsyncSnapshot snapShot){
            if(snapShot.hasData){
              _videoPlayerController = snapShot.data as VideoPlayerController;
              if(_videoPlayerController != null){
                  _chewieController =  ChewieController(
                    videoPlayerController: _videoPlayerController,
                    aspectRatio: 3 / 2,
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
                          return VideoScaffold(
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
              } else {
                AppUtils.onPrintLog('_videoPlayerController >> $_videoPlayerController');
              }
              return Center(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: _chewieController != null?Chewie(
                          controller: _chewieController,
                        ):isMaxDuration?Center(
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
                              ):Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.red
                            ),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ),
                    ),
                    /*FlatButton(
                      onPressed: () {
                        _chewieController.enterFullScreen();
                      },
                      child: Text('Fullscreen'),
                    ),// temp add*/
                  ],
                ),
              );
            } else {
              if(isMaxDuration == true){
                return Center(
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
                );
              } else {
                return Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                      ),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
              }
              
            }
          },
        );
    
  }
  //End
  
}

class VideoScaffold extends StatefulWidget {
  const VideoScaffold({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _VideoScaffoldState();
}

class _VideoScaffoldState extends State<VideoScaffold> {
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