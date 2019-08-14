import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import 'SharedPreferences.dart';
import 'connectivity.dart';
class AppUtils{
    
    static double maxVideoDuration = 120000.00;
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
      AppUtils.onPrintLog("pop  >> 13");
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

    static Future<String> getDocumentPath() async{
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      return appDirectory.path;
    }

    static Future<String> getAssessorPath() async {
      final String assessorUUID = await AppUtils.getAssessorUUID();
      return 'Document/$assessorUUID';
    }

    static Future<String> getAssessmentPath(String assessmentUDID) async{
      final String assessorPath =  await AppUtils.getAssessorPath();
      return '$assessorPath/$assessmentUDID';
    }

    static Future<String> getCreateFolder(String path) async{
      final String appDirectory = await getDocumentPath();

      AppUtils.onPrintLog('appDirectory >> $appDirectory');
      //final String folderPath  = await getTaskPath(folderName);
      final String directory = '$appDirectory/$path';
      await Directory(directory).create(recursive: true);
      return directory;
    }

    static Future<void> deleteLocalFolder(String path) async{
      final String appDirectory = await getDocumentPath();
      //final String directory = '$appDirectory/$assessorPath/$folderName';
      final String directory = '$appDirectory/$path';
      try {
        var res = await Directory(directory).delete(recursive: true);
         AppUtils.onPrintLog('res >>> $res');
      } catch (e){
         AppUtils.onPrintLog('res >>> ${e.toString()}');
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
    static const image_camera = "assets/images/camera.png";
    static const image_mic = "assets/images/Audio_record.png";
    static const image_rerecord = "assets/images/rerecord.png";
    static const image_edit = "assets/images/edit.png";
    static const eyeOpen = "assets/images/eye.png";
    static const eyeClose = "assets/images/eye-closed.png";
    static const eyeClose1 = "assets/images/eyeclose.png";
    

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
    static const String kError_SomethingWentWrong = 'Something went wrong!';
    static const String kError_QuestionSelecteError = 'Please select your answer from given option!';
    static const String kError_QuestionInputError = 'Please input your answer!';
    static const String kError_NoAssessment = 'Candidate have no assessment!';
    static const String kError_FileNotFound = 'File not found!';
    static const String kMsg_Logout = 'Are you sure you want Logout and return to Login Screen?';
    static const String kMsg_Reset = 'Please check your email';
    static const String kError_Download = 'Need to Download assessment first!';
    static const String kError_DownloadAlready = 'Assessment already downloaded!';
    static const String kError_UploadedAlready = 'Assessment already uploaded!';
    static const String kError_UploadedSuccess = 'Assessment upload successfully!';

    static const String kError_captureImage = 'Please capture image!';
    static const String kError_recoredAudio = 'Please record audio or stop audio recorder!';
    static const String kError_recoredVideo = 'Please record video!';
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
    static const String kTitle_UploadAssessment = 'Upload Assessment';
    static const String kTitle_EndAssessment = 'End Assessment';
    static const String kTitle_Check = 'Check';
    static const String kTitle_Next = 'Next';
    static const String kTitle_Pass = 'Pass';
    static const String kTitle_Fail = 'Fail';
    static const String kTitle_Pending = 'Pending';
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
  static const String param_candidate_uuid = 'candidate_uuid';
  static const String param_assessment_result = 'assessment_result';
  static const String param_assessment_obtainmark = 'assessment_obtainmark';
  static const String param_assessment_data = 'assessment_data';
  static const String param_assessor_comment = 'assessor_comment';
  static const String key_isContactAdd = 'isContactAdd';
  static const String key_isCalenterEventAdd = 'isCalenterEventAdd';
  static const String param_rawJson = 'rawJson';

  
  
}

class ApiResponsKey {
  ApiResponsKey._();
  static const String success  = 'success';
  static const String data = 'data';
  static const String error = 'error';
  static const String code = 'code';
  static const String message = 'message';
}

class Permission {
  Permission._();
  static const String camera  = 'camera';
  static const String microphone = 'microphone';
  
}

class AppDatabase{
  AppDatabase._();

  static final String db_name = 'HAE.db';
  static final int db_version = 1;

  static final String tbl_name_assessments = 'assessments';
  static final String tbl_name_assessment_meta = 'assessment_meta';
  static final String tbl_name_tasks = 'tasks';
  
  static final String tbl_assessments_field_assessment_uuid = 'assessment_uuid';
  static final String tbl_assessments_field_assessment_appointment = 'assessment_appointment';
  static final String tbl_assessments_field_assessment_assessor_first = "assessment_assessor_first";
  static final String tbl_assessments_field_assessment_assessor_last = 'assessment_assessor_last';
  static final String tbl_assessments_field_assessment_candidate_first = 'assessment_candidate_first';
  static final String tbl_assessments_field_assessment_candidate_last = 'assessment_candidate_last';
  static final String tbl_assessments_field_assessment_candidate_email = 'assessment_candidate_email';
  static final String tbl_assessments_field_assessment_candidate_number = 'assessment_candidate_number';
  static final String tbl_assessments_field_assessment_address_company = 'assessment_address_company';
  static final String tbl_assessments_field_assessment_address_address1 = 'assessment_address_address1';
  static final String tbl_assessments_field_assessment_address_address2 = 'assessment_address_address2';
  static final String tbl_assessments_field_assessment_address_towncity = 'assessment_address_towncity';
  static final String tbl_assessments_field_assessment_address_county = 'assessment_address_county';
  static final String tbl_assessments_field_assessment_address_postcode = 'assessment_address_postcode';
  static final String tbl_assessments_field_assessment_address_country = 'assessment_address_country';
  static final String tbl_assessments_field_assessment_title = 'assessment_title';
  static final String tbl_assessments_field_assessor_uuid = 'assessor_uuid';
  static final String tbl_assessments_field_id = 'assessment_id';
  static final String tbl_assessments_field_assessment_is_add_contact = 'is_add_contact';
  static final String tbl_assessments_field_assessment_contact_id = 'contact_id';
  static final String tbl_assessments_field_assessment_is_add_calender = 'is_add_calender';
  static final String tbl_assessments_field_assessment_calender_id = 'calender_id';
  static final String tbl_assessments_field_assessment_is_downloaded = 'is_downloaded';
  static final String tbl_assessments_field_assessment_is_uploaded = 'is_uploaded';
  static final String tbl_assessments_field_assessment_is_end = 'is_end';
  

  static final String tbl_tasks_field_assessment_task_uuid = 'assessment_task_uuid';
  static final String tbl_tasks_field_assessment_task_type = 'assessment_task_type';
  static final String tbl_tasks_field_assessment_task_correct_response_id = 'assessment_task_correct_response_id';
  static final String tbl_tasks_field_assessment_task_answer_response_id = 'assessment_task_answer_response_id';
  static final String tbl_tasks_field_score = 'score';
  static final String tbl_tasks_field_prompt = 'prompt';
  static final String tbl_tasks_field_result = 'result';
  static final String tbl_tasks_field_responses = 'responses';
  static final String tbl_tasks_field_assessment_task_correct_response_text = 'assessment_task_correct_response_text';
  static final String tbl_tasks_field_assessment_task_answer_response_text = 'assessment_task_answer_response_text';
  static final String tbl_tasks_field_assessment_task_asset_url = 'assessment_task_asset_url';
  static final String tbl_tasks_field_assessment_task_upload_format = 'assessment_task_upload_format';
  static final String tbl_tasks_field_assessment_task_local_file = 'assessment_task_local_file';
  static final String tbl_tasks_field_assessment_uuid = 'assessment_uuid';
  static final String tbl_tasks_field_assessor_uuid = 'assessor_uuid';

  static final String tbl_assessment_meta_field_assessor_uuid = 'assessor_uuid';
  static final String tbl_assessment_meta_field_assessor_name = 'assessor_name';
  static final String tbl_assessment_meta_field_candidate_uuid = 'candidate_uuid';
  static final String tbl_assessment_meta_field_candidate_name = 'candidate_name';
  static final String tbl_assessment_meta_field_assessment_uuid = 'assessment_uuid';
  static final String tbl_assessment_meta_field_assessment_name = 'assessment_name';
  static final String tbl_assessment_meta_field_assessment_introduction = 'assessment_introduction';
  static final String tbl_assessment_meta_field_assessment_passmark = 'assessment_passmark';
  static final String tbl_assessment_meta_field_assessment_obtainmark = 'assessment_obtainmark';
  static final String tbl_assessment_meta_field_assessment_result = 'assessment_result';
  static final String tbl_assessment_meta_field_assessment_comment = 'assessment_comment';
  static final String tbl_assessment_meta_field_assessment_result_Is_pending = 'assessment_result_Is_pending';

        


}



