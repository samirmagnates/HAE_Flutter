import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hea/Utils/SharedPreferences.dart';
import 'package:hea/Utils/connectivity.dart';
import 'dart:convert';
class AppUtils{
    
    static Future getAppUserToken() async{
      var user = await SharedPreferencesManager.getObject(AppKey.appuser);

      if(user is Map){
        String appUserToken = user[AppKey.appuser_token];
        return appUserToken;
      } else if(user is String && user.isNotEmpty){
        var appuser = json.decode(user);
        String appUserToken = appuser[AppKey.appuser_token];
        return appUserToken;
      } else{
        return '';
      }
    }

    static Future getAssessorUUID() async{

      var user = await SharedPreferencesManager.getObject(AppKey.appuser);
      if(user is Map){
        String assessorUUID = user[AppKey.appuser_assessor_uuid];
        return assessorUUID;
      } else if(user is String){
        if(user != null && user.isNotEmpty){
            var appuser = json.decode(user);
            String assessorUUID = appuser[AppKey.appuser_assessor_uuid];
            return assessorUUID;
        }
      }else {
        return '';
      }
    }

    static void onPrintLog(object){
      print(object);
    }

    static String getCurrentYear(){
      return DateTime.now().year.toString();
    }

    static Widget onShowLoder(){
      return Center(
        child: new CircularProgressIndicator()
      );
    }

    static void onHideLoader(context){
      Navigator.pop(context);
    }
    

    static void showInSnackBar(GlobalKey<ScaffoldState>_scaffoldKey, String value) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(value),
        duration: Duration(seconds: 2),
      )
    );
  }

    static Future<bool> isNetwrokAvailabe(context) async{
        bool isNetworkAval = await Conectivity.isNetworkAvilable(); 
        if(isNetworkAval == true){
          return true;
        } else {
          return false;
        }
    }

    
}

class QuestionType {
  static const question_singleAnswer = "1";
  static const question_multipleAnswer = "2";
  static const question_boolAnswer = "3";
  static const question_textAnswer = "4";
  static const question_intgerAnswer = "5";
  static const question_imageViewAnswer = "6";
  static const question_audioPlayAnswer = "7";
  static const question_videoPlayAnswer = "8";
  static const question_imageCaptureAnswer = "9";
  static const question_audioRecordAnswer = "10";
  static const question_videoRecordAnswer = "11";
}

class ThemeColor{
    ThemeColor._();
    static const ans_Red =  Color(0xFFb41332);
    static const ans_green =  Color(0xFF49aa1c);
    static const theme_blue =  Color(0xFF0198c3);
    static const theme_dark =  Color(0xFF394b59);
    static const theme_borderline_gray = Color(0xFFb8bec3);
    static const theme_grey = Color(0xFFededed);

    static const theme_gradiant = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.1, 0.5],
      colors: [
            // Colors are easy thanks to Flutter's Colors class.
            theme_blue,
            theme_dark,
          ],
    );
}

class ThemeImage{
    ThemeImage._();
    static const image_logo =  "assets/images/login_logo.png";
    static const image_delete =  "assets/images/delete.png";
    static const image_logout =  "assets/images/logout.png";
    static const image_drowDownArrow =  "assets/images/dropdown_icon.png";
    static const image_check =  "assets/images/check.png";
    static const image_uncheck =  "assets/images/uncheck.png";
    static const image_no =  "assets/images/No.png";
    static const image_yes =  "assets/images/Yes.png";
    static const image_Bluetick =  "assets/images/Bluetick.png";
    static const image_back =  "assets/images/Backbutton.png";
    static const image_noImageFound = "assets/images/NoImageFound.png";
    static const image_pause = "assets/images/pause.png";
    static const image_play = "assets/images/Play.png";
    static const image_stop = "assets/images/Stop.png";
    

    
}

class ThemeFont{
  ThemeFont._();
  static const font_pourceSanPro = "SourceSansPro";
  }


class AppMessage{
    AppMessage._();
    static const String kError_EnterUserName = 'Please enter username';
    static const String kError_EnterPassword = 'Please enter password';
    static const String kError_NoInternet = 'Netwrok not availabel!';
    static const String kError_SomethingWentWrong = 'Something went wronge!';
    static const String kError_QuestionSelecteError = 'Please select your answer from given option!';
    static const String kError_QuestionInputError = 'Please input your answer!';
    static const String kError_NoAssessment = 'Candidate have no assessment!';
    static const String kError_FileNotFound = 'File not found!';
    static const String kMsg_Logout = 'Are you sure you want Logout and return to Login Screen?';
    static const String kMsg_Reset = 'Please check your email';
}

class AppRoute{
    AppRoute._();
    static const routeLoginScreen = 'Login';
    static const routeHomeScreen = 'Home';
}

class AppConstant{
  AppConstant._();

  static const String kHint_UserName = 'USERNAME';
    static const String kHint_Password = 'PASSWORD';
    static const String kHint_SecurePassword = "PASSWORD";
    
    static const String kTitle_Login = 'Log In';
    static const String kTitle_ForgotPass = 'Forgot Password?';
    static const String kTitle_Send = 'Send';
    static const String kTitle_StartAssessment = 'Start Assessment';
    static const String kTitle_EndAssessment = 'End Assessment';
    static const String kTitle_Check = 'Check';
    static const String kTitle_Next = 'Next';
    static const String kTitle_Pass = 'Pass';
    static const String kTitle_Fail = 'Fail';
    static const String kTitle_Assessment = 'Assessment';
    static const String kTitle_Assessment_Details = 'Assessment Details';
    static const String kTitle_AddToDevice = 'Add To Device';
    static const String kTitle_Download = 'Download';
    static const String kTitle_AssessmentHeader = 'Skills Assessor';


    
    static const String kHeader_ForogotPass = 'Forgot Password?';
    static const String kHeader_Skill = 'Skills Assessor';
}

class AppKey {
  AppKey._();
  static const String appuser = 'appuser';
  static const String appuser_token = 'appuser_token';
  static const String appuser_assessor_uuid = 'assessor_uuid';
  
  static const String header_Authorization = 'Authorization';
  static const String param_username = 'username';
  static const String param_password = 'password';
  static const String param_assessor_uuid = 'assessor_uuid';
  static const String param_appuser_token = 'appuser_token';
  static const String param_assessment_uuid = 'assessment_uuid';
  static const String key_isContactAdd = 'isContactAdd';
  static const String key_isCalenterEventAdd = 'isCalenterEventAdd';
  
}

class ApiResponsKey {
  ApiResponsKey._();
  static const String success  = 'success';
  static const String data = 'data';
  static const String error = 'error';
  static const String code = 'code';
  static const String message = 'message';
}



