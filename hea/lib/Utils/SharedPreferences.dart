import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
class SharedPreferencesManager{
  
  static Future getValue(String key) async{
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.get(key); 
  }

  static void setValue(String value , String key) async{
    if(value != null && key != null){
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
    
  }

  static Future getObject(String key) async{
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var value  =  await prefs.get(key);
      if(value != null){
        return json.decode(value);
      } 
      return '';
      
  }

  static Future setObject(dynamic value , String key) async{
    if(value != null && key != null){
      final SharedPreferences prefs = await SharedPreferences.getInstance();
       var jsonString = json.encode(value);
      await prefs.setString(key, jsonString);
    }
  }

  static Future removeValue(String key) async{
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
  }
}