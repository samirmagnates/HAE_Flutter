import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hea/Utils/AppUtils.dart';
import 'package:hea/Model/Candidate.dart';
import 'package:hea/Utils/apimanager.dart';
import 'package:hea/Utils/DbManager.dart';
import 'package:contacts_service/contacts_service.dart';
//import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:hea/Screen/StartAssessment.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hea/Model/AssessmentTasks.dart';
import 'package:hea/Model/AssessmentMetaData.dart';
import 'package:hea/Model/QuestionOptions.dart';
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  DeviceCalendarPlugin _deviceCalendarPlugin;
  static final GlobalKey<ScaffoldState> _scaffoldKeyHome = new GlobalKey<ScaffoldState>();
  
  Candidate assessmentSelected;
  bool _isLoading = true;
  bool _isError = false;
  bool _isAddToDeviceTapped = false;
  bool _isDownloadTapped = false;
  bool _isStartAssessmentTapped = false;
  bool _isDeleteTap = false;


  String noDataMessage = '';

  var errorMessage = AppMessage.kError_SomethingWentWrong;
  List<Candidate> arrCadidates;
  String appUserToken;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _deviceCalendarPlugin = new DeviceCalendarPlugin();
    getBasicRequireParameters();
    getAessessment();
  }

  void getBasicRequireParameters() async {
      appUserToken = await AppUtils.getAppUserToken() ;
      Map<PermissionGroup, PermissionStatus> permissionRequestResult = await PermissionHandler().requestPermissions([PermissionGroup.calendar,PermissionGroup.contacts]);
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
            if(_isDeleteTap == false)  {
              //await _performDeletAction();
               await DBManager.db.clearDataBase(this.assessmentSelected.ASSESSOR_UUID);
                Navigator.of(context).pop();
            } 
          },
          )
        ],
        leading: IconButton(
          padding: EdgeInsets.all(12.0),
          icon: Image.asset(ThemeImage.image_logout),
          onPressed: (){
            _showLogoutAlert(context);
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
          onPressed: () => _isStartAssessmentTapped?null:_startAssessment(),
          child: Center(
            child: Text(
                AppConstant.kTitle_StartAssessment,
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
    setState(() {
          _isLoading = true;
          _isDeleteTap = true;
    });

    for (int i = 0; i < this.arrCadidates.length; i++){
        Candidate can = this.arrCadidates[i];
        if (can.IS_ADD_CONTACT == 1){
            Map<PermissionGroup, PermissionStatus> permissionRequestResult = await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
            PermissionStatus _permissionStatus = permissionRequestResult[PermissionGroup.contacts];
            if(_permissionStatus == PermissionStatus.granted){
                await _deleteContact(can);
            } else {
                openPermisionPopupBox('Contact Access Denie','Enable contact service for application form setting');
            }
        }
        if (can.IS_ADD_CALENDER == 1){
            Map<PermissionGroup, PermissionStatus> permissionRequestResult = await PermissionHandler().requestPermissions([PermissionGroup.calendar]);
            PermissionStatus _permissionStatus = permissionRequestResult[PermissionGroup.contacts];
            if(_permissionStatus == PermissionStatus.granted){
                await _deleteCalenderEvent(can);
            } else {
                openPermisionPopupBox('Contact Access Denie','Enable contact service for application form setting');
            }
        }
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
          _isLoading?AppUtils.onShowLoder() : SizedBox(height: 0.0, width: 0.0,),
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
                                  _showCandidatePicker(context);
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
                                    onPressed: () => _isAddToDeviceTapped?null:({
                                       _addToDevice()
                                    }),
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
                                    onPressed: () => _isDownloadTapped?null:({
                                       _downloadAssessment()
                                    }),
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

    var assessorUUID = await AppUtils.getAssessorUUID() as String;

    if (assessorUUID != null && assessorUUID != ''){
      if(await AppUtils.isNetwrokAvailabe(context) == true){
        setState(() {
            _isLoading = true;
        });
        
        Map body = {
          AppKey.param_assessor_uuid:assessorUUID
        };

        var response =  await APIManager().httpRequest(APIType.private,APIMathods.getAssessments,context,body) as Map;
        var data;
        if(response != null){
            AppUtils.onPrintLog("response >> $response");
            if(response[ApiResponsKey.success] == true){
              if(response[ApiResponsKey.data] != null){
                data = response[ApiResponsKey.data];
                Iterable list = data;
                //matchData = list.map((model) => Match.fromJson(model)).toList();
                this.arrCadidates = list.map((model) => Candidate.fromJSON(model)).toList();
                if(this.arrCadidates.length > 0){
                    Candidate candidate = this.arrCadidates.first;
                    //await DBManager.db.performAssessmetnsAction(candidate);

                    var res = await DBManager.db.checkAssessementsExists(candidate);
                    if (res.isEmpty){
                      await DBManager.db.insertAssessmetns(candidate);
                    } 
                    var response =  await DBManager.db.getAssessements(candidate.ASSESSMENT_UUID,candidate.ASSESSOR_UUID);
                    setState(()  {
                      this.assessmentSelected = response != null?response as Candidate:null;
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
        setState(() {
            _isLoading = false;
        });
        if(data != null){
          //Navigator.of(context).pushNamed(AppRoute.routeHomeScreen);
        }
      } else {
          setState(() {
            _isLoading = false;
          });
          _isError = true;
          if(_isError == true){
            AppUtils.showInSnackBar(_scaffoldKeyHome,AppMessage.kError_NoInternet);
          }
      }
    } else {

        AppUtils.showInSnackBar(_scaffoldKeyHome, errorMessage);
        setState(() {
            _isLoading = false;
            this.assessmentSelected = null;
          });
    }
  }
  

  void logout() async{
    
  if (appUserToken != null && appUserToken.isNotEmpty){
      if(await AppUtils.isNetwrokAvailabe(context) == true){
        setState((){
            _isLoading = true;
        });
        AppUtils.onShowLoder();
        Map body = {
          AppKey.param_appuser_token:appUserToken
        };

        var response =  await APIManager().httpRequest(APIType.public,APIMathods.logout,context,body) as Map;
        var data;
        if(response != null){
            AppUtils.onPrintLog("response >> $response");
  
            if(response[ApiResponsKey.success] == true){
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
        setState((){
          _isLoading = false;
        });
         _isLoading = false;
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
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: new Text("Logout"),
                onPressed: () {
                  Navigator.of(context).pop();
                  logout();
                },
              ),
            ],
          )
      );
    }

    void _showCandidatePicker(BuildContext context) async{

       final result = await showDialog(
          context: context,
          builder: (context) => SearchCandidateView(arrCadidates:this.arrCadidates)
      );

      if(result != null){
          Candidate candidate = result as Candidate;
          //await DBManager.db.performAssessmetnsAction(candidate);
          var res = await DBManager.db.checkAssessementsExists(candidate);
          if (res.isEmpty){
            await DBManager.db.insertAssessmetns(candidate);
          } 
          var response =  await DBManager.db.getAssessements(candidate.ASSESSMENT_UUID,candidate.ASSESSOR_UUID);
          setState(() {
            this.assessmentSelected = response != null?response as Candidate:null;
            if(this.assessmentSelected != null){
               updateCandidateList();
            }
          });
      }
    }

    Future _addToDevice() async {
        setState(() {
          _isLoading = true;
          _isAddToDeviceTapped = true;
        });
        
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
        
        setState(() {
          _isLoading = false;
          _isAddToDeviceTapped = false;
        });
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

    Future _deleteContact(Candidate candidate) async {

      try{
        //var contact = await ContactsService.getContacts(query: 'identifier:${candidate.CONTACT_ID}');
        var allContacts = await ContactsService.getContacts();
        var filtered = allContacts.where((c) => c.identifier.contains("${candidate.CONTACT_ID}")).toList();
        AppUtils.onPrintLog('calender >>> $filtered');
        await ContactsService.deleteContact(filtered.first);
      } on PlatformException catch(e){
        //openPermisionPopupBox('Contact ${e.message}','Enable contact service for application form setting');
        //AppUtils.showInSnackBar(_scaffoldKey,'Contact ${e.message}');
      }

    }

    

    Future _deleteCalenderEvent(Candidate candidate) async {

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      Calendar calendar = calendarsResult.data.first;
      var createEventResult = await _deviceCalendarPlugin.deleteEvent(calendar.id, candidate.CALENDER_ID);
      if (createEventResult.isSuccess) {
          AppUtils.onPrintLog('calender >>> $createEventResult');
      } else {
        AppUtils.onPrintLog('calender error >>> ${createEventResult.errorMessages.join(' | ')}');
      }

    }
    updateCandidateList() async{

      for (int i = 0; i < this.arrCadidates.length; i++){
        Candidate can = this.arrCadidates[i];
        if (can.ASSESSMENT_ID == this.assessmentSelected.ASSESSMENT_ID){
            this.arrCadidates[i] = this.assessmentSelected;
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
        /*final Event event = Event(
          title: '$candidateFullName  assessment  of ${this.assessmentSelected.ASSESSMENT_TITLE}',
          description: this.assessmentSelected.ASSESSMENT_TITLE,
          startDate: startDate,
          endDate: null
        );
        try{

            
            bool isAdded = await Add2Calendar.addEvent2Cal(event);
            if (isAdded == true){
              AppUtils.onPrintLog('calender >>> $isAdded');
              this.assessmentSelected.IS_ADD_CALENDER = 1;
              var res = await DBManager.db.checkAssessementsExists(this.assessmentSelected);
              if (res.isNotEmpty){
                await DBManager.db.updateAssessmetns(this.assessmentSelected);
              } 
            } else {

            }
            
          } on PlatformException catch(e){
            openPermisionPopupBox('Calender ${e.message}','Enable calender service for application form setting');
            //AppUtils.showInSnackBar(_scaffoldKey,e.toString());
          }*/
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
                            Navigator.of(context).pop();
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
          setState((){
              _isLoading = true;
              _isDownloadTapped = true;
          });

          if(this.assessmentSelected.ASSESSMENT_UUID != null && this.assessmentSelected.ASSESSMENT_UUID.isNotEmpty){
            if(await AppUtils.isNetwrokAvailabe(context) == true){
              
              AppUtils.onShowLoder();
              Map body = {
                AppKey.param_assessment_uuid:this.assessmentSelected.ASSESSMENT_UUID
              };

              var response =  await APIManager().httpRequest(APIType.private,APIMathods.downloadAssessment,context,body) as Map;
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
                _isLoading = false;
                _isDownloadTapped = false;
              });
            } else {
                _isError = true;
                if(_isError == true){
                  AppUtils.showInSnackBar(_scaffoldKeyHome,AppMessage.kError_NoInternet);
                }
            }

          } else {
            setState((){
                  _isLoading = false;
                  _isStartAssessmentTapped = false;
              });
            AppUtils.showInSnackBar(_scaffoldKeyHome, AppMessage.kError_NoAssessment);
          }
      } else {
          AppUtils.showInSnackBar(_scaffoldKeyHome, AppMessage.kError_DownloadAlready);
      }
  }

    Future addAssessmentTaskToDb(List<AssessmentTasks>  arrAssessmentTask) async {
      arrAssessmentTask.forEach((task) async {
        var res = await DBManager.db.checkAssessementsTaskExists(task,this.assessmentSelected.ASSESSMENT_UUID,this.assessmentSelected.ASSESSOR_UUID);
          if (res.isEmpty){
            await DBManager.db.insertAssessmetnsTask(task,this.assessmentSelected.ASSESSMENT_UUID,this.assessmentSelected.ASSESSOR_UUID);
          } 
      });
    }

    void _startAssessment() async {

      if (this.assessmentSelected.IS_DOWNLOADED == 1){
          setState((){
              _isLoading = true;
              _isStartAssessmentTapped = true;
          });

          if(this.assessmentSelected.ASSESSMENT_UUID != null && this.assessmentSelected.ASSESSMENT_UUID.isNotEmpty){
            AssessmentMetaData resMetadata = await DBManager.db.getAssessementsMetaData(this.assessmentSelected.ASSESSMENT_UUID, this.assessmentSelected.ASSESSOR_UUID);
            List<AssessmentTasks> list = await DBManager.db.getAllAssessementsTasks(this.assessmentSelected.ASSESSMENT_UUID, this.assessmentSelected.ASSESSOR_UUID);

            list.forEach((task){
                print('task >> $task');
                print('task questions >>${task.prompt}');
            });

            setState((){
                _isLoading = false;
                _isStartAssessmentTapped = false;
              });
              if(list != null && list.length > 0){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => StartAssessment(resMetadata: resMetadata,resAssessmentTask: list,)));
              }
            /*if(await AppUtils.isNetwrokAvailabe(context) == true){
              
              AppUtils.onShowLoder();
              Map body = {
                AppKey.param_assessment_uuid:this.assessmentSelected.ASSESSMENT_UUID
              };

              var response =  await APIManager().httpRequest(APIType.private,APIMathods.downloadAssessment,context,body) as Map;
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
              setState((){
                _isLoading = false;
                _isStartAssessmentTapped = false;
              });
              if(data != null){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => StartAssessment(responsData: data)));
              }
            } else {
                _isError = true;
                if(_isError == true){
                  AppUtils.showInSnackBar(_scaffoldKeyHome,AppMessage.kError_NoInternet);
                }
            }*/

          } else {
            setState((){
                  _isLoading = false;
                  _isStartAssessmentTapped = false;
              });
            AppUtils.showInSnackBar(_scaffoldKeyHome, AppMessage.kError_NoAssessment);
          }
      } else {
           AppUtils.showInSnackBar(_scaffoldKeyHome, AppMessage.kError_Download);
      }

    }


}

class SearchCandidateView extends StatefulWidget {
  SearchCandidateView({Key key,this.arrCadidates}) : super(key: key);

  final List<Candidate> arrCadidates;
  _SearchCandidateViewState createState() => _SearchCandidateViewState();
}

class _SearchCandidateViewState extends State<SearchCandidateView> {

  TextEditingController txtSearch = TextEditingController();
  List<Candidate> arrSearch = List<Candidate> ();
  BuildContext globalContext;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.arrCadidates != null){
      setState((){
        arrSearch.addAll(widget.arrCadidates);
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

      Candidate assessment = this.arrSearch[index];

      String firstsName = assessment.ASSESSMENT_CANDIDATE_FIRST;
      String lastName = assessment.ASSESSMENT_CANDIDATE_LAST;

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
          child: Text(
                  '$firstsName $lastName',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: ThemeFont.font_pourceSanPro,
                      color: ThemeColor.theme_dark,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0),
                ),
        ),
        onTap: (){
          Navigator.of(context).pop(assessment);
        },
      );
  }

  void filterSearchResult(String searchText){
       List<Candidate> dummySearchList = List<Candidate>();
    dummySearchList.addAll(widget.arrCadidates);
      if(searchText.isNotEmpty){
          List<Candidate> arrDynamic = List<Candidate>();
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
          this.arrSearch.addAll(widget.arrCadidates);
        });
        return;
      }
  }
}