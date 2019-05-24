import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:hea/Utils/AppUtils.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

typedef void OnError(Exception exception);

enum PlayerState { stopped, playing, paused }

class CustomAudioPlayer extends StatefulWidget {
  @override
  
  CustomAudioPlayer({Key key,@required this.url }): super(key:key);
  String url;
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

  void initAudioPlayer(){
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

  Future play() async {
    try{
      await audioPlayer.play(audioURL);
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

  Future _playLocal() async {
    await audioPlayer.play(localFilePath, isLocal: true);
    setState(() => playerState = PlayerState.playing);
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

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

  void onComplete() {
    setState(() {
      playerState = PlayerState.stopped;
      position =  Duration(seconds: 0);
    });
    //stop();
    //setState(() => playerState = PlayerState.stopped);
  }

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

  Future _loadFile() async {

      try{
        setState(() {
        isDownloading = true;
        });
        final bytes = await _loadFileBytes(audioURL,
            onError: (Exception exception) =>
                print('_loadFile => exception $exception'));

        final dir = await getApplicationDocumentsDirectory();
        final file = new File('${dir.path}/audio.mp3');

        await file.writeAsBytes(bytes);
        if (await file.exists())
          setState(() {
            localFilePath = file.path;
          });

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
                    /*localFilePath != null
                        ? new Text(localFilePath)
                        : new Container(),
                    new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            new RaisedButton(
                              onPressed: () => _loadFile(),
                              child: new Text('Download'),
                            ),
                            new RaisedButton(
                              onPressed: () => _playLocal(),
                              child: new Text('play local'),
                            ),
                          ]),
                    )*/
                  ]),
                  
                ],
              )
            )));
  }

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
            /*new Row(mainAxisSize: MainAxisSize.min, children: [
              new IconButton(
                  onPressed: isPlaying ? null : () => play(),
                  iconSize: 64.0,
                  icon: new Icon(Icons.play_arrow),
                  color: Colors.cyan),
              new IconButton(
                  onPressed: isPlaying ? () => pause() : null,
                  iconSize: 64.0,
                  icon: new Icon(Icons.pause),
                  color: Colors.cyan),
              new IconButton(
                  onPressed: isPlaying || isPaused ? () => stop() : null,
                  iconSize: 64.0,
                  icon: new Icon(Icons.stop),
                  color: Colors.cyan),
            ]),*/
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
                  onPressed: isPlaying ? null : () => play(),
                  iconSize: 100.0,
                  icon: isPlaying?Image.asset(ThemeImage.image_pause):Image.asset(ThemeImage.image_play),
                  color: Colors.cyan),
                /*new IconButton(
                    onPressed: () => mute(true),
                    icon: new Icon(Icons.headset_off),
                    color: Colors.cyan),
                new IconButton(
                    onPressed: () => mute(false),
                    icon: new Icon(Icons.headset),
                    color: Colors.cyan),*/
              ],
            ),
            /*new Row(mainAxisSize: MainAxisSize.min, children: [
              new Padding(
                  padding: new EdgeInsets.all(12.0),
                  child: new Stack(children: [
                    new CircularProgressIndicator(
                        value: 1.0,
                        valueColor: new AlwaysStoppedAnimation(Colors.grey[300])),
                    new CircularProgressIndicator(
                      value: position != null && position.inMilliseconds > 0
                          ? (position?.inMilliseconds?.toDouble() ?? 0.0) /
                              (duration?.inMilliseconds?.toDouble() ?? 0.0)
                          : 0.0,
                      valueColor: new AlwaysStoppedAnimation(Colors.cyan),
                      backgroundColor: Colors.yellow,
                    ),
                  ])),
              new Text(
                  position != null
                      ? "${positionText ?? ''} / ${durationText ?? ''}"
                      : duration != null ? durationText : '',
                  style: new TextStyle(fontSize: 24.0))
            ])*/
          ]),
          isDownloading?AppUtils.onShowLoder() : SizedBox(height: 0.0, width: 0.0,),
        ],
      ),
    );
}