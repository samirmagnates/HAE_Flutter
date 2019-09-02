


import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:hea/Utils/AppUtils.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as path;

typedef void OnError(Exception exception);

enum PlayerState { stopped, playing, paused }

/*
  Audio Player class is use to play audio file from local or server url;
  Parameters :
    url : server or local url for audio file. This url recevice form class which call CustomAudioPlayer constructor.
    assessmentUuid : assessmentUuid is unique id of assessment use to find local folder having name assessmentUuid

*/

class CustomAudioPlayer extends StatefulWidget {
  @override
  
  CustomAudioPlayer({Key key,@required this.url,@required this.assessmentUuid }): super(key:key);
  String url;
  String assessmentUuid;
  _CustomAudioPlayerState createState() => _CustomAudioPlayerState();
}

class _CustomAudioPlayerState extends State<CustomAudioPlayer> {

  Duration duration;
  Duration position;
  AudioPlayer audioPlayer;
  String localFilePath;
  PlayerState playerState = PlayerState.stopped;
  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;
  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;
  bool isDownloading = false;
  bool isError = false;

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  String audioURL = 'https://codingwithjoe.com/wp-content/uploads/2018/03/applause.mp3';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    audioURL = widget.url;
    duration = new Duration(seconds: 0);
    _loadFile();
     initAudioPlayer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
  }
  /*
    initAudioPlayer is init Audioplaye using url
    set subscriber for audioposition change is for fast forward using slider 
    set duration parameter if running and if stope than set to begining.

  */
  Future initAudioPlayer() async{
    audioPlayer = new AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
        isDownloading = false;
        isError = true;
      });
    });
  }

  /*
    play is use to play audion and change status to playing.
  */
  Future play() async {
    try{
      //await audioPlayer.play(audioURL);
      await audioPlayer.play(localFilePath, isLocal: true);
      setState(() => playerState = PlayerState.playing);
    } catch (Exception){
      setState(() {
        isDownloading = false;
        isError = true;
      });
    }

    setState(() {
      playerState = PlayerState.playing;
    });
  }

  /*Future _playLocal() async {
    await audioPlayer.play(localFilePath, isLocal: true);
    setState(() => playerState = PlayerState.playing);
  }*/

  /*
    pause is use to pause audion and change status to paused.
  */
  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  /*
    stop is use to stop audio and change status to stopped and reset duration parameter.
  */
  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = new Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  /*
    this method is called when audio end
    change status to stopped
    reset position duration set to 0
  */
  void onComplete() {
    setState(() {
      playerState = PlayerState.stopped;
      position =  Duration(seconds: 0);
    });
    //stop();
    //setState(() => playerState = PlayerState.stopped);
  }
  /*
      _loadFileBytes is use to download audio file for server using url and add to app local storage.
  */

  Future<Uint8List> _loadFileBytes(String url, {OnError onError}) async {
    Uint8List bytes;
    try {
      bytes = await readBytes(url);
    } on ClientException catch(e){
      setState(() {
        isDownloading = false;
        isError = true;
      });
    }
    return bytes;
  }

  /*
    _loadFile use to get file from local storage
    if file not exits in local than call _loadFileBytes function to download file from server using url.
  */
  Future _loadFile() async {

      try{
        setState(() {
        isDownloading = true;
        });
        
        String taskFolder = await AppUtils.getAssessmentPath(widget.assessmentUuid);
        String docDirectory = await AppUtils.getDocumentPath();
        //await AppUtils.getCreateFolder(taskFolder);

        //String pathFolder = await AppUtils.getLocalPath(widget.taskUuid);
        final file = new File('$docDirectory/$taskFolder/audio${path.extension(audioURL)}');

        if(await AppUtils.isNetwrokAvailabe(context) == true){
            final bytes = await _loadFileBytes(audioURL,
            onError: (Exception exception) =>
                AppUtils.onPrintLog('_loadFile => exception $exception'));
           await file.writeAsBytes(bytes);
        } 

        if (await file.exists()){
           setState(() {
            localFilePath = file.path;
          });
        }
         

        setState(() {
          isDownloading = false;
        });
      } catch (Exception){
        setState(() {
          isDownloading = false;
          isError = true;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Material(
            color: Colors.grey[200],
            child: new Center(
              child:Stack(
                children: <Widget>[
                  Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    new Material(child: _buildPlayer()),
                    
                  ]),
                  
                ],
              )
            )));
  }

  /*
   * _buildPlayer return audio player ui 
   *  ui  
   *   text current duration : use to show current duration of audio
   *   text duration : show audio file duration
   *   slider : slider move as per current dutation 
   *    button paly/pause : use to play or stop audio 
   */

  Widget _buildPlayer() => new Container(
      padding: new EdgeInsets.all(16.0),
      child : duration == null || isError == true
        ? new Container(
            child: Center(
              child: Text(
                AppMessage.kError_FileNotFound,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: ThemeFont.font_pourceSanPro,
                    color: ThemeColor.theme_dark,
                    fontWeight: FontWeight.w400,
                    fontSize: 18.0),
              ),
            ),
        )
        :Stack(
        children: <Widget>[
          Column(mainAxisSize: MainAxisSize.min, children: [
            duration == null || isError == true
                ? new Container(
                    child: Center(
                      child: Text(
                        AppMessage.kError_FileNotFound,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: ThemeFont.font_pourceSanPro,
                            color: ThemeColor.theme_dark,
                            fontWeight: FontWeight.w400,
                            fontSize: 18.0),
                      ),
                    ),
                )
                : new Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                  child: Slider(
                    activeColor: ThemeColor.theme_blue,
                    inactiveColor: ThemeColor.theme_dark,
                    value: position?.inMilliseconds?.toDouble() ?? 0.0,
                    onChanged: (double value) => audioPlayer.seek((value / 1000).roundToDouble()),
                    min: 0.0,
                    max: duration.inMilliseconds.toDouble()),
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
                      position != null
                          ? "${positionText ?? ''}"
                          : duration != null ? durationText : '',
                      style: TextStyle(
                          fontFamily: ThemeFont.font_pourceSanPro,
                          color: ThemeColor.theme_dark,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.0),
                  ),
                  Text(
                      position != null
                          ? "${durationText ?? ''}"
                          : duration != null ? durationText : '',
                      style: TextStyle(
                          fontFamily: ThemeFont.font_pourceSanPro,
                          color: ThemeColor.theme_dark,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.0),
                  )
                ]
              ),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  onPressed: isPlaying ? () => pause() : () => play(),
                  iconSize: 100.0,
                  icon: isPlaying?Image.asset(ThemeImage.image_pause):Image.asset(ThemeImage.image_play),
                  color: Colors.cyan),
                
              ],
            ),
          ]),
          isDownloading?AppUtils.onShowLoder() : SizedBox(height: 0.0, width: 0.0,),
        ],
      ),
    );
}