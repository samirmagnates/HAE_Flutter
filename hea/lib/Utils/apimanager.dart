import 'dart:io';

import 'package:hea/Utils/AppUtils.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class APIManager {


  static const String baseURL = "https://ath.hae.org.uk/services/"; 

  Future httpRequest(String urltype, String method,Map body) async{

    String url = baseURL+urltype+'/';
    dynamic requestBody; 
    
    Map<String, String> requestHeaders = {
       //'content-type': 'application/json',
       //"content-type": "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW",
     };
     
    
    if(urltype == APIType.public){
      url = url+'account/';
    } else {
      String userToken = await AppUtils.getAppUserToken();
      requestHeaders[AppKey.header_Authorization] = userToken;
    }
    if(method == APIMathods.setManifest){
      //requestHeaders[HttpHeaders.contentTypeHeader] = 'text/plain';
      requestBody = body[AppKey.param_rawJson];
      url = url+'manifest/set/';
    } else if(method == APIMathods.getManifest){
      requestBody = body;
      url = url+'manifest/get/';
    } else if(method == APIMathods.uploadManifest){
      //requestHeaders[HttpHeaders.contentTypeHeader] = 'text/plain';
      requestBody = body[AppKey.param_rawJson];
      url = url+'manifest/upload/';
    } else if(method == APIMathods.uploadAssessment){
      url = url+method+'/';
      requestBody =  jsonEncode(body);
    }else {
      url = url+method+'/';
      requestBody = body;
      //requestHeaders[HttpHeaders.contentTypeHeader] = 'application/json';
    }

     AppUtils.onPrintLog("$method >>> $requestBody");
      
    var jsonData;
    try{
        var response = await http.post(url,body: requestBody,headers: requestHeaders);
        AppUtils.onPrintLog("response >>> ${response.body}");
        //var data = json.encode(response.body);
        try {
          jsonData = json.decode(response.body);
        } on FormatException catch (e) {
          AppUtils.onPrintLog("That string didn't look like Json. >>> $e");
        } on NoSuchMethodError catch (e) {
          AppUtils.onPrintLog('That string was null! >>> $e');
        }
    } on TimeoutException catch (e){
      AppUtils.onPrintLog("TimeoutException. >>> $e");

    } on SocketException catch(e){
      AppUtils.onPrintLog("SocketException. >>> $e");

    }
    return jsonData;
  }

}

class APIParams {
  APIParams._();

  static const String header_authorization = "Authorization";
  
  static const String param_username = "username";
  static const String param_password = "password";
  static const String param_appuser_token = "appuser_token";
  static const String param_assessment_uuid = "assessment_uuid";
  static const String param_assessor_uuid = "assessor_uuid";
  
}

class APIType {
  APIType._();
  static const String private = "private";
  static const String public = "public";
}
class APIMathods {
  APIMathods._();
  static const String login = "login";
  static const String logout = "logout";
  static const String resetPassword = "resetPassword";
  static const String uploadAssessment = "uploadAssessment";
  static const String getAssessments = "getAssessments";
  static const String downloadAssessment = "downloadAssessment";
  static const String setManifest = "setManifest";
  static const String getManifest = "getManifest";
  static const String uploadManifest = "uploadManifest";
}