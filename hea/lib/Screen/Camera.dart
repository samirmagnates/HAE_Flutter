import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';

class CameraCapture extends StatefulWidget {
  @override
  _CameraCaptureState createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture>  {

   List<CameraDescription> cameras;

  CameraController _cameraController;
  Future<void> _initializeControllerFuture;

  @override
  void initState() async{
    // TODO: implement initState
    super.initState();
    
    await getAvailabelCamera();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    _initializeControllerFuture = _cameraController.initialize();
  }

  Future<void> getAvailabelCamera() async {
    cameras = await availableCameras();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context,snapshot){
          if(snapshot.connectionState == ConnectionState.done){
              return CameraPreview(_cameraController);
          }else {
             return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}