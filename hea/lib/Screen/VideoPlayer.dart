import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';
import 'package:hea/Utils/AppUtils.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/services.dart';
import 'dart:io';


class customVideoPlayer extends StatefulWidget {
  customVideoPlayer({Key key,@required this.url, @required this.isLocal}): super(key:key);
  String url;
  bool isLocal;
  @override
  _customVideoPlayerState createState() => _customVideoPlayerState();
}


class _customVideoPlayerState extends State<customVideoPlayer> {

  TargetPlatform _platform;
  VideoPlayerController _videoPlayerController1;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    getLocalVideo();
  }

  getLocalVideo() async {
    if(widget.isLocal == false){
      _videoPlayerController1 = VideoPlayerController.network(
        widget.url);
    } else {
      String docDirectory =  await AppUtils.getDocumentPath();
      final file = new File('$docDirectory/${widget.url}');
      _videoPlayerController1 = VideoPlayerController.file(file);
    }
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController1,
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
  }
  
  

  @override
  void dispose() {
    //_videoPlayerController1.dispose();
    //_chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: _chewieController != null?Chewie(
                  controller: _chewieController,
                ):Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
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
            ),*/
            
            
          ],
        ),
      );
  }
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



