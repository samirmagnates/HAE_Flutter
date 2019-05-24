import 'dart:io';

import 'package:hea/Utils/AppUtils.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class APIManager {


  static const String baseURL = "https://ath.hae.org.uk/services/"; 

  Future httpRequest(String urltype, String method, context,Map body) async{

    String url = baseURL+urltype+'/';
    
    Map<String, String> requestHeaders = {
       //'Accept': 'application/json',
     };
    
    if(urltype == APIType.public){
      url = url+'account/';
    } else {
      String userToken = await AppUtils.getAppUserToken();
      requestHeaders[AppKey.header_Authorization] = userToken;
    }
    url = url+method+'/';
    var jsonData;
    try{
        var response = await http.post(url,body: body,headers: requestHeaders);
        AppUtils.onPrintLog("response >>> ${response.body}");
        var data = json.encode(response.body);
        try {
          jsonData = json.decode(response.body);
        } on FormatException catch (e) {
          print("That string didn't look like Json. >>> $e");
        } on NoSuchMethodError catch (e) {
          print('That string was null! >>> $e');
        }
    } on TimeoutException catch (e){

    } on SocketException catch(e){

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
}