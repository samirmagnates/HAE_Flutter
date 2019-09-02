import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../Utils/AppUtils.dart';
import '../Model/Assessment.dart';
import '../Utils/apimanager.dart';
import '../Utils/DbManager.dart';
import 'package:contacts_service/contacts_service.dart';
//import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:hea/Screen/StartAssessment.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hea/Model/AssessmentTasks.dart';
import 'package:hea/Model/AssessmentMetaData.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path/path.dart' as path;
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  DeviceCalendarPlugin _deviceCalendarPlugin;
  static final GlobalKey<ScaffoldState> _scaffoldKeyHome = new GlobalKey<ScaffoldState>();
  
  Assessment assessmentSelected;
  //bool _isLoading = true;
  bool _isError = false;
  bool _isAddToDeviceTapped = false;
  bool _isDownloadTapped = false;
  bool _isStartAssessmentTapped = false;
  bool _isDeleteTap = false;

  int needTouploadFileCount = 0;
  int uploadFileCount = 0;

  String noDataMessage = '';

  final _loadingStreamController = StreamController<bool>.broadcast();

  var errorMessage = AppMessage.kError_SomethingWentWrong;
  List<Assessment> arrAssessments;
  String appUserToken;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _deviceCalendarPlugin = new DeviceCalendarPlugin();
    getAessessment();
  }

    getBasicRequireParameters() async {
      appUserToken = await AppUtils.getAppUserToken() ;
      await PermissionHandler().requestPermissions([PermissionGroup.calendar,PermissionGroup.contacts]);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyHome,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
                    AppConstant.kHeader_Skill,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: ThemeFont.font_pourceSanPro,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0),
                  ),
        actions: <Widget>[
          IconButton(
          iconSize: 20,
          icon: Image.asset(ThemeImage.image_delete),
          //onPressed: () => _isDeleteTap?null:_performDeletAction(),
          onPressed: () async{
            //if(_isLoading == false){
              if(_isDeleteTap == false)  {
              //await _performDeletAction();
               await DBManager.db.clearDataBase(this.assessmentSelected.ASSESSOR_UUID);
               AppUtils.onPrintLog("pop  >> 1");
                Navigator.of(context).pop();
              } 
            //} 
            
          },
          )
        ],
        leading: IconButton(
          padding: EdgeInsets.all(12.0),
          icon: Image.asset(ThemeImage.image_logout),
          onPressed: (){
            //if(_isLoading == false){
              _showLogoutAlert(context);
            //}
            
          },
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: widgetHomeScreen(),
      ),
      bottomNavigationBar:this.assessmentSelected != null?SafeArea(
        bottom: true,
        child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: this.assessmentSelected.IS_DOWNLOADED == 1?ThemeColor.theme_blue:Colors.grey
        ),
        child: FlatButton(
          onPressed: () => _isStartAssessmentTapped?null:this.assessmentSelected.IS_END == 1?_uploadAssessment():_startAssessment(),
          child: Center(
            child: Text(
                this.assessmentSelected.IS_END == 1?AppConstant.kTitle_UploadAssessment:AppConstant.kTitle_StartAssessment,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: ThemeFont.font_pourceSanPro,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0),
              ),
          ),
        ),
      ),
      ):SizedBox(
        width: 0.0,
        height: 0.0,
      ),
    );
  }

  _performDeletAction()async{
    // setState(() {
    //       _isLoading = true;
    //       _isDeleteTap = true;
    // });

    _isDeleteTap = true;
    _loadingStreamController.sink.add(true);

    for (int i = 0; i < this.arrAssessments.length; i++){
        Assessment can = this.arrAssessments[i];
        await _deleteContact(can);
        await _deleteCalenderEvent(can);
    }
  }

  Widget widgetNoDataFount(){
    return Center(
      child: Text(
            noDataMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: ThemeFont.font_pourceSanPro,
                color: ThemeColor.theme_dark,
                fontWeight: FontWeight.w400,
                fontSize: 20.0
          ),
        ),
      );
  }

  Widget widgetHomeScreen() {
    return Stack(
        children: <Widget>[
          this.assessmentSelected != null ?widgetHomePage() : widgetNoDataFount(),
          //_isLoading?AppUtils.onShowLoder() : SizedBox(height: 0.0, width: 0.0,),
          StreamBuilder(
            stream: _loadingStreamController.stream,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot){
              if(snapshot.hasData){
                if(snapshot.data == true){
                  return AppUtils.onShowLoder();
                }else {
                 return SizedBox(height: 0.0, width: 0.0,);
                }
              } else {
                return SizedBox(height: 0.0, width: 0.0);
              }

            },
          )
         ],
      );
  }

  Widget widgetHomePage(){
    return Container(
        child : Padding(
          padding: EdgeInsets.only(left: 30,right: 30,top: 30),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Text(
                      AppConstant.kTitle_Assessment,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: ThemeFont.font_pourceSanPro,
                          color: ThemeColor.theme_blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1.0,style: BorderStyle.solid),
                          borderRadius: BorderRadius.all(Radius.circular(5.0))
                        )
                      ),
                      child:Stack(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: 50,
                                  width: 50,
                                  child: Center(
                                    child: Container(
                                      height: 15,
                                      width: 15,
                                      child: Image.asset(ThemeImage.image_drowDownArrow),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ),
                          Container(
                              decoration: BoxDecoration(
                              ),
                              child:FlatButton(
                                onPressed: (){
                                  //if(_isLoading == false){
                                    _showCandidatePicker(context);
                                  //} 
                                  
                                },
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text('${this.assessmentSelected.ASSESSMENT_CANDIDATE_FIRST} ${this.assessmentSelected.ASSESSMENT_CANDIDATE_LAST}',
                                      style: TextStyle(
                                        fontFamily: ThemeFont.font_pourceSanPro,
                                        color: ThemeColor.theme_dark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0
                                      ),
                                  ),
                                ),
                              )
                            ),
                        ],
                      )
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ]
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0))
                        ),
                        color: ThemeColor.theme_grey
                      ),
                      child: ListView(
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        shrinkWrap: true,
                        children: <Widget>[
                          SizedBox(
                           height: 10,
                          ),
                          Text(
                            AppConstant.kTitle_Assessment_Details,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: ThemeFont.font_pourceSanPro,
                                color: ThemeColor.theme_blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0),
                          ),
                          SizedBox(
                           height: 20,
                          ),
                          Text(
                            'Title: ${this.assessmentSelected.ASSESSMENT_TITLE}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: ThemeFont.font_pourceSanPro,
                                color: ThemeColor.theme_dark,
                                fontWeight: FontWeight.w400,
                                fontSize: 20.0),
                          ),
                          SizedBox(
                           height: 20,
                          ),
                          Text(
                            '${this.assessmentSelected.ASSESSMENT_ADDRESS_ADDRESS1}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: ThemeFont.font_pourceSanPro,
                                color: ThemeColor.theme_dark,
                                fontWeight: FontWeight.w400,
                                fontSize: 20.0),
                          ),
                          this.assessmentSelected.ASSESSMENT_ADDRESS_ADDRESS2 != null && this.assessmentSelected.ASSESSMENT_ADDRESS_ADDRESS2 != ''?
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  '${this.assessmentSelected.ASSESSMENT_ADDRESS_ADDRESS2}',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: ThemeFont.font_pourceSanPro,
                                      color: ThemeColor.theme_dark,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20.0),
                                ),
                              ],
                            ):SizedBox(
                           height: 0,
                          ),
                          SizedBox(
                           height: 2,
                          ),
                          Text(
                            'Town: ${this.assessmentSelected.ASSESSMENT_ADDRESS_TOWNCITY}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: ThemeFont.font_pourceSanPro,
                                color: ThemeColor.theme_dark,
                                fontWeight: FontWeight.w400,
                                fontSize: 20.0),
                          ),
                          SizedBox(
                           height: 2,
                          ),
                          Text(
                            'County: ${this.assessmentSelected.ASSESSMENT_ADDRESS_COUNTY}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: ThemeFont.font_pourceSanPro,
                                color: ThemeColor.theme_dark,
                                fontWeight: FontWeight.w400,
                                fontSize: 20.0),
                          ),
                          SizedBox(
                           height: 2,
                          ),
                          Text(
                            'Post Code : ${this.assessmentSelected.ASSESSMENT_ADDRESS_POSTCODE}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: ThemeFont.font_pourceSanPro,
                                color: ThemeColor.theme_dark,
                                fontWeight: FontWeight.w400,
                                fontSize: 20.0),
                          ),
                          SizedBox(
                           height: 2,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Date: ${this.assessmentSelected.ASSESSMENT_APPOINTMENT_DATE}',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontFamily: ThemeFont.font_pourceSanPro,
                                    color: ThemeColor.theme_dark,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20.0),
                              ),
                              Text(
                                'Time: ${this.assessmentSelected.ASSESSMENT_APPOINTMENT_TIME}',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontFamily: ThemeFont.font_pourceSanPro,
                                    color: ThemeColor.theme_dark,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20.0),
                              ),
                            ],
                          ),
                          SizedBox(
                           height: 2,
                          ),
                          Text(
                            'Email: ${this.assessmentSelected.ASSESSMENT_CANDIDATE_EMAIL}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: ThemeFont.font_pourceSanPro,
                                color: ThemeColor.theme_dark,
                                fontWeight: FontWeight.w400,
                                fontSize: 20.0),
                          ),
                          SizedBox(
                           height: 2,
                          ),
                          Text(
                            'Telephone: ${this.assessmentSelected.ASSESSMENT_CANDIDATE_NUMBER}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: ThemeFont.font_pourceSanPro,
                                color: ThemeColor.theme_dark,
                                fontWeight: FontWeight.w400,
                                fontSize: 20.0),
                          ),
                          SizedBox(
                           height: 10,
                          ),
                        ],
                      ),
                    ),
                  ]
                )
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              this.assessmentSelected.IS_ADD_CALENDER == 0 || this.assessmentSelected.IS_ADD_CONTACT == 0 ? Expanded(child:
                                Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Container(
                                  height: 50,
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                                    ),
                                    color: ThemeColor.theme_blue,
                                  ),
                                  child: FlatButton(
                                    onPressed: (){
                                      //if(_isLoading == false){
                                        if(_isAddToDeviceTapped == false){
                                          _addToDevice();
                                        }
                                      //}
                                    },
                                    /*onPressed: () => _isAddToDeviceTapped?null:({
                                      if(_isLoading == false){
                                        _addToDevice()
                                      }
                                       
                                    }),*/
                                    child: Center(
                                      child: Text(
                                          AppConstant.kTitle_AddToDevice,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: ThemeFont.font_pourceSanPro,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                    ),
                                  ),
                                ),
                                )
                                
                              ):SizedBox(),
                              this.assessmentSelected.IS_DOWNLOADED == 0?Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Container(
                                  height: 50,
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                                    ),
                                    color: ThemeColor.theme_blue,
                                  ),
                                  child: FlatButton(
                                    onPressed: (){
                                      //if(_isLoading == false){
                                        if(_isDownloadTapped == false){
                                          _downloadAssessment();
                                        }
                                      //}
                                    },
                                    /*onPressed: () => _isDownloadTapped?null:({
                                        if(_isLoading == false){
                                        _downloadAssessment()
                                        } 
                                    }),*/
                                    child: Center(
                                      child: Text(
                                          AppConstant.kTitle_Download,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: ThemeFont.font_pourceSanPro,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                    ),
                                  ),
                                ),
                                )
                              ):SizedBox(),
                            ],
                          ),
                          
                    ),
                  ]
                )
              )
            ],
          )
          )
        
    );
  }

  void getAessessment() async {
    getBasicRequireParameters();
    
    var assessorUUID = await AppUtils.getAssessorUUID() as String;

    if (assessorUUID != null && assessorUUID != ''){
      if(await AppUtils.isNetwrokAvailabe(context) == true){
        // setState(() {
        //     _isLoading = true;
        // });

        _loadingStreamController.sink.add(true);
        
        Map body = {
          AppKey.param_assessor_uuid:assessorUUID
        };

        var response =  await APIManager().httpRequest(APIType.private,APIMathods.getAssessments,body) as Map;
        var data;
        if(response != null){
            AppUtils.onPrintLog("response >> $response");
            if(response[ApiResponsKey.success] == true){
              if(response[ApiResponsKey.data] != null){
                data = response[ApiResponsKey.data];
                Iterable list = data;
                //matchData = list.map((model) => Match.fromJson(model)).toList();
                this.arrAssessments = list.map((model) => Assessment.fromJSON(model)).toList();
                if(this.arrAssessments.length > 0){
                    Assessment candidate = this.arrAssessments.first;
                    //await DBManager.db.performAssessmetnsAction(candidate);

                    var res = await DBManager.db.checkAssessementsExists(candidate);
                    if (res.isEmpty){
                      await DBManager.db.insertAssessmetns(candidate);
                    } 
                    var response =  await DBManager.db.getAssessements(candidate.ASSESSMENT_UUID,candidate.ASSESSOR_UUID);
                    setState(()  {
                      this.assessmentSelected = response != null?response as Assessment:null;
                      if(this.assessmentSelected != null){
                           updateCandidateList();
                      }

                    });
                } else {
                   setState(() {
                      noDataMessage = 'No data found';
                    });
                }
              }
            }else {
              if(response[ApiResponsKey.error] != null){
                  _isError = true;
                  Map error = response[ApiResponsKey.error];
                  if(error[ApiResponsKey.message] != null){
                    errorMessage = error[ApiResponsKey.message];
                  }
                  if(_isError == true){
                    AppUtils.showInSnackBar(_scaffoldKeyHome, errorMessage);
                  }
              }
              setState(() {
                      noDataMessage = 'No data found';
              });
            }
        }
        /*setState(() {
          AppUtils.onPrintLog("_isLoading >> 4");
            _isLoading = false;
        });*/
        _loadingStreamController.sink.add(false);
        if(data != null){
          //Navigator.of(context).pushNamed(AppRoute.routeHomeScreen);
        }
      } else {
          // setState(() {
          //   AppUtils.onPrintLog("_isLoading >> 5");
          //   _isLoading = false;
          // });
          _loadingStreamController.sink.add(false);
          _isError = true;
          if(_isError == true){
            AppUtils.showInSnackBar(_scaffoldKeyHome,AppMessage.kError_NoInternet);
          }
      }
    } else {

        AppUtils.showInSnackBar(_scaffoldKeyHome, errorMessage);
        _loadingStreamController.sink.add(false);
        setState(() {
          AppUtils.onPrintLog("_isLoading >> 6");
            //_isLoading = false;
            this.assessmentSelected = null;
          });
        
    }
  }
  

  void logout() async{
    
  if (appUserToken != null && appUserToken.isNotEmpty){
      if(await AppUtils.isNetwrokAvailabe(context) == true){
        // setState((){
        //     _isLoading = true;
        // });
        _loadingStreamController.sink.add(true);
        AppUtils.onShowLoder();
        Map body = {
          AppKey.param_appuser_token:appUserToken
        };

        var response =  await APIManager().httpRequest(APIType.public,APIMathods.logout,body) as Map;
        var data;
        if(response != null){
            AppUtils.onPrintLog("response >> $response");
  
            if(response[ApiResponsKey.success] == true){
              AppUtils.onPrintLog("pop  >> 2");
                Navigator.of(context).popUntil((route) => route.isFirst);
            }else {
              if(response[ApiResponsKey.error] != null){
                  _isError = true;
                  Map error = response[ApiResponsKey.error];
                  if(error[ApiResponsKey.message] != null){
                    errorMessage = error[ApiResponsKey.message];
                  }
                  if(_isError == true){
                    AppUtils.showInSnackBar(_scaffoldKeyHome, errorMessage);
                  }
                }
            }
        }
        // setState((){
        //   AppUtils.onPrintLog("_isLoading >> 7");
        //   _isLoading = false;
        // });
        _loadingStreamController.sink.add(false);
        if(data != null){
          //Navigator.of(context).pushNamed(AppRoute.routeHomeScreen);
        }
      } else {
          _isError = true;
          if(_isError == true){
            AppUtils.showInSnackBar(_scaffoldKeyHome,AppMessage.kError_NoInternet);
          }
      }
    } else {
        AppUtils.showInSnackBar(_scaffoldKeyHome, errorMessage);
    }
  }

  void _showLogoutAlert(BuildContext context) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Logout"),
            content: Text(AppMessage.kMsg_Logout),
            actions: <Widget>[
              FlatButton(
                child: new Text("Cancel"),
                onPressed: () {
                  //if(_isLoading == false){
                    AppUtils.onPrintLog("pop  >> 3");
                    Navigator.of(context).pop();
                  //}
                  
                },
              ),
              FlatButton(
                child: new Text("Logout"),
                onPressed: () {
                  //if(_isLoading == false){
                    AppUtils.onPrintLog("pop  >> 4");
                    Navigator.of(context).pop();
                    logout();
                  //}
                  
                },
              ),
            ],
          )
      );
    }

    void _showCandidatePicker(BuildContext context) async{

      

       final result = await showDialog(
          context: context,
          builder: (context) => SearchCandidateView(arrAssessments:this.arrAssessments,currentAssessment:this.assessmentSelected)
      );

      if(result != null){
          Assessment candidate = result as Assessment;
          //await DBManager.db.performAssessmetnsAction(candidate);
          var res = await DBManager.db.checkAssessementsExists(candidate);
          if (res.isEmpty){
            await DBManager.db.insertAssessmetns(candidate);
          } 
          var response =  await DBManager.db.getAssessements(candidate.ASSESSMENT_UUID,candidate.ASSESSOR_UUID);
          setState(() {
            this.assessmentSelected = response != null?response as Assessment:null;
            if(this.assessmentSelected != null){
               updateCandidateList();
            }
          });
      }
    }

    Future _addToDevice() async {
        // setState(() {
        //   _isLoading = true;
        //   _isAddToDeviceTapped = true;
        // });
        _isAddToDeviceTapped = true;
        _loadingStreamController.sink.add(true);
        
        //var isContactAdd = SharedPreferencesManager.getValue('${AppKey.key_isContactAdd}-${this.assessmentSelected.ASSESSMENT_ID}');
        int isContactAdd = this.assessmentSelected.IS_ADD_CONTACT;
        if(isContactAdd == null || isContactAdd ==  0){
            if(this.assessmentSelected.ASSESSMENT_CANDIDATE_NUMBER != null && this.assessmentSelected.ASSESSMENT_CANDIDATE_NUMBER != ''){
              await _addToContact();
            }
        }
        
        
        //var isCalenderEventAdded = SharedPreferencesManager.getValue('${AppKey.key_isCalenterEventAdd}-${this.assessmentSelected.ASSESSMENT_ID}');
        int isCalenderEventAdded = this.assessmentSelected.IS_ADD_CALENDER;
        String strAddCalender = 'false';
        if(isCalenderEventAdded == null || isCalenderEventAdded == 0){
           if(this.assessmentSelected.ASSESSMENT_APPOINTMENT != null && this.assessmentSelected.ASSESSMENT_APPOINTMENT != ''){
              await _addToCalender();
            }
        }

        
        if(isContactAdd == 1 && isCalenderEventAdded == 1 ){
            AppUtils.showInSnackBar(_scaffoldKeyHome,'Already added to device');
        }
        
        // setState(() {
        //   AppUtils.onPrintLog("_isLoading >> 8");
        //   _isLoading = false;
        //   _isAddToDeviceTapped = false;
        // });
        _isAddToDeviceTapped = false;
        _loadingStreamController.sink.add(false);
    }

    Future _addToContact() async {

        Map<PermissionGroup, PermissionStatus> permissionRequestResult = await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
        PermissionStatus _permissionStatus = permissionRequestResult[PermissionGroup.contacts];

        if(_permissionStatus == PermissionStatus.granted){
            Contact newContct = Contact();
            newContct.displayName = this.assessmentSelected.ASSESSMENT_CANDIDATE_FIRST + ' ' + this.assessmentSelected.ASSESSMENT_CANDIDATE_LAST;
            newContct.givenName = this.assessmentSelected.ASSESSMENT_CANDIDATE_FIRST;
            newContct.familyName = this.assessmentSelected.ASSESSMENT_CANDIDATE_LAST;
             PostalAddress address = PostalAddress();
            address.label = '${this.assessmentSelected.ASSESSMENT_ADDRESS_ADDRESS1}';
            address.street = '${this.assessmentSelected.ASSESSMENT_ADDRESS_ADDRESS2}';
            address.city = '${this.assessmentSelected.ASSESSMENT_ADDRESS_TOWNCITY}';
            address.postcode = '${this.assessmentSelected.ASSESSMENT_ADDRESS_POSTCODE}';
            address.region = '${this.assessmentSelected.ASSESSMENT_ADDRESS_COUNTY}';
            address.country = '${this.assessmentSelected.ASSESSMENT_ADDRESS_COUNTRY}';
            
            newContct.postalAddresses = [address];//list;
            
            newContct.company = this.assessmentSelected.ASSESSMENT_ADDRESS_COMPANY;
            newContct.emails = [Item(label: 'email',value: this.assessmentSelected.ASSESSMENT_CANDIDATE_EMAIL)];
            newContct.phones = [Item(label: 'phone',value: this.assessmentSelected.ASSESSMENT_CANDIDATE_NUMBER)];

            try{
              await ContactsService.addContact(newContct);
              var allContacts = await ContactsService.getContacts();
              var filtered = allContacts.where((c) => c.phones.any((phone) => phone.value.contains("${this.assessmentSelected.ASSESSMENT_CANDIDATE_NUMBER}"))).toList();

              AppUtils.onPrintLog('calender >>> ${filtered.first.identifier}');
              this.assessmentSelected.IS_ADD_CONTACT = 1;
              this.assessmentSelected.CONTACT_ID = filtered.first.identifier;
              var res = await DBManager.db.checkAssessementsExists(this.assessmentSelected);
              if (res.isNotEmpty){
                await DBManager.db.updateAssessmetns(this.assessmentSelected);
                await updateCandidateList();
              } 


            } on PlatformException catch(e){
              openPermisionPopupBox('Contact ${e.message}','Enable contact service for application form setting');
              //AppUtils.showInSnackBar(_scaffoldKey,'Contact ${e.message}');
            }
        } else {
            openPermisionPopupBox('Contact Access Denie','Enable contact service for application form setting');
        }
    }

    Future _deleteContact(Assessment asseesment) async {

      if (asseesment.IS_ADD_CONTACT == 1){
            Map<PermissionGroup, PermissionStatus> permissionRequestResult = await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
            PermissionStatus _permissionStatus = permissionRequestResult[PermissionGroup.contacts];
            if(_permissionStatus == PermissionStatus.granted){
                try{
                  //var contact = await ContactsService.getContacts(query: 'identifier:${candidate.CONTACT_ID}');
                  var allContacts = await ContactsService.getContacts();
                  var filtered = allContacts.where((c) => c.identifier.contains("${asseesment.CONTACT_ID}")).toList();
                  AppUtils.onPrintLog('calender >>> $filtered');
                  await ContactsService.deleteContact(filtered.first);
                } on PlatformException catch(e){
                  //openPermisionPopupBox('Contact ${e.message}','Enable contact service for application form setting');
                  AppUtils.showInSnackBar(_scaffoldKeyHome,'Contact delete ${e.message}');
                }
            } else {
                //openPermisionPopupBox('Contact Access Denie','Enable contact service for application form setting');
            }
        }
    }

    

    Future _deleteCalenderEvent(Assessment assessment) async {

      if (assessment.IS_ADD_CALENDER == 1){
            Map<PermissionGroup, PermissionStatus> permissionRequestResult = await PermissionHandler().requestPermissions([PermissionGroup.calendar]);
            PermissionStatus _permissionStatus = permissionRequestResult[PermissionGroup.calendar];
            if(_permissionStatus == PermissionStatus.granted){
                final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
                Calendar calendar = calendarsResult.data.first;
                var createEventResult = await _deviceCalendarPlugin.deleteEvent(calendar.id, assessment.CALENDER_ID);
                if (createEventResult.isSuccess) {
                    AppUtils.onPrintLog('calender >>> $createEventResult');
                } else {
                  AppUtils.onPrintLog('calender error >>> ${createEventResult.errorMessages.join(' | ')}');
                }
            } else {
                 //openPermisionPopupBox('Calender Access Denie','Enable calender service for application form setting');
            }
        }

      

    }
    updateCandidateList() async{

      for (int i = 0; i < this.arrAssessments.length; i++){
        Assessment can = this.arrAssessments[i];
        if (can.ASSESSMENT_ID == this.assessmentSelected.ASSESSMENT_ID){
            this.arrAssessments[i] = this.assessmentSelected;
            break;
        }
      }
    }

    Future _addToCalender() async {
      
      Map<PermissionGroup, PermissionStatus> permissionRequestResult = await PermissionHandler().requestPermissions([PermissionGroup.calendar]);
      PermissionStatus _permissionStatus = permissionRequestResult[PermissionGroup.calendar];
      if(_permissionStatus == PermissionStatus.granted){
          String candidateFullName = this.assessmentSelected.ASSESSMENT_CANDIDATE_FIRST + ' ' + this.assessmentSelected.ASSESSMENT_CANDIDATE_LAST;
          DateTime startDate  = DateTime.parse(this.assessmentSelected.ASSESSMENT_APPOINTMENT);
          DateTime endDate  = startDate.add(Duration(hours: 1));

          final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();

          Calendar calendar = calendarsResult.data.first;
          String eventTitle = '$candidateFullName  assessment  of ${this.assessmentSelected.ASSESSMENT_TITLE}';
          Event event = Event(calendar.id,title: eventTitle,start: startDate,end: endDate);

          var createEventResult = await _deviceCalendarPlugin.createOrUpdateEvent(event);

          if (createEventResult.isSuccess) {

              AppUtils.onPrintLog('calender >>> ${event.eventId}');
              AppUtils.onPrintLog('calender >>> $createEventResult');
              //var getEventResult = await _deviceCalendarPlugin.retrieveEvents(calendar.id, RetrieveEventsParams(startDate: startDate, endDate: endDate));
              this.assessmentSelected.IS_ADD_CALENDER = 1;
              if(createEventResult.data.isNotEmpty){
                  this.assessmentSelected.CALENDER_ID = createEventResult.data;
              }
              /*for(int i = 0; i < getEventResult.data.length; i++){
                  Event eve = getEventResult.data[i] ;
                  if(eve.title == eventTitle && eve.start == startDate && eve.end == endDate){
                    this.assessmentSelected.CALENDER_ID = eve.eventId;
                    break;
                  }
              }*/
              
              var res = await DBManager.db.checkAssessementsExists(this.assessmentSelected);
              if (res.isNotEmpty){
                await DBManager.db.updateAssessmetns(this.assessmentSelected);
                await updateCandidateList();
              } 

          } else {
            AppUtils.onPrintLog('calender error >>> ${createEventResult.errorMessages.join(' | ')}');
            
          }
        
      } else {
        openPermisionPopupBox('Calender Access Denie','Enable calender service for application form setting');
      }
      
      

    }

    Widget openPermisionPopupBox(String title, String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 0.0),
            content: Container(
              width: 300.0,
              height: 220.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: ThemeColor.theme_blue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32.0),
                            topRight: Radius.circular(32.0)),
                      ),
                      child: Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: ThemeFont.font_pourceSanPro,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.center,
                              ),
                    ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0,top: 10.0),
                    child:Center(
                      child:Text(
                                message,
                                style: TextStyle(
                                  color: ThemeColor.theme_dark,
                                  fontFamily: ThemeFont.font_pourceSanPro,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.center,
                              ),
                    ),
                  ),
                  Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          color: ThemeColor.theme_blue,
                        ),
                        child: FlatButton(
                          onPressed: ()  {
                            //if(_isLoading == false){
                              AppUtils.onPrintLog("pop  >> 5");
                              Navigator.of(context).pop();
                            //}
                          },
                          child: Center(
                            child: Text(
                                'Ok',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: ThemeFont.font_pourceSanPro,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0),
                              ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          );
        });
  }

  void _downloadAssessment() async {
      if(this.assessmentSelected.IS_DOWNLOADED == 0){
          // setState((){
          //     _isLoading = true;
          //     _isDownloadTapped = true;
          // });
          _isDownloadTapped = true;
          _loadingStreamController.sink.add(true);

          if(this.assessmentSelected.ASSESSMENT_UUID != null && this.assessmentSelected.ASSESSMENT_UUID.isNotEmpty){
            if(await AppUtils.isNetwrokAvailabe(context) == true){
              
              AppUtils.onShowLoder();
              Map body = {
                AppKey.param_assessment_uuid:this.assessmentSelected.ASSESSMENT_UUID
              };

              var response =  await APIManager().httpRequest(APIType.private,APIMathods.downloadAssessment,body) as Map;
              var data;
              if(response != null){
                  AppUtils.onPrintLog("response >> $response");
        
                  if(response[ApiResponsKey.success] == true){
                    if(response[ApiResponsKey.data] != null){
                      data = response[ApiResponsKey.data];
                    }
                      
                  }else {
                    if(response[ApiResponsKey.error] != null){
                        _isError = true;
                        Map error = response[ApiResponsKey.error];
                        if(error[ApiResponsKey.message] != null){
                          errorMessage = error[ApiResponsKey.message];
                        }
                        if(_isError == true){
                          AppUtils.showInSnackBar(_scaffoldKeyHome, errorMessage);
                        }
                      }
                  }
              }
              
              if(data != null){
                  if(data['assessment_meta'] != null){
                    Map meta = data['assessment_meta'];
                    AssessmentMetaData  metadate = AssessmentMetaData.fromJSON(meta);

                    var res = await DBManager.db.checkAssessementsMetaDataExists(metadate);
                    if (res.isEmpty){
                      await DBManager.db.insertAssessmetnsMetaData(metadate);
                    } 

                  }

                  if(data['assessment_tasks'] != null){
                    Iterable list = data['assessment_tasks'];
                    AppUtils.onPrintLog("assessment_tasks >> $list");
                    List<AssessmentTasks> arrAssessmentTask = list.map((model) => AssessmentTasks.fromJSON(model)).toList();
                    if(arrAssessmentTask.length > 0){

                        await addAssessmentTaskToDb(arrAssessmentTask);
                        this.assessmentSelected.IS_DOWNLOADED = 1;
                        var res = await DBManager.db.checkAssessementsExists(this.assessmentSelected);
                        if (res.isNotEmpty){
                          await DBManager.db.updateAssessmetns(this.assessmentSelected);
                          await updateCandidateList();
                        } 
                    } 
                  }
              }
              setState((){
                AppUtils.onPrintLog("_isLoading >> 9");
                //_isLoading = false;
                _isDownloadTapped = false;
              });
              //_isDownloadTapped = false;
              _loadingStreamController.sink.add(false);
            } else {
                _isError = true;
                if(_isError == true){
                  AppUtils.showInSnackBar(_scaffoldKeyHome,AppMessage.kError_NoInternet);
                }
            }

          } else {
            // setState((){
            //   AppUtils.onPrintLog("_isLoading >> 10");
            //       _isLoading = false;
            //       _isStartAssessmentTapped = false;
            //   });
              _isStartAssessmentTapped = false;
              _loadingStreamController.sink.add(false);
            AppUtils.showInSnackBar(_scaffoldKeyHome, AppMessage.kError_NoAssessment);
          }
      } else {
          AppUtils.showInSnackBar(_scaffoldKeyHome, AppMessage.kError_DownloadAlready);
      }
  }

    Future addAssessmentTaskToDb(List<AssessmentTasks>  arrAssessmentTask) async {
      arrAssessmentTask.forEach((task) async {
        var res = await DBManager.db.checkAssessementsTaskExists(task,this.assessmentSelected.ASSESSMENT_UUID,this.assessmentSelected.ASSESSOR_UUID);
          AppUtils.onPrintLog('addAssessmentTaskToDb >> $res');
          if (res.isEmpty){
            await DBManager.db.insertAssessmetnsTask(task,this.assessmentSelected.ASSESSMENT_UUID,this.assessmentSelected.ASSESSOR_UUID);
          } 
      });
    }

    setManifestFile(String assessmentUdid,List<AssessmentTasks> taskList) async {

        Map<String,dynamic> data = Map<String,dynamic>();
        Map<String,dynamic> assessment_meta = Map<String,dynamic>();
        assessment_meta['assessment_uuid'] = assessmentUdid;
        List<Map <String,dynamic>> assessment_files = List<Map <String,dynamic>>();

        for( AssessmentTasks task in taskList){
          //AssessmentTasks task = taskList[index];
          if(task.assessmentTaskLocalFile.isNotEmpty) {
            String docDirectory = await AppUtils.getDocumentPath();
            String fileFullPath = '$docDirectory/${task.assessmentTaskLocalFile}';
          
            final File file =  File(fileFullPath);
            String fileName = path.basename(file.path);
            int fileSize = await getFileSize(fileFullPath);
            AppUtils.onPrintLog('File fileSize-->$fileSize');
            
            Map<String,dynamic> file_info = Map<String,dynamic>();
            file_info['assessment_task_uuid'] = task.assessmentTaskUuid;
            file_info['assessment_task_upload_filesize'] = '${fileSize.toString()}';
            file_info['assessment_task_upload_filename'] = fileName;
            assessment_files.add(file_info);
          }
          
          
        }
       
        if(assessment_files.length > 0){
          data['assessment_meta'] = assessment_meta;
          data['assessment_files'] = assessment_files;
          String json = jsonEncode(data);
          AppUtils.onPrintLog("json >> $json");


          if(this.assessmentSelected.ASSESSMENT_UUID != null && this.assessmentSelected.ASSESSMENT_UUID.isNotEmpty){
            if(await AppUtils.isNetwrokAvailabe(context) == true){
              
              Map body = {
                AppKey.param_rawJson:json
              };

              var setResponse =  await APIManager().httpRequest(APIType.private,APIMathods.setManifest,body) as Map;
              AppUtils.onPrintLog("setResponse >> $setResponse");
              getManifestFile(this.assessmentSelected.ASSESSMENT_UUID);
              
              
            } else {

                _isError = true;
                if(_isError == true){
                  AppUtils.showInSnackBar(_scaffoldKeyHome,AppMessage.kError_NoInternet);
                }
              //   setState((){
              //   AppUtils.onPrintLog("_isLoading >> 15");
              //   _isLoading = false;
              //   _isStartAssessmentTapped = false;
              // });
              _isStartAssessmentTapped = false;
              _loadingStreamController.sink.add(false);
              return null;
            }

          } else {
            // setState((){
            //     AppUtils.onPrintLog("_isLoading >> 16");
            //     _isLoading = false;
            //     _isStartAssessmentTapped = false;
            //   });
              _isStartAssessmentTapped = false;
              _loadingStreamController.sink.add(false);
            AppUtils.showInSnackBar(_scaffoldKeyHome, AppMessage.kError_NoAssessment);
            return null;
          }
        } else {
          uploadTaskResult();
        }
        
        
    }

    getManifestFile(String assessmentUdid) async {
        if(await AppUtils.isNetwrokAvailabe(context) == true){
            Map body = {
              AppKey.param_assessment_uuid:assessmentUdid
            };

            var getManifestResponse =  await APIManager().httpRequest(APIType.private,APIMathods.getManifest,body) as Map;
            AppUtils.onPrintLog("getManifestResponse >> $getManifestResponse");
            var data;
            if(getManifestResponse != null){
                AppUtils.onPrintLog("getManifestResponse >> $getManifestResponse");
      
                if(getManifestResponse[ApiResponsKey.success] == true){
                  if(getManifestResponse[ApiResponsKey.data] != null){
                    data = getManifestResponse[ApiResponsKey.data];
                  }
                    
                }else {
                  if(getManifestResponse[ApiResponsKey.error] != null){
                      _isError = true;
                      Map error = getManifestResponse[ApiResponsKey.error];
                      if(error[ApiResponsKey.message] != null){
                        errorMessage = error[ApiResponsKey.message];
                      }
                      if(_isError == true){
                        AppUtils.showInSnackBar(_scaffoldKeyHome, errorMessage);
                      }
                    } 
                }
            }
          
            if(data != null){
              if(data['assessment_meta'] != null){
                Map meta = data['assessment_meta'];
                String status = meta['assessment_files_upload_status'] as String;

                if(status != 'Complete'){
                      
                  if(data['assessment_files_status'] != null){
                    List<dynamic> list = data['assessment_files_status'];
                    
                    for( dynamic fileStatus in list){
                      //AssessmentTasks task = taskList[index];
                      String status = fileStatus['assessment_task_file_status'] as String;
                      if(status != null && status != '' && status != 'OK') {
                        needTouploadFileCount++;
                        AppUtils.onPrintLog("needTouploadFileCount++");
                        uploadManifestFile(fileStatus);
                      }
                    }
                    AppUtils.onPrintLog("needTouploadFileCount >> $needTouploadFileCount");
                    if(needTouploadFileCount == 0){
                      AppUtils.showInSnackBar(_scaffoldKeyHome,AppMessage.kError_UploadedAlready);
                      // setState((){
                      //   AppUtils.onPrintLog("_isLoading >> 18");
                      //   _isLoading = false;
                      //   _isStartAssessmentTapped = false;
                      // });
                      _isStartAssessmentTapped = false;
                      _loadingStreamController.sink.add(false);
                    }
                  }
                } else {
                  AppUtils.showInSnackBar(_scaffoldKeyHome,AppMessage.kError_UploadedAlready);
                  // setState((){
                  //   AppUtils.onPrintLog("_isLoading >> 118");
                  //   _isLoading = false;
                  //   _isStartAssessmentTapped = false;
                  // });
                  _isStartAssessmentTapped = false;
                  _loadingStreamController.sink.add(false);
                }
              }
            }else {
            //   setState((){
            //   AppUtils.onPrintLog("_isLoading >> 188");
            //   _isLoading = false;
            //   _isStartAssessmentTapped = false;
            // });
              _isStartAssessmentTapped = false;
              _loadingStreamController.sink.add(false);
            }
            
          } else {
            //   setState((){
            //   AppUtils.onPrintLog("_isLoading >> 17");
            //   _isLoading = false;
            //   _isStartAssessmentTapped = false;
            // });
              _isStartAssessmentTapped = false;
              _loadingStreamController.sink.add(false);
              _isError = true;
              if(_isError == true){
                AppUtils.showInSnackBar(_scaffoldKeyHome,AppMessage.kError_NoInternet);
              }
            return null;
          }
        
        
    }

    uploadTaskResult() async{
        AssessmentMetaData resMetadata = await DBManager.db.getAssessementsMetaData(this.assessmentSelected.ASSESSMENT_UUID, this.assessmentSelected.ASSESSOR_UUID);
        List<AssessmentTasks> taskList = await DBManager.db.getAllAssessementsTasks(this.assessmentSelected.ASSESSMENT_UUID, this.assessmentSelected.ASSESSOR_UUID);
        Map<String,dynamic> data = Map<String,dynamic>();
        String comment = resMetadata.assessmentComment;
        bool isPanding = false;
        if(resMetadata.assessmentPending == true){
          isPanding = true;
        }
        Map<String,dynamic> assessment_meta = Map<String,dynamic>();
        assessment_meta['assessment_uuid'] = this.assessmentSelected.ASSESSMENT_UUID;
        List<Map <String,dynamic>> assessment_files = List<Map <String,dynamic>>();

        for( AssessmentTasks task in taskList){
            Map<String,dynamic> file_info = Map<String,dynamic>();
            file_info['assessment_task_type'] = task.assessmentTaskType;
            file_info['assessment_task_uuid'] = task.assessmentTaskUuid;
            file_info['assessment_task_answer'] = task.assessmentTaskAnswerIdResponseId;
            file_info['assessment_task_result'] = task.result;
            file_info['assessment_result_Is_pending'] = isPanding;
            assessment_files.add(file_info);
        }
       
        String json = jsonEncode(assessment_files);
        AppUtils.onPrintLog("json >> $json");


        if(this.assessmentSelected.ASSESSMENT_UUID != null && this.assessmentSelected.ASSESSMENT_UUID.isNotEmpty){
          if(await AppUtils.isNetwrokAvailabe(context) == true){
            
            Map body = {
              AppKey.param_assessment_uuid:resMetadata.assessmentUuid,
              AppKey.param_candidate_uuid:resMetadata.candidateUuid,
              AppKey.param_assessor_uuid:resMetadata.assessorUuid,
              AppKey.param_assessment_result:resMetadata.assessmentResult,
              AppKey.param_assessment_obtainmark:resMetadata.assessmentObtainmark,
              AppKey.param_assessor_comment:comment,
              AppKey.param_assessment_data:json,
            };

            AppUtils.onPrintLog("json >> $body");

            var responseUploadTaskResult =  await APIManager().httpRequest(APIType.private,APIMathods.uploadAssessment,body) as Map;
            AppUtils.onPrintLog("response_uploadTaskResult >> $responseUploadTaskResult");
            if(responseUploadTaskResult != null){
      
                if(responseUploadTaskResult[ApiResponsKey.success] == true){
                    performAssessmentTaskDelete(this.assessmentSelected);
                    
                }else {
                  if(responseUploadTaskResult[ApiResponsKey.error] != null){
                      _isError = true;
                      Map error = responseUploadTaskResult[ApiResponsKey.error];
                      if(error[ApiResponsKey.message] != null){
                        errorMessage = error[ApiResponsKey.message];
                      }
                      if(_isError == true){
                        AppUtils.showInSnackBar(_scaffoldKeyHome, errorMessage);
                      }

                      // setState((){
                      //   AppUtils.onPrintLog("_isLoading >> 1B1");
                      //   _isLoading = false;
                      //   _isStartAssessmentTapped = false;
                      // });
                      _isStartAssessmentTapped = false;
                      _loadingStreamController.sink.add(false);
                    } 
                }
            }
            
            
          } else {
              _isError = true;
              if(_isError == true){
                AppUtils.showInSnackBar(_scaffoldKeyHome,AppMessage.kError_NoInternet);
              }
            //   setState((){
            //   AppUtils.onPrintLog("_isLoading >> 11");
            //   _isLoading = false;
            //   _isStartAssessmentTapped = false;
            // });

            _isStartAssessmentTapped = false;
            _loadingStreamController.sink.add(false);
            return null;
          }

        } else {
          // setState((){
          //     AppUtils.onPrintLog("_isLoading >> 12");
          //     _isLoading = false;
          //     _isStartAssessmentTapped = false;
          // });
          _isStartAssessmentTapped = false;
          _loadingStreamController.sink.add(false);
          AppUtils.showInSnackBar(_scaffoldKeyHome, AppMessage.kError_NoAssessment);
          return null;
        }
    }

    performAssessmentTaskDelete(Assessment assessment) async{
        await _deleteContact(this.assessmentSelected);
        await _deleteCalenderEvent(this.assessmentSelected);

        this.assessmentSelected.IS_ADD_CONTACT = 0;
        this.assessmentSelected.CONTACT_ID = '';
        this.assessmentSelected.IS_ADD_CALENDER = 0;
        this.assessmentSelected.CALENDER_ID = '';
        //this.assessmentSelected.IS_UPLOADED = 0;
        //this.assessmentSelected.IS_END = 0;
        var res = await DBManager.db.checkAssessementsExists(this.assessmentSelected);
        if (res.isNotEmpty){
          await DBManager.db.updateAssessmetns(this.assessmentSelected);
          await updateCandidateList();
        } 
        /*AssessmentMetaData resMetadata = await DBManager.db.getAssessementsMetaData(this.assessmentSelected.ASSESSMENT_UUID, this.assessmentSelected.ASSESSOR_UUID);
        resMetadata.assessmentPassmark = '';
        resMetadata.assessmentResult = '';
        resMetadata.assessmentComment = '';
        resMetadata.assessmentPending = 0;
        await DBManager.db.updateAssessmetnsMetaData(resMetadata);

        List<AssessmentTasks> list = await DBManager.db.getAllAssessementsTasks(this.assessmentSelected.ASSESSMENT_UUID, this.assessmentSelected.ASSESSOR_UUID);
        list.forEach((task)async {
          task.result = '';
          task.assessmentTaskAnswerIdResponseId = '';
          task.assessmentTaskAnswerResponseText = '';
          task.assessmentTaskLocalFile = '';
          await DBManager.db.updateAssessmetnsTask(task);
        });*/

        final String  assessorPath =  await AppUtils.getAssessorPath();
        await AppUtils.deleteLocalFolder('$assessorPath/${this.assessmentSelected.ASSESSMENT_UUID}');
        
        //await DBManager.db.deleteTaskData(this.assessmentSelected.ASSESSMENT_UUID);
        AppUtils.showInSnackBar(_scaffoldKeyHome, AppMessage.kError_UploadedSuccess);
         setState((){
           AppUtils.onPrintLog("_isLoading >> 1");
           _isStartAssessmentTapped = false;
         });
        //_isStartAssessmentTapped = false;
        _loadingStreamController.sink.add(false);
        
    }

    uploadManifestFile(Map<String,dynamic>fileStatus) async{

        String taskUdid = fileStatus['assessment_task_uuid'] as String;
        if(taskUdid != null && taskUdid != '') {
          Map<String,dynamic> data = Map<String,dynamic>();

          Map<String,dynamic> assessmentMeta = Map<String,dynamic>();
          assessmentMeta['assessment_uuid'] = this.assessmentSelected.ASSESSMENT_UUID;
          assessmentMeta['assessment_task_uuid'] = taskUdid;

          Map<String,dynamic> assessmentFile = Map<String,dynamic>();
          AssessmentTasks task = await DBManager.db.getAssessementsTask(taskUdid,this.assessmentSelected.ASSESSMENT_UUID, this.assessmentSelected.ASSESSOR_UUID);
          if(task.assessmentTaskLocalFile.isNotEmpty) {
              String docDirectory = await AppUtils.getDocumentPath();
              String fileFullPath = '$docDirectory/${task.assessmentTaskLocalFile}';
              final File file =  File(fileFullPath);
              
              List<int> imageBytes = file.readAsBytesSync();
              String base64 =  base64Encode(imageBytes);
              assessmentFile['assessment_file_content'] = base64;
              
          }
          data['assessment_meta'] = assessmentMeta;
          data['assessment_file'] = assessmentFile;
          String json = jsonEncode(data);
          AppUtils.onPrintLog("json >> $json");
          if(this.assessmentSelected.ASSESSMENT_UUID != null && this.assessmentSelected.ASSESSMENT_UUID.isNotEmpty){
            if(await AppUtils.isNetwrokAvailabe(context) == true){
              Map body = {
                AppKey.param_rawJson:json
              };
              APIManager().httpRequest(APIType.private,APIMathods.uploadManifest,body).then((response){
                uploadFileCount++;
                AppUtils.onPrintLog("response 3424 >> $response");
                AppUtils.onPrintLog("uploadFileCount >> $uploadFileCount");
                AppUtils.onPrintLog("needTouploadFileCount >> $needTouploadFileCount");
                if(uploadFileCount >= needTouploadFileCount){
                  uploadTaskResult();
                  
                }
                //return response;
              });
              //var response =  await APIManager().httpRequest(APIType.private,APIMathods.uploadManifest,body) as Map;
              
            } else {
                _isError = true;
                if(_isError == true){
                  AppUtils.showInSnackBar(_scaffoldKeyHome,AppMessage.kError_NoInternet);
                }
            //     setState((){
            //   AppUtils.onPrintLog("_isLoading >> 19");
            //   _isLoading = false;
            //   _isStartAssessmentTapped = false;
            // });
            _isStartAssessmentTapped = false;
            _loadingStreamController.sink.add(false);
              //return null;
            }
          } else {
            AppUtils.showInSnackBar(_scaffoldKeyHome, AppMessage.kError_NoAssessment);
            // setState((){
            //   AppUtils.onPrintLog("_isLoading >> 20");
            //   _isLoading = false;
            //   _isStartAssessmentTapped = false;
            // });
            _isStartAssessmentTapped = false;
            _loadingStreamController.sink.add(false);
            //return null;
          }
        } else {
          // setState((){
          //     AppUtils.onPrintLog("_isLoading >> 21");
          //     _isLoading = false;
          //     _isStartAssessmentTapped = false;
          //   });
          _isStartAssessmentTapped = false;
          _loadingStreamController.sink.add(false);
          //return null;
        }
    }

    getFileSize(String path) async {
      AppUtils.onPrintLog('File path-->$path');
      File file =  File('$path');
      var isExist = await file.exists();
      if (isExist) {
        AppUtils.onPrintLog('File exists------------------>_getLocalFile()');
        return await file.length().then((onValue){
        AppUtils.onPrintLog('onValue -->$onValue');
        return onValue;
      });
        //return 'exist';
      } else {
        AppUtils.onPrintLog('file does not exist---------->_getLocalFile()');  
        return '';
      }
    }

    void _uploadAssessment() async {

      if(_isStartAssessmentTapped == false){
          if(this.assessmentSelected.ASSESSMENT_UUID != null && this.assessmentSelected.ASSESSMENT_UUID.isNotEmpty ){
          if(this.assessmentSelected.IS_END == 1){
            
            
            List<AssessmentTasks> list = await DBManager.db.getAllAssessementsTasks(this.assessmentSelected.ASSESSMENT_UUID, this.assessmentSelected.ASSESSOR_UUID);

           // AppUtils.showInSnackBar(_scaffoldKeyHome, 'Upload assessment is under devlopment');
            // setState((){
            //       _isLoading = true;
            //       _isStartAssessmentTapped = true;
            // });
            _isStartAssessmentTapped = true;
            _loadingStreamController.sink.add(true);
            //var getManifestResponse = await getManifestFile(this.assessmentSelected.ASSESSMENT_UUID);
            //AppUtils.onPrintLog("getManifestResponse >> $getManifestResponse");
            setManifestFile(this.assessmentSelected.ASSESSMENT_UUID,list);
            
            
          } else {
            // setState((){
            //   AppUtils.onPrintLog("_isLoading >> 13");
            //   _isLoading = false;
            //   _isStartAssessmentTapped = false;
            // });
            _isStartAssessmentTapped = false;
            _loadingStreamController.sink.add(false);
            AppUtils.showInSnackBar(_scaffoldKeyHome, 'First need to end assessment than upload.');
          }

        } else {
          // setState((){
          //     AppUtils.onPrintLog("_isLoading >> 14");
          //     _isLoading = false;
          //     _isStartAssessmentTapped = false;
          //   });
          _isStartAssessmentTapped = false;
          _loadingStreamController.sink.add(false);
          AppUtils.showInSnackBar(_scaffoldKeyHome, AppMessage.kError_NoAssessment);
          
        }
      }
    }

    void _startAssessment() async {
      //if(_isLoading == false){
          if(this.assessmentSelected.IS_END == 0){
            if (this.assessmentSelected.IS_DOWNLOADED == 1){
                // setState((){
                //     _isLoading = true;
                //     _isStartAssessmentTapped = true;
                // });
                _isStartAssessmentTapped = true;
                _loadingStreamController.sink.add(true);

                if(this.assessmentSelected.ASSESSMENT_UUID != null && this.assessmentSelected.ASSESSMENT_UUID.isNotEmpty){
                  AssessmentMetaData resMetadata = await DBManager.db.getAssessementsMetaData(this.assessmentSelected.ASSESSMENT_UUID, this.assessmentSelected.ASSESSOR_UUID);
                  List<AssessmentTasks> list = await DBManager.db.getAllAssessementsTasks(this.assessmentSelected.ASSESSMENT_UUID, this.assessmentSelected.ASSESSOR_UUID);

                  list.forEach((task){
                      AppUtils.onPrintLog('task >> $task');
                      AppUtils.onPrintLog('task questions >>${task.prompt}');
                      AppUtils.onPrintLog('task responses >>${task.responses}');
                      AppUtils.onPrintLog('task assessmentTaskAnswerIdResponseId >>${task.assessmentTaskAnswerIdResponseId}');
                      AppUtils.onPrintLog('task assessmentTaskAnswerResponseText >>${task.assessmentTaskAnswerResponseText}');
                      AppUtils.onPrintLog('task assessmentTaskLocalFile >>${task.assessmentTaskLocalFile}');
                  });

                    // setState((){
                    // AppUtils.onPrintLog("_isLoading >> 2");
                    //   _isLoading = false;
                    //   _isStartAssessmentTapped = false;
                    // });
                    if(list != null && list.length > 0){
                      String taskFolder = await AppUtils.getAssessmentPath(this.assessmentSelected.ASSESSMENT_UUID);
                      await AppUtils.getCreateFolder(taskFolder);
                      final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => StartAssessment(resMetadata: resMetadata,resAssessmentTask: list,resAssessment: this.assessmentSelected)));
                      if(result != null){
                            Assessment assessment = result as Assessment;
                            //await DBManager.db.performAssessmetnsAction(candidate);
                            var res = await DBManager.db.checkAssessementsExists(assessment);
                            if (res.isEmpty){
                              await DBManager.db.insertAssessmetns(assessment);
                            } 
                            var response =  await DBManager.db.getAssessements(assessment.ASSESSMENT_UUID,assessment.ASSESSOR_UUID);
                            setState(() {
                              if(this.assessmentSelected != null){
                                updateCandidateList();
                              }
                              this.assessmentSelected = response != null?response as Assessment:null;
                            });
                       }
                      _isStartAssessmentTapped = false;
                      _loadingStreamController.sink.add(false);
                    } else {
                      _isStartAssessmentTapped = false;
                      _loadingStreamController.sink.add(false);
                    }
                  

                } else {
                  // setState((){
                  //   AppUtils.onPrintLog("_isLoading >> 3");
                  //       _isLoading = false;
                  //       _isStartAssessmentTapped = false;
                  //   });
                  _isStartAssessmentTapped = false;
                  _loadingStreamController.sink.add(false);
                  AppUtils.showInSnackBar(_scaffoldKeyHome, AppMessage.kError_NoAssessment);
                }
            } else {
                AppUtils.showInSnackBar(_scaffoldKeyHome, AppMessage.kError_Download);
            }
          } else {
            AppUtils.showInSnackBar(_scaffoldKeyHome, 'Need to upload assessment document.');
          }
      //}
      
      

    }


}

class SearchCandidateView extends StatefulWidget {
  SearchCandidateView({Key key,this.arrAssessments,this.currentAssessment}) : super(key: key);

  final List<Assessment> arrAssessments;
  final Assessment currentAssessment;
  _SearchCandidateViewState createState() => _SearchCandidateViewState();
}

class _SearchCandidateViewState extends State<SearchCandidateView> {

  TextEditingController txtSearch = TextEditingController();
  List<Assessment> arrSearch = List<Assessment> ();
  BuildContext globalContext;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.arrAssessments != null){
      setState((){
        arrSearch.addAll(widget.arrAssessments);
      });
    }
  }
  @override
   void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    AppUtils.onPrintLog('didChangeDependencies');

  }

  @override
  void didUpdateWidget(SearchCandidateView oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    AppUtils.onPrintLog('didUpdateWidget');
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    txtSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globalContext =  context;
    return SimpleDialog(
            title: Column(
              children: <Widget>[
                TextField(
                  onChanged: (value){
                    filterSearchResult(value);
                  },
                  onSubmitted: (String value) => FocusScope.of(context).requestFocus(new FocusNode()),
                  textAlign: TextAlign.left,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(
                    color: ThemeColor.theme_dark,
                    fontFamily: ThemeFont.font_pourceSanPro,
                    fontSize: 18.0
                  ),
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  
                )
              ],
            ),
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                        itemExtent: 40,
                        itemCount: this.arrSearch.length,
                        itemBuilder: (context,i){
                          return _buildCanidateTiles(context,i);
                        },
                )
              )
            ],
          );
  }

  Widget _buildCanidateTiles(BuildContext context, index){

      Assessment assessment = this.arrSearch[index];
      bool isSelectedAssessment = false;
      AppUtils.onPrintLog('widget.currentCandidate.ASSESSMENT_ID >> ${widget.currentAssessment.ASSESSMENT_ID}');
      AppUtils.onPrintLog('assessment.ASSESSMENT_ID >> ${assessment.ASSESSMENT_ID}');
      if(widget.currentAssessment.ASSESSMENT_ID == assessment.ASSESSMENT_ID){
        isSelectedAssessment = true;
      }

      String firstsName = assessment.ASSESSMENT_CANDIDATE_FIRST;
      String lastName = assessment.ASSESSMENT_CANDIDATE_LAST;
      String fullName = '$firstsName $lastName';

      return ListTile(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: ThemeColor.theme_borderline_gray
              )
            )
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
          child: Container(
                height: MediaQuery.of(context).size.height,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[ 
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                          fullName,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontFamily: ThemeFont.font_pourceSanPro,
                              color: ThemeColor.theme_dark,
                              fontWeight: FontWeight.w600,
                              fontSize: 18.0),
                        ),
                    ),
                    isSelectedAssessment?Container(
                      padding: EdgeInsets.only(right: 10),
                      width: 35,
                      height: 35,
                      child: Image.asset(ThemeImage.image_yes),
                    ):SizedBox(
                      height: 0,
                      width: 0,
                    ),
                  ],
                ),
              ),
        ),  
        onTap: (){
          AppUtils.onPrintLog("pop  >> 6 ");
          Navigator.of(context).pop(assessment);
        },
      );
  }

  void filterSearchResult(String searchText){
       List<Assessment> dummySearchList = List<Assessment>();
    dummySearchList.addAll(widget.arrAssessments);
      if(searchText.isNotEmpty){
          List<Assessment> arrDynamic = List<Assessment>();
          dummySearchList.forEach((assessment){
              String fullName = assessment.ASSESSMENT_CANDIDATE_FIRST + ' ' +assessment.ASSESSMENT_CANDIDATE_LAST;
              AppUtils.onPrintLog('fullName >>> $fullName');
              AppUtils.onPrintLog('searchText >>> $searchText');
              if(fullName.toLowerCase().contains(searchText.toLowerCase())){
                  arrDynamic.add(assessment);
              }
          });
          setState(() {
            this.arrSearch.clear();
            this.arrSearch.addAll(arrDynamic);
          });
          return;
      } else {
        
        setState(() {
          this.arrSearch.clear();
          this.arrSearch.addAll(widget.arrAssessments);
        });
        return;
      }
  }
}