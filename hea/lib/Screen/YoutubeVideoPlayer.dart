import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hea/Utils/AppUtils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_youtube_view/flutter_youtube_view.dart';


class YoutubeVideoPlayer extends StatefulWidget {
  YoutubeVideoPlayer({Key key,@required this.url }): super(key:key);
  String url;
  @override
  _YoutubeVideoPlayerState createState() => _YoutubeVideoPlayerState();
}


class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> implements YouTubePlayerListener{
  
  double _currentVideoSecond = 0.0;
  String _playerState = "";
  FlutterYoutubeViewController _controller;
  
  String youtube_id = '';
  String _videoId = "iLnmTe5Q2Qw";  

  
  @override
  void initState() {
    if(widget.url.contains('https://youtu.be/')){
      youtube_id = widget.url.replaceAll('https://youtu.be/', '');
    } 

    
    super.initState();
  }

  @override
  void onCurrentSecond(double second) {
    //AppUtils.onPrintLog("onCurrentSecond second = $second");
    _currentVideoSecond = second;
  }

  @override
  void onError(String error) {
    AppUtils.onPrintLog("onError error = $error");
  }

  @override
  void onReady() {
    AppUtils.onPrintLog("onReady");
  }

  @override
  void onStateChange(String state) {
    AppUtils.onPrintLog("onStateChange state = $state");
    setState(() {
      _playerState = state;
    });
  }

  @override
  void onVideoDuration(double duration) {
    AppUtils.onPrintLog("onVideoDuration duration = $duration");
  }

  void _onYoutubeCreated(FlutterYoutubeViewController controller) {
    this._controller = controller;
  }

  void _loadOrCueVideo() {
    _controller.loadOrCueVideo(youtube_id, _currentVideoSecond);
  }
  

  Widget getYoutubeVideo(){
    return FlutterYoutubeView(
              onViewCreated: _onYoutubeCreated,
              listener: this,
              params: YoutubeParam(
              videoId: youtube_id,
               showUI: true,
              startSeconds: 0.0),
            );
  }

  @override
  void dispose() {
    //_controller = null;
    super.dispose();
  }
  

  

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: getYoutubeVideo(),
              ),
            ),
            
          ],
        ),
      );
  }
}





