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
          "${AppDatabase.tbl_assessment_meta_field_assessment_comment} TEXT"
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
        String assessment_uuid = assessment.ASSESSMENT_UUID != null ? assessment.ASSESSMENT_UUID:'';
        String assessment_appointment = assessment.ASSESSMENT_APPOINTMENT != null ? assessment.ASSESSMENT_APPOINTMENT:'';
        String assessment_assessor_first = assessment.ASSESSMENT_ASSESSOR_FIRST != null ? assessment.ASSESSMENT_ASSESSOR_FIRST:'';
        String assessment_assessor_last = assessment.ASSESSMENT_ASSESSOR_LAST != null ? assessment.ASSESSMENT_ASSESSOR_LAST:'';
        String assessment_candidate_first = assessment.ASSESSMENT_CANDIDATE_FIRST != null ? assessment.ASSESSMENT_CANDIDATE_FIRST:'';
        String assessment_candidate_last = assessment.ASSESSMENT_CANDIDATE_LAST != null ? assessment.ASSESSMENT_CANDIDATE_LAST:'';
        String assessment_candidate_email = assessment.ASSESSMENT_CANDIDATE_EMAIL != null ? assessment.ASSESSMENT_CANDIDATE_EMAIL:'';
        String assessment_candidate_number = assessment.ASSESSMENT_CANDIDATE_NUMBER != null ? assessment.ASSESSMENT_CANDIDATE_NUMBER:'';
        String assessment_address_company = assessment.ASSESSMENT_ADDRESS_COMPANY != null ? assessment.ASSESSMENT_ADDRESS_COMPANY:'';
        String assessment_address_address1 = assessment.ASSESSMENT_ADDRESS_ADDRESS1 != null ? assessment.ASSESSMENT_ADDRESS_ADDRESS1:'';
        String assessment_address_address2 = assessment.ASSESSMENT_ADDRESS_ADDRESS2 != null ? assessment.ASSESSMENT_ADDRESS_ADDRESS2:'';
        String assessment_address_towncity = assessment.ASSESSMENT_ADDRESS_TOWNCITY != null ? assessment.ASSESSMENT_ADDRESS_TOWNCITY:'';
        String assessment_address_county = assessment.ASSESSMENT_ADDRESS_COUNTY != null ? assessment.ASSESSMENT_ADDRESS_COUNTY:'';
        String assessment_address_postcode = assessment.ASSESSMENT_ADDRESS_POSTCODE != null ? assessment.ASSESSMENT_ADDRESS_POSTCODE:'';
        String assessment_address_country = assessment.ASSESSMENT_ADDRESS_COUNTRY != null ? assessment.ASSESSMENT_ADDRESS_COUNTRY:'';
        String assessment_title = assessment.ASSESSMENT_TITLE != null ? assessment.ASSESSMENT_TITLE:'';
        String assessor_uuid = assessment.ASSESSOR_UUID != null ? assessment.ASSESSOR_UUID:'';
        int assessment_id = assessment.ASSESSMENT_ID != null ? assessment.ASSESSMENT_ID:0;
        int is_add_contact = assessment.IS_ADD_CONTACT != null ? assessment.IS_ADD_CONTACT:0;
        String contact_id = assessment.CONTACT_ID != null ? assessment.CONTACT_ID:'';
        int is_add_calender = assessment.IS_ADD_CALENDER != null ? assessment.IS_ADD_CALENDER:0;
        String calender_id = assessment.CALENDER_ID != null ? assessment.CALENDER_ID:'';
        int is_downloaded = assessment.IS_DOWNLOADED != null ? assessment.IS_DOWNLOADED:0;
        int is_uploaded = assessment.IS_UPLOADED != null ? assessment.IS_UPLOADED:0;
        int is_end = assessment.IS_END != null ? assessment.IS_END:0;
        

        final db = await database;
        var res = await db.rawInsert(
          "INSERT INTO ${AppDatabase.tbl_name_assessments} (${AppDatabase.tbl_assessments_field_assessment_uuid},${AppDatabase.tbl_assessments_field_assessment_appointment},${AppDatabase.tbl_assessments_field_assessment_assessor_first},${AppDatabase.tbl_assessments_field_assessment_assessor_last},${AppDatabase.tbl_assessments_field_assessment_candidate_first},${AppDatabase.tbl_assessments_field_assessment_candidate_last},${AppDatabase.tbl_assessments_field_assessment_candidate_email},${AppDatabase.tbl_assessments_field_assessment_candidate_number},${AppDatabase.tbl_assessments_field_assessment_address_company},${AppDatabase.tbl_assessments_field_assessment_address_address1},${AppDatabase.tbl_assessments_field_assessment_address_address2},${AppDatabase.tbl_assessments_field_assessment_address_towncity},${AppDatabase.tbl_assessments_field_assessment_address_county},${AppDatabase.tbl_assessments_field_assessment_address_postcode},${AppDatabase.tbl_assessments_field_assessment_address_country},${AppDatabase.tbl_assessments_field_assessment_title},${AppDatabase.tbl_assessments_field_assessor_uuid},${AppDatabase.tbl_assessments_field_id},${AppDatabase.tbl_assessments_field_assessment_is_add_contact},${AppDatabase.tbl_assessments_field_assessment_contact_id},${AppDatabase.tbl_assessments_field_assessment_is_add_calender},${AppDatabase.tbl_assessments_field_assessment_calender_id},${AppDatabase.tbl_assessments_field_assessment_is_downloaded},${AppDatabase.tbl_assessments_field_assessment_is_uploaded},${AppDatabase.tbl_assessments_field_assessment_is_end})"
          " VALUES ('$assessment_uuid','$assessment_appointment','$assessment_assessor_first','$assessment_assessor_last','$assessment_candidate_first','$assessment_candidate_last','$assessment_candidate_email','$assessment_candidate_number','$assessment_address_company','$assessment_address_address1','$assessment_address_address2','$assessment_address_towncity','$assessment_address_county','$assessment_address_postcode','$assessment_address_country','$assessment_title','$assessor_uuid',$assessment_id,$is_add_contact,'$contact_id',$is_add_calender,'$calender_id',$is_downloaded,$is_uploaded,$is_end)");
        return res;
    }
    updateAssessmetns(Assessment assessment) async {
        final db = await database;
        var res = await db.update('${AppDatabase.tbl_name_assessments}', assessment.toJson(),where: "${AppDatabase.tbl_assessments_field_assessment_uuid} = ?", whereArgs: [assessment.ASSESSMENT_UUID]);
        return res;
    }
    
    getAssessements(String assessment_uuid,String assessor_uuid) async {
      final db = await database;
      List<Map> list = await db.rawQuery('SELECT * FROM ${AppDatabase.tbl_name_assessments} WHERE ${AppDatabase.tbl_assessments_field_assessment_uuid} = ? AND ${AppDatabase.tbl_assessments_field_assessor_uuid} = ?',['$assessment_uuid','$assessor_uuid']);
      AppUtils.onPrintLog('list >> $list');
      return list.isNotEmpty ? Assessment.fromJSON(list.first) : null;
    }
    
    getAllAssessements(String assessor_uuid) async {
      final db = await database;
      var res = await db.rawQuery('SELECT * FROM ${AppDatabase.tbl_name_assessments} WHERE ${AppDatabase.tbl_assessments_field_assessor_uuid}="$assessor_uuid"');
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
        String assessor_uuid = metadata.assessorUuid != null ? metadata.assessorUuid:'';
        String assessor_name = metadata.assessorName != null ? metadata.assessorName:'';
        String candidate_uuid = metadata.candidateUuid != null ? metadata.candidateUuid:'';
        String candidate_name = metadata.candidateName != null ? metadata.candidateName:'';
        String assessment_uuid = metadata.assessmentUuid != null ? metadata.assessmentUuid:'';
        String assessment_name = metadata.assessmentName != null ? metadata.assessmentName:'';
        String assessment_introduction = metadata.assessmentIntroduction != null ? metadata.assessmentIntroduction:'';
        String assessment_passmark = metadata.assessmentPassmark != null ? metadata.assessmentPassmark:'';
        String assessmentObtainmark = metadata.assessmentObtainmark != null ? metadata.assessmentObtainmark:'';
        String assessmentResult = metadata.assessmentResult != null ? metadata.assessmentResult:'';
        String assessmentComment = metadata.assessmentComment != null ? metadata.assessmentComment:'';

        
        
        final db = await database;
        var res = await db.rawInsert(
          "INSERT INTO ${AppDatabase.tbl_name_assessment_meta} (${AppDatabase.tbl_assessment_meta_field_assessor_uuid},${AppDatabase.tbl_assessment_meta_field_assessor_name},${AppDatabase.tbl_assessment_meta_field_candidate_uuid},${AppDatabase.tbl_assessment_meta_field_candidate_name},${AppDatabase.tbl_assessment_meta_field_assessment_uuid},${AppDatabase.tbl_assessment_meta_field_assessment_name},${AppDatabase.tbl_assessment_meta_field_assessment_introduction},${AppDatabase.tbl_assessment_meta_field_assessment_passmark},${AppDatabase.tbl_assessment_meta_field_assessment_obtainmark},${AppDatabase.tbl_assessment_meta_field_assessment_result},${AppDatabase.tbl_assessment_meta_field_assessment_comment})"
          " VALUES ('$assessor_uuid','$assessor_name','$candidate_uuid','$candidate_name','$assessment_uuid','$assessment_name','$assessment_introduction','$assessment_passmark','$assessmentObtainmark','$assessmentResult','$assessmentComment')");
        return res;
    }

    updateAssessmetnsMetaData(AssessmentMetaData metadata) async {
        final db = await database;
        var res = await db.update('${AppDatabase.tbl_name_assessment_meta}', metadata.toJson(),where: "${AppDatabase.tbl_assessment_meta_field_assessment_uuid} = ?", whereArgs: [metadata.assessmentUuid]);
        return res;
    }
    
    getAssessementsMetaData(String assessment_uuid,String assessor_uuid) async {
      final db = await database;
      List<Map> list = await db.rawQuery('SELECT * FROM ${AppDatabase.tbl_name_assessment_meta} WHERE ${AppDatabase.tbl_assessment_meta_field_assessment_uuid} = ? AND ${AppDatabase.tbl_assessment_meta_field_assessor_uuid} = ?',['$assessment_uuid','$assessor_uuid']);
      AppUtils.onPrintLog('list >> $list');
      return list.isNotEmpty ? AssessmentMetaData.fromJSON(list.first) : null;
      
    }
    
    getAllAssessementsMetaData(String assessor_uuid) async {
      final db = await database;
      var res = await db.rawQuery('SELECT * FROM ${AppDatabase.tbl_name_assessment_meta} WHERE ${AppDatabase.tbl_assessment_meta_field_assessor_uuid}="$assessor_uuid"');
      List<AssessmentMetaData> list =
          res.isNotEmpty ? res.map((c) => AssessmentMetaData.fromJSON(c)).toList() : [];
      return list;
    }


    checkAssessementsTaskExists(AssessmentTasks task,String assessment_uuid,String assessor_uuid) async {
      final db = await database;
      var res = await db.rawQuery('SELECT * FROM ${AppDatabase.tbl_name_tasks} WHERE ${AppDatabase.tbl_tasks_field_assessment_task_uuid}="${task.assessmentTaskUuid}"');
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