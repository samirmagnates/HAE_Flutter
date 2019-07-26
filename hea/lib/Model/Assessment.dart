import 'package:intl/intl.dart';
import '../Utils/AppUtils.dart';
class Assessment{

  String ASSESSMENT_UUID;
  String ASSESSMENT_APPOINTMENT;
  String ASSESSMENT_APPOINTMENT_DATE;
  String ASSESSMENT_APPOINTMENT_TIME;
  String ASSESSMENT_ASSESSOR_FIRST;
  String ASSESSMENT_ASSESSOR_LAST;
  String ASSESSMENT_CANDIDATE_FIRST;
  String ASSESSMENT_CANDIDATE_LAST;
  String ASSESSMENT_CANDIDATE_EMAIL;
  String ASSESSMENT_CANDIDATE_NUMBER;
  String ASSESSMENT_ADDRESS_COMPANY;
  String ASSESSMENT_ADDRESS_ADDRESS1;
  String ASSESSMENT_ADDRESS_ADDRESS2;
  String ASSESSMENT_ADDRESS_TOWNCITY;
  String ASSESSMENT_ADDRESS_COUNTY;
  String ASSESSMENT_ADDRESS_POSTCODE;
  String ASSESSMENT_ADDRESS_COUNTRY;
  String ASSESSMENT_TITLE;
  String ASSESSOR_UUID;
  int ASSESSMENT_ID;
  int IS_ADD_CONTACT;
  String CONTACT_ID;
  int IS_ADD_CALENDER;
  String CALENDER_ID;
  int IS_DOWNLOADED;
  int IS_UPLOADED;
  int IS_END;
  

  Assessment({

      this.ASSESSMENT_UUID,
      this.ASSESSMENT_APPOINTMENT,
      this.ASSESSMENT_ASSESSOR_FIRST,
      this.ASSESSMENT_ASSESSOR_LAST,
      this.ASSESSMENT_CANDIDATE_FIRST,
      this.ASSESSMENT_CANDIDATE_LAST,
      this.ASSESSMENT_CANDIDATE_EMAIL,
      this.ASSESSMENT_CANDIDATE_NUMBER,
      this.ASSESSMENT_ADDRESS_COMPANY,
      this.ASSESSMENT_ADDRESS_ADDRESS1,
      this.ASSESSMENT_ADDRESS_ADDRESS2,
      this.ASSESSMENT_ADDRESS_TOWNCITY,
      this.ASSESSMENT_ADDRESS_COUNTY,
      this.ASSESSMENT_ADDRESS_POSTCODE,
      this.ASSESSMENT_ADDRESS_COUNTRY,
      this.ASSESSMENT_TITLE,
      this.ASSESSOR_UUID,
      this.ASSESSMENT_ID,
      this.ASSESSMENT_APPOINTMENT_DATE,
      this.ASSESSMENT_APPOINTMENT_TIME,
      this.IS_ADD_CONTACT,
      this.CONTACT_ID,
      this.IS_ADD_CALENDER,
      this.CALENDER_ID,
      this.IS_DOWNLOADED,
      this.IS_UPLOADED,
      this.IS_END
  });

  getValue(Map<String, dynamic> json,String key)  {
    AppUtils.onPrintLog(json);
    AppUtils.onPrintLog(key);
    if (json['$key'] != null){
      return json['$key'];
    } else {
      String lowerKey = key.toLowerCase();
      AppUtils.onPrintLog(lowerKey);
      if(json['${key.toLowerCase()}'] != null){
          return json['${key.toLowerCase()}'];
      } else {
        return null;
      } 
    }
    //return json[key]?json[key]:json[key.toLowerCase()]?json[key.toLowerCase()]:'';
  }

  Assessment.fromJSON(Map<String, dynamic> json){
      String formattedDate = '';
      String strTime = '';

      //String utcdate = json["ASSESSMENT_APPOINTMENT"]?json["ASSESSMENT_APPOINTMENT"]:json["assessment_appointment"]?json["assessment_appointment"]:'';
      
      String utcdate =   getValue(json,'ASSESSMENT_APPOINTMENT'); 
      formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(utcdate).toLocal());
      strTime = DateFormat('HH:mm:ss').format(DateTime.parse(utcdate).toLocal());
      
      ASSESSMENT_UUID = getValue(json,'ASSESSMENT_UUID')as String;
      ASSESSMENT_APPOINTMENT = getValue(json,'ASSESSMENT_APPOINTMENT')as String;
      ASSESSMENT_ASSESSOR_FIRST = getValue(json,'ASSESSMENT_ASSESSOR_FIRST') as String;
      ASSESSMENT_ASSESSOR_LAST = getValue(json,'ASSESSMENT_ASSESSOR_LAST') as String;
      ASSESSMENT_CANDIDATE_FIRST = getValue(json,'ASSESSMENT_CANDIDATE_FIRST') as String;
      ASSESSMENT_CANDIDATE_LAST = getValue(json,'ASSESSMENT_CANDIDATE_LAST') as String;
      ASSESSMENT_CANDIDATE_EMAIL = getValue(json,'ASSESSMENT_CANDIDATE_EMAIL') as String;
      ASSESSMENT_CANDIDATE_NUMBER = getValue(json,'ASSESSMENT_CANDIDATE_NUMBER') as String;
      ASSESSMENT_ADDRESS_COMPANY = getValue(json,'ASSESSMENT_ADDRESS_COMPANY') as String;
      ASSESSMENT_ADDRESS_ADDRESS1 = getValue(json,'ASSESSMENT_ADDRESS_ADDRESS1') as String;
      ASSESSMENT_ADDRESS_ADDRESS2 = getValue(json,'ASSESSMENT_ADDRESS_ADDRESS2') as String;
      ASSESSMENT_ADDRESS_TOWNCITY = getValue(json,'ASSESSMENT_ADDRESS_TOWNCITY') as String;
      ASSESSMENT_ADDRESS_COUNTY = getValue(json,'ASSESSMENT_ADDRESS_COUNTY') as String ;
      ASSESSMENT_ADDRESS_POSTCODE = getValue(json,'ASSESSMENT_ADDRESS_POSTCODE') as String;
      ASSESSMENT_ADDRESS_COUNTRY = getValue(json,'ASSESSMENT_ADDRESS_COUNTRY') as String;
      ASSESSMENT_TITLE = getValue(json,'ASSESSMENT_TITLE') as String;
      ASSESSOR_UUID = getValue(json,'ASSESSOR_UUID') as String;
      ASSESSMENT_ID = getValue(json,'assessment_id') != null?getValue(json,'assessment_id'): getValue(json,'ID') != null?getValue(json,'ID'):'';
      ASSESSMENT_APPOINTMENT_DATE = formattedDate;
      ASSESSMENT_APPOINTMENT_TIME = strTime;
      IS_ADD_CONTACT = getValue(json,'IS_ADD_CONTACT') != null?getValue(json,'IS_ADD_CONTACT'):0;
      CONTACT_ID = getValue(json,'CONTACT_ID');
      IS_ADD_CALENDER = getValue(json,'IS_ADD_CALENDER') != null?getValue(json,'IS_ADD_CALENDER'):0;
      CALENDER_ID = getValue(json,'CALENDER_ID');
      IS_DOWNLOADED = getValue(json,'IS_DOWNLOADED') != null?getValue(json,'IS_DOWNLOADED'):0;
      IS_UPLOADED = getValue(json,'IS_UPLOADED') != null?getValue(json,'IS_UPLOADED'):0;
      IS_END = getValue(json,'IS_END') != null?getValue(json,'IS_END'):0;
      
  }
    

  Map<String,dynamic> toJson() => {'assessment_uuid': ASSESSMENT_UUID, 'assessment_appointment': ASSESSMENT_APPOINTMENT, 'assessment_assessor_first': ASSESSMENT_ASSESSOR_FIRST,
    'assessment_assessor_last':ASSESSMENT_ASSESSOR_LAST,'assessment_candidate_first':ASSESSMENT_CANDIDATE_FIRST,'assessment_candidate_last':ASSESSMENT_CANDIDATE_LAST,
    'assessment_candidate_email':ASSESSMENT_CANDIDATE_EMAIL,'assessment_candidate_number':ASSESSMENT_CANDIDATE_NUMBER,'assessment_address_company':ASSESSMENT_ADDRESS_COMPANY,
    'assessment_address_address1':ASSESSMENT_ADDRESS_ADDRESS1,'assessment_address_address2':ASSESSMENT_ADDRESS_ADDRESS2,'assessment_address_towncity':ASSESSMENT_ADDRESS_TOWNCITY,
    'assessment_address_county':ASSESSMENT_ADDRESS_COUNTY,'assessment_address_postcode':ASSESSMENT_ADDRESS_POSTCODE,'assessment_address_country':ASSESSMENT_ADDRESS_COUNTRY,
    'assessment_title':ASSESSMENT_TITLE,'assessor_uuid':ASSESSOR_UUID,'assessment_id':ASSESSMENT_ID,'is_add_contact':IS_ADD_CONTACT,'contact_id':CONTACT_ID,'is_add_calender':IS_ADD_CALENDER,'calender_id':CALENDER_ID,'is_downloaded':IS_DOWNLOADED,'is_uploaded':IS_UPLOADED,'is_end':IS_END
    };
  

}