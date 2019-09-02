import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:hea/Utils/AppUtils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hea/Model/AssessmentTasks.dart';
import 'package:hea/Model/AssessmentMetaData.dart';
import 'package:hea/Model/QuestionOptions.dart';
import 'package:hea/Model/Assessment.dart';


class DBManager{
  DBManager._();
  static final DBManager db = DBManager._();
  static Database _database;


  Future<Database> get database async{
      if(_database != null){
        return _database;
      }

      _database = await initDB();
      return _database;

  }

  initDB() async {
    Directory documentDictionry = await getApplicationDocumentsDirectory();
    String path = join(documentDictionry.path,AppDatabase.db_name);

    return await openDatabase(path, version:AppDatabase.db_version, onOpen:(db){

    },onCreate:(Database db, int version) async {
        await createTables(db);
    });
  } 

  createTables(Database db) async {
      await db.execute("CREATE TABLE ${AppDatabase.tbl_name_assessments} ("
          "id INTEGER PRIMARY KEY,"
          "${AppDatabase.tbl_assessments_field_assessment_uuid} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_appointment} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_assessor_first} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_assessor_last} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_candidate_first} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_candidate_last} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_candidate_email} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_candidate_number} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_address_company} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_address_address1} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_address_address2} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_address_towncity} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_address_county} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_address_postcode} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_address_country} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_title} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessor_uuid} TEXT,"
          "${AppDatabase.tbl_assessments_field_id} INTEGER,"
          "${AppDatabase.tbl_assessments_field_assessment_is_add_contact} INTEGER DEFAULT 0,"
          "${AppDatabase.tbl_assessments_field_assessment_contact_id} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_is_add_calender} INTEGER DEFAULT 0,"
          "${AppDatabase.tbl_assessments_field_assessment_calender_id} TEXT,"
          "${AppDatabase.tbl_assessments_field_assessment_is_downloaded} INTEGER DEFAULT 0,"
          "${AppDatabase.tbl_assessments_field_assessment_is_uploaded} INTEGER DEFAULT 0,"
          "${AppDatabase.tbl_assessments_field_assessment_is_end} INTEGER DEFAULT 0"
        ")");

        await db.execute("CREATE TABLE ${AppDatabase.tbl_name_tasks} ("
          "id INTEGER PRIMARY KEY,"
          "${AppDatabase.tbl_tasks_field_assessment_task_uuid} TEXT,"
          "${AppDatabase.tbl_tasks_field_assessment_task_type} TEXT,"
          "${AppDatabase.tbl_tasks_field_score} TEXT,"
          "${AppDatabase.tbl_tasks_field_prompt} TEXT,"
          "${AppDatabase.tbl_tasks_field_result} TEXT,"
          "${AppDatabase.tbl_tasks_field_responses} TEXT,"
          "${AppDatabase.tbl_tasks_field_assessment_task_correct_response_id} TEXT,"
          "${AppDatabase.tbl_tasks_field_assessment_task_answer_response_id} TEXT,"
          "${AppDatabase.tbl_tasks_field_assessment_task_answer_response_text} TEXT,"
          "${AppDatabase.tbl_tasks_field_assessment_task_correct_response_text} TEXT,"
          "${AppDatabase.tbl_tasks_field_assessment_task_asset_url} TEXT,"
          "${AppDatabase.tbl_tasks_field_assessment_task_upload_format} TEXT,"
          "${AppDatabase.tbl_tasks_field_assessment_task_local_file} TEXT,"
          "${AppDatabase.tbl_tasks_field_assessment_uuid} TEXT,"
          "${AppDatabase.tbl_tasks_field_assessor_uuid} TEXT"
        ")");

        await db.execute("CREATE TABLE ${AppDatabase.tbl_name_assessment_meta} ("
          "id INTEGER PRIMARY KEY,"
          "${AppDatabase.tbl_assessment_meta_field_assessor_uuid} TEXT,"
          "${AppDatabase.tbl_assessment_meta_field_assessor_name} TEXT,"
          "${AppDatabase.tbl_assessment_meta_field_candidate_uuid} TEXT,"
          "${AppDatabase.tbl_assessment_meta_field_candidate_name} TEXT,"
          "${AppDatabase.tbl_assessment_meta_field_assessment_uuid} TEXT,"
          "${AppDatabase.tbl_assessment_meta_field_assessment_name} TEXT,"
          "${AppDatabase.tbl_assessment_meta_field_assessment_introduction} TEXT,"
          "${AppDatabase.tbl_assessment_meta_field_assessment_passmark} TEXT,"
          "${AppDatabase.tbl_assessment_meta_field_assessment_obtainmark} TEXT,"
          "${AppDatabase.tbl_assessment_meta_field_assessment_result} TEXT,"
          "${AppDatabase.tbl_assessment_meta_field_assessment_comment} TEXT,"
          "${AppDatabase.tbl_assessment_meta_field_assessment_result_Is_pending} INTEGER DEFAULT 0"
          
        ")");
    }

    performAssessmetnsAction(Assessment assessment) async {

      var res = await checkAssessementsExists(assessment);
      if (res.isNotEmpty){
         return await updateAssessmetns(assessment);
      } else {
          return await insertAssessmetns(assessment);
      }
    }

    checkAssessementsExists(Assessment assessment) async {
      final db = await database;
      var res = await db.rawQuery('SELECT * FROM ${AppDatabase.tbl_name_assessments} WHERE ${AppDatabase.tbl_assessments_field_assessment_uuid}="${assessment.ASSESSMENT_UUID}"');
      return res;

    }

    insertAssessmetns(Assessment assessment) async {
        String assessmentUuid = assessment.ASSESSMENT_UUID != null ? assessment.ASSESSMENT_UUID:'';
        String assessmentAppointment = assessment.ASSESSMENT_APPOINTMENT != null ? assessment.ASSESSMENT_APPOINTMENT:'';
        String assessmentAssessorFirst = assessment.ASSESSMENT_ASSESSOR_FIRST != null ? assessment.ASSESSMENT_ASSESSOR_FIRST:'';
        String assessmentAssessorLast = assessment.ASSESSMENT_ASSESSOR_LAST != null ? assessment.ASSESSMENT_ASSESSOR_LAST:'';
        String assessmentCandidateFirst = assessment.ASSESSMENT_CANDIDATE_FIRST != null ? assessment.ASSESSMENT_CANDIDATE_FIRST:'';
        String assessmentCandidateLast = assessment.ASSESSMENT_CANDIDATE_LAST != null ? assessment.ASSESSMENT_CANDIDATE_LAST:'';
        String assessmentCandidateEmail = assessment.ASSESSMENT_CANDIDATE_EMAIL != null ? assessment.ASSESSMENT_CANDIDATE_EMAIL:'';
        String assessmentCandidateNumber = assessment.ASSESSMENT_CANDIDATE_NUMBER != null ? assessment.ASSESSMENT_CANDIDATE_NUMBER:'';
        String assessmentAddressCompany = assessment.ASSESSMENT_ADDRESS_COMPANY != null ? assessment.ASSESSMENT_ADDRESS_COMPANY:'';
        String assessmentAddressAddress1 = assessment.ASSESSMENT_ADDRESS_ADDRESS1 != null ? assessment.ASSESSMENT_ADDRESS_ADDRESS1:'';
        String assessmentAddressAddress2 = assessment.ASSESSMENT_ADDRESS_ADDRESS2 != null ? assessment.ASSESSMENT_ADDRESS_ADDRESS2:'';
        String assessmentAddressTowncity = assessment.ASSESSMENT_ADDRESS_TOWNCITY != null ? assessment.ASSESSMENT_ADDRESS_TOWNCITY:'';
        String assessmentAddressCounty = assessment.ASSESSMENT_ADDRESS_COUNTY != null ? assessment.ASSESSMENT_ADDRESS_COUNTY:'';
        String assessmentAddressPostcode = assessment.ASSESSMENT_ADDRESS_POSTCODE != null ? assessment.ASSESSMENT_ADDRESS_POSTCODE:'';
        String assessmentAddressCountry = assessment.ASSESSMENT_ADDRESS_COUNTRY != null ? assessment.ASSESSMENT_ADDRESS_COUNTRY:'';
        String assessmentTitle = assessment.ASSESSMENT_TITLE != null ? assessment.ASSESSMENT_TITLE:'';
        String assessorUuid = assessment.ASSESSOR_UUID != null ? assessment.ASSESSOR_UUID:'';
        int assessmentId = assessment.ASSESSMENT_ID != null ? assessment.ASSESSMENT_ID:0;
        int isAddContact = assessment.IS_ADD_CONTACT != null ? assessment.IS_ADD_CONTACT:0;
        String contactId = assessment.CONTACT_ID != null ? assessment.CONTACT_ID:'';
        int isAddCalender = assessment.IS_ADD_CALENDER != null ? assessment.IS_ADD_CALENDER:0;
        String calenderId = assessment.CALENDER_ID != null ? assessment.CALENDER_ID:'';
        int isDownloaded = assessment.IS_DOWNLOADED != null ? assessment.IS_DOWNLOADED:0;
        int isUploaded = assessment.IS_UPLOADED != null ? assessment.IS_UPLOADED:0;
        int isEnd = assessment.IS_END != null ? assessment.IS_END:0;
        

        final db = await database;
        var res = await db.rawInsert(
          "INSERT INTO ${AppDatabase.tbl_name_assessments} (${AppDatabase.tbl_assessments_field_assessment_uuid},${AppDatabase.tbl_assessments_field_assessment_appointment},${AppDatabase.tbl_assessments_field_assessment_assessor_first},${AppDatabase.tbl_assessments_field_assessment_assessor_last},${AppDatabase.tbl_assessments_field_assessment_candidate_first},${AppDatabase.tbl_assessments_field_assessment_candidate_last},${AppDatabase.tbl_assessments_field_assessment_candidate_email},${AppDatabase.tbl_assessments_field_assessment_candidate_number},${AppDatabase.tbl_assessments_field_assessment_address_company},${AppDatabase.tbl_assessments_field_assessment_address_address1},${AppDatabase.tbl_assessments_field_assessment_address_address2},${AppDatabase.tbl_assessments_field_assessment_address_towncity},${AppDatabase.tbl_assessments_field_assessment_address_county},${AppDatabase.tbl_assessments_field_assessment_address_postcode},${AppDatabase.tbl_assessments_field_assessment_address_country},${AppDatabase.tbl_assessments_field_assessment_title},${AppDatabase.tbl_assessments_field_assessor_uuid},${AppDatabase.tbl_assessments_field_id},${AppDatabase.tbl_assessments_field_assessment_is_add_contact},${AppDatabase.tbl_assessments_field_assessment_contact_id},${AppDatabase.tbl_assessments_field_assessment_is_add_calender},${AppDatabase.tbl_assessments_field_assessment_calender_id},${AppDatabase.tbl_assessments_field_assessment_is_downloaded},${AppDatabase.tbl_assessments_field_assessment_is_uploaded},${AppDatabase.tbl_assessments_field_assessment_is_end})"
          " VALUES ('$assessmentUuid','$assessmentAppointment','$assessmentAssessorFirst','$assessmentAssessorLast','$assessmentCandidateFirst','$assessmentCandidateLast','$assessmentCandidateEmail','$assessmentCandidateNumber','$assessmentAddressCompany','$assessmentAddressAddress1','$assessmentAddressAddress2','$assessmentAddressTowncity','$assessmentAddressCounty','$assessmentAddressPostcode','$assessmentAddressCountry','$assessmentTitle','$assessorUuid',$assessmentId,$isAddContact,'$contactId',$isAddCalender,'$calenderId',$isDownloaded,$isUploaded,$isEnd)");
        return res;
    }
    updateAssessmetns(Assessment assessment) async {
        final db = await database;
        var res = await db.update('${AppDatabase.tbl_name_assessments}', assessment.toJson(),where: "${AppDatabase.tbl_assessments_field_assessment_uuid} = ?", whereArgs: [assessment.ASSESSMENT_UUID]);
        return res;
    }
    
    getAssessements(String assessmentUuid,String assessorUuid) async {
      final db = await database;
      List<Map> list = await db.rawQuery('SELECT * FROM ${AppDatabase.tbl_name_assessments} WHERE ${AppDatabase.tbl_assessments_field_assessment_uuid} = ? AND ${AppDatabase.tbl_assessments_field_assessor_uuid} = ?',['$assessmentUuid','$assessorUuid']);
      AppUtils.onPrintLog('list >> $list');
      return list.isNotEmpty ? Assessment.fromJSON(list.first) : null;
    }
    
    getAllAssessements(String assessorUuid) async {
      final db = await database;
      var res = await db.rawQuery('SELECT * FROM ${AppDatabase.tbl_name_assessments} WHERE ${AppDatabase.tbl_assessments_field_assessor_uuid}="$assessorUuid"');
      List<Assessment> list =
          res.isNotEmpty ? res.map((c) => Assessment.fromJSON(c)).toList() : [];
      return list;
    }

    checkAssessementsMetaDataExists(AssessmentMetaData metadata) async {
      final db = await database;
      var res = await db.rawQuery('SELECT * FROM ${AppDatabase.tbl_name_assessment_meta} WHERE ${AppDatabase.tbl_assessment_meta_field_assessment_uuid}="${metadata.assessmentUuid}"');
      return res;
    }


    insertAssessmetnsMetaData(AssessmentMetaData metadata) async {
        String assessorUuid = metadata.assessorUuid != null ? metadata.assessorUuid:'';
        String assessorName = metadata.assessorName != null ? metadata.assessorName:'';
        String candidateUuid = metadata.candidateUuid != null ? metadata.candidateUuid:'';
        String candidateName = metadata.candidateName != null ? metadata.candidateName:'';
        String assessmentUuid = metadata.assessmentUuid != null ? metadata.assessmentUuid:'';
        String assessmentName = metadata.assessmentName != null ? metadata.assessmentName:'';
        String assessmentIntroduction = metadata.assessmentIntroduction != null ? metadata.assessmentIntroduction:'';
        String assessmentPassmark = metadata.assessmentPassmark != null ? metadata.assessmentPassmark:'';
        String assessmentObtainmark = metadata.assessmentObtainmark != null ? metadata.assessmentObtainmark:'';
        String assessmentResult = metadata.assessmentResult != null ? metadata.assessmentResult:'';
        String assessmentComment = metadata.assessmentComment != null ? metadata.assessmentComment:'';
        int isPending = metadata.assessmentPending != null ? metadata.assessmentPending:0;
        
        
        final db = await database;
        var res = await db.rawInsert(
          "INSERT INTO ${AppDatabase.tbl_name_assessment_meta} (${AppDatabase.tbl_assessment_meta_field_assessor_uuid},${AppDatabase.tbl_assessment_meta_field_assessor_name},${AppDatabase.tbl_assessment_meta_field_candidate_uuid},${AppDatabase.tbl_assessment_meta_field_candidate_name},${AppDatabase.tbl_assessment_meta_field_assessment_uuid},${AppDatabase.tbl_assessment_meta_field_assessment_name},${AppDatabase.tbl_assessment_meta_field_assessment_introduction},${AppDatabase.tbl_assessment_meta_field_assessment_passmark},${AppDatabase.tbl_assessment_meta_field_assessment_obtainmark},${AppDatabase.tbl_assessment_meta_field_assessment_result},${AppDatabase.tbl_assessment_meta_field_assessment_comment},${AppDatabase.tbl_assessment_meta_field_assessment_result_Is_pending})"
          " VALUES ('$assessorUuid','$assessorName','$candidateUuid','$candidateName','$assessmentUuid','$assessmentName','$assessmentIntroduction','$assessmentPassmark','$assessmentObtainmark','$assessmentResult','$assessmentComment',$isPending)");
        return res;
    }

    updateAssessmetnsMetaData(AssessmentMetaData metadata) async {
        final db = await database;
        var res = await db.update('${AppDatabase.tbl_name_assessment_meta}', metadata.toJson(),where: "${AppDatabase.tbl_assessment_meta_field_assessment_uuid} = ?", whereArgs: [metadata.assessmentUuid]);
        return res;
    }
    
    getAssessementsMetaData(String assessmentUuid,String assessorUuid) async {
      final db = await database;
      List<Map> list = await db.rawQuery('SELECT * FROM ${AppDatabase.tbl_name_assessment_meta} WHERE ${AppDatabase.tbl_assessment_meta_field_assessment_uuid} = ? AND ${AppDatabase.tbl_assessment_meta_field_assessor_uuid} = ?',['$assessmentUuid','$assessorUuid']);
      AppUtils.onPrintLog('list >> $list');
      return list.isNotEmpty ? AssessmentMetaData.fromJSON(list.first) : null;
      
    }

    
    
    getAllAssessementsMetaData(String assessorUuid) async {
      final db = await database;
      var res = await db.rawQuery('SELECT * FROM ${AppDatabase.tbl_name_assessment_meta} WHERE ${AppDatabase.tbl_assessment_meta_field_assessor_uuid}="$assessorUuid"');
      List<AssessmentMetaData> list =
          res.isNotEmpty ? res.map((c) => AssessmentMetaData.fromJSON(c)).toList() : [];
      return list;
    }


    checkAssessementsTaskExists(AssessmentTasks task,String assessmentUuid,String assessorUuid) async {
      final db = await database;
      var res = await db.rawQuery('SELECT * FROM ${AppDatabase.tbl_name_tasks} WHERE ${AppDatabase.tbl_tasks_field_assessment_task_uuid}="${task.assessmentTaskUuid}" AND ${AppDatabase.tbl_tasks_field_assessment_uuid}="$assessmentUuid" AND ${AppDatabase.tbl_tasks_field_assessor_uuid}="$assessorUuid"');
      AppUtils.onPrintLog('checkAssessementsTaskExists >> $res');
      return res;
    }


    insertAssessmetnsTask(AssessmentTasks task, String assessmentuuid, String assessoruuid) async {
        String assessmentTaskUuid = task.assessmentTaskUuid;
        String assessmentTaskType = task.assessmentTaskType;
        String assessmentTaskCorrectResponseId = task.assessmentTaskCorrectResponseId;
        String assessmentTaskAnswerIdResponseId = task.assessmentTaskAnswerIdResponseId;
        String assessmentTaskCorrectResponseText = task.assessmentTaskCorrectResponseText;
        String assessmentTaskAnswerResponseText = task.assessmentTaskAnswerResponseText;
        String assessmentTaskAssetUrl = task.assessmentTaskAssetUrl;
        String score = task.score;  
        String prompt = task.prompt;  
        String result = task.result;
        String responses  = task.responses;
        //List<QuestionOptions> answers;
        String assessmentTaskUploadFormat = task.assessmentTaskUploadFormat;
        String assessmentTaskLocalFile = task.assessmentTaskLocalFile;
        String assessmentUuid = task.assessmentUuid != ''?task.assessmentUuid:assessmentuuid;
        String assessorUuid = task.assessorUuid != ''? task.assessorUuid:assessoruuid;

        final db = await database;

        // var res = await db.rawInsert(
        //   "INSERT INTO ${AppDatabase.tbl_name_tasks} (${AppDatabase.tbl_tasks_field_assessment_task_uuid},${AppDatabase.tbl_tasks_field_assessment_task_type},${AppDatabase.tbl_tasks_field_score},${AppDatabase.tbl_tasks_field_prompt},${AppDatabase.tbl_tasks_field_result},${AppDatabase.tbl_tasks_field_responses},${AppDatabase.tbl_tasks_field_assessment_task_correct_response_id},${AppDatabase.tbl_tasks_field_assessment_task_answer_response_id},${AppDatabase.tbl_tasks_field_assessment_task_answer_response_text},${AppDatabase.tbl_tasks_field_assessment_task_correct_response_text},${AppDatabase.tbl_tasks_field_assessment_task_asset_url},${AppDatabase.tbl_tasks_field_assessment_task_upload_format},${AppDatabase.tbl_tasks_field_assessment_task_local_file},${AppDatabase.tbl_tasks_field_assessment_uuid},${AppDatabase.tbl_tasks_field_assessor_uuid})"
        //   " VALUES ('$assessmentTaskUuid','$assessmentTaskType','$assessmentTaskCorrectResponseId','$assessmentTaskAnswerIdResponseId','$assessmentTaskCorrectResponseText','$assessmentTaskAnswerResponseText','$assessmentTaskAssetUrl','$score','$prompt','$result','$responses','$assessmentTaskUploadFormat','$assessmentTaskLocalFile','$assessmentUuid','$assessorUuid')");
        //    AppUtils.onPrintLog('inserted1: $res');

        var res = await db.rawInsert('INSERT INTO ${AppDatabase.tbl_name_tasks} (${AppDatabase.tbl_tasks_field_assessment_task_uuid},${AppDatabase.tbl_tasks_field_assessment_task_type},${AppDatabase.tbl_tasks_field_assessment_task_correct_response_id},${AppDatabase.tbl_tasks_field_assessment_task_answer_response_id},${AppDatabase.tbl_tasks_field_assessment_task_correct_response_text},${AppDatabase.tbl_tasks_field_assessment_task_answer_response_text},${AppDatabase.tbl_tasks_field_assessment_task_asset_url},${AppDatabase.tbl_tasks_field_score},${AppDatabase.tbl_tasks_field_prompt},${AppDatabase.tbl_tasks_field_result},${AppDatabase.tbl_tasks_field_responses},${AppDatabase.tbl_tasks_field_assessment_task_upload_format},${AppDatabase.tbl_tasks_field_assessment_task_local_file},${AppDatabase.tbl_tasks_field_assessment_uuid},${AppDatabase.tbl_tasks_field_assessor_uuid}) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',[assessmentTaskUuid,assessmentTaskType,assessmentTaskCorrectResponseId,assessmentTaskAnswerIdResponseId,assessmentTaskCorrectResponseText,assessmentTaskAnswerResponseText,assessmentTaskAssetUrl,score,prompt,result,responses,assessmentTaskUploadFormat,assessmentTaskLocalFile,assessmentUuid,assessorUuid]);
        AppUtils.onPrintLog('inserted1: $res');
        return res;

    }

    updateAssessmetnsTask(AssessmentTasks task) async {
        final db = await database;
        var res = await db.update('${AppDatabase.tbl_name_tasks}', task.toJson(),where: "${AppDatabase.tbl_tasks_field_assessment_task_uuid} = ?", whereArgs: [task.assessmentTaskUuid]);
        return res;
    }
    
    getAssessementsTask(String taskUuid,String assessmentUuid,String assessorUuid) async {
      final db = await database;
      List<Map> list = await db.rawQuery('SELECT * FROM ${AppDatabase.tbl_name_tasks} WHERE ${AppDatabase.tbl_tasks_field_assessment_task_uuid} = ? AND ${AppDatabase.tbl_tasks_field_assessment_uuid} = ? AND ${AppDatabase.tbl_tasks_field_assessor_uuid} = ?',['$taskUuid','$assessmentUuid','$assessorUuid']);
      AppUtils.onPrintLog('list >> $list');
      return list.isNotEmpty ? AssessmentTasks.fromJSON(list.first) : null;
      
    }
    
    getAllAssessementsTasks(String assessmentUuid,String assessorUuid) async {
      final db = await database;
      var res = await db.rawQuery('SELECT * FROM ${AppDatabase.tbl_name_tasks} WHERE ${AppDatabase.tbl_tasks_field_assessment_uuid}="$assessmentUuid" AND ${AppDatabase.tbl_tasks_field_assessor_uuid}="$assessorUuid"');
      List<AssessmentTasks> list =
          res.isNotEmpty ? res.map((c) => AssessmentTasks.fromJSON(c)).toList() : [];
      return list;
    }

    deleteTaskData(String assessmentUuid) async{
      final db = await database;

      db.delete(AppDatabase.tbl_name_assessments, where: "${AppDatabase.tbl_assessments_field_assessment_uuid} = ?", whereArgs: [assessmentUuid]);
      db.delete(AppDatabase.tbl_name_assessment_meta, where: "${AppDatabase.tbl_assessment_meta_field_assessment_uuid} = ?", whereArgs: [assessmentUuid]);
      db.delete(AppDatabase.tbl_name_tasks, where: "${AppDatabase.tbl_tasks_field_assessment_uuid} = ?", whereArgs: [assessmentUuid]);
    }

    clearDataBase(String assessorUuid) async {
      final db = await database;

      db.delete(AppDatabase.tbl_name_assessments, where: "${AppDatabase.tbl_assessments_field_assessor_uuid} = ?", whereArgs: [assessorUuid]);
      db.delete(AppDatabase.tbl_name_assessment_meta, where: "${AppDatabase.tbl_assessment_meta_field_assessor_uuid} = ?", whereArgs: [assessorUuid]);
      db.delete(AppDatabase.tbl_name_tasks, where: "${AppDatabase.tbl_tasks_field_assessor_uuid} = ?", whereArgs: [assessorUuid]);
    }
}