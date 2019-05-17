
import 'package:connectivity/connectivity.dart';
import 'dart:async';
 
class Conectivity{
    Conectivity._();
    static Future<bool> isNetworkAvilable() async {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.mobile) {
          // I am connected to a mobile network.
          return true;
        } else if (connectivityResult == ConnectivityResult.wifi) {
          // I am connected to a wifi network.
          return true;
        }else if (connectivityResult == ConnectivityResult.none) {
          return false;
        } else {
          return false;
        }
    }
}