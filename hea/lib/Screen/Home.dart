import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hea/Utils/AppUtils.dart';
import 'package:hea/Model/Candidate.dart';
import 'package:hea/Utils/apimanager.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:hea/Screen/StartAssessment.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  Candidate assessmentSelected;
  bool _isLoading = true;
  bool _isError = false;

  String noDataMessage = '';

  var errorMessage = AppMessage.kError_SomethingWentWrong;
  List<Candidate> arrCadidates;
  String appUserToken;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBasicRequireParameters();
    getAessessment();
  }

  void getBasicRequireParameters() async {
      appUserToken = await AppUtils.getAppUserToken() ;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
          onPressed: (){
            
          },)
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
      bottomNavigationBar:this.assessmentSelected != null?Container(
        height: 60,
        decoration: BoxDecoration(
          color: ThemeColor.theme_blue
        ),
        child: FlatButton(
                          onPressed: () => _startAssessment(),
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
      ):SizedBox(
        width: 0.0,
        height: 0.0,
      ),
    );
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
          _isLoading?AppUtils.onShowLoder() : Container(height: 0.0, width: 0.0,),
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(child:
                                Container(
                                  height: 50,
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                                    ),
                                    color: ThemeColor.theme_blue,
                                  ),
                                  child: FlatButton(
                                    onPressed: () => ({
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
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(child:
                                Container(
                                  height: 50,
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                                    ),
                                    color: ThemeColor.theme_blue,
                                  ),
                                  child: FlatButton(
                                    onPressed: () => ({}),
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
                              ),
                              
                              
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
                    setState(() {
                      this.assessmentSelected = this.arrCadidates[0];
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
                    AppUtils.showInSnackBar(_scaffoldKey, errorMessage);
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
            AppUtils.showInSnackBar(_scaffoldKey,AppMessage.kError_NoInternet);
          }
      }
    } else {
        AppUtils.showInSnackBar(_scaffoldKey, errorMessage);
        setState(() {
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
                    AppUtils.showInSnackBar(_scaffoldKey, errorMessage);
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
            AppUtils.showInSnackBar(_scaffoldKey,AppMessage.kError_NoInternet);
          }
      }
    } else {
        AppUtils.showInSnackBar(_scaffoldKey, errorMessage);
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
          setState(() {
            this.assessmentSelected = result as Candidate;
          });
      }
    }

    Future _addToDevice() async {
        setState(() {
          _isLoading = true;
        });
        if(this.assessmentSelected.ASSESSMENT_CANDIDATE_NUMBER != null && this.assessmentSelected.ASSESSMENT_CANDIDATE_NUMBER != ''){
          await _addToContact();
        }

        if(this.assessmentSelected.ASSESSMENT_APPOINTMENT != null && this.assessmentSelected.ASSESSMENT_APPOINTMENT != ''){
          await _addToCalender();
        }
        
        setState(() {
          _isLoading = false;
        });
    }

    Future _addToContact() async {
        Contact newContct = Contact();
        newContct.displayName = this.assessmentSelected.ASSESSMENT_CANDIDATE_FIRST + ' ' + this.assessmentSelected.ASSESSMENT_CANDIDATE_LAST;
        newContct.givenName = this.assessmentSelected.ASSESSMENT_CANDIDATE_FIRST;
        newContct.familyName = this.assessmentSelected.ASSESSMENT_CANDIDATE_LAST;
        newContct.emails = [Item(label: 'email',value: this.assessmentSelected.ASSESSMENT_CANDIDATE_EMAIL)];
        newContct.phones = [Item(label: 'phone',value: this.assessmentSelected.ASSESSMENT_CANDIDATE_NUMBER)];
        await ContactsService.addContact(newContct);
    }

    Future _addToCalender() async {

      String candidateFullName = this.assessmentSelected.ASSESSMENT_CANDIDATE_FIRST + ' ' + this.assessmentSelected.ASSESSMENT_CANDIDATE_LAST;
      DateTime startDate  = DateTime.parse(this.assessmentSelected.ASSESSMENT_APPOINTMENT);
      DateTime endDate  = startDate.add(Duration(days: 1));
      final Event event = Event(
        title: '$candidateFullName  assessment  of ${this.assessmentSelected.ASSESSMENT_TITLE}',
        description: this.assessmentSelected.ASSESSMENT_TITLE,
        startDate: startDate,
        endDate: endDate
      );
      Add2Calendar.addEvent2Cal(event);

    }

    void _startAssessment() async {

      if(this.assessmentSelected.ASSESSMENT_UUID != null && this.assessmentSelected.ASSESSMENT_UUID.isNotEmpty){
        if(await AppUtils.isNetwrokAvailabe(context) == true){
          setState((){
              _isLoading = true;
          });
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
                      AppUtils.showInSnackBar(_scaffoldKey, errorMessage);
                    }
                  }
              }
          }
          setState((){
            _isLoading = false;
          });
          _isLoading = false;
          if(data != null){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => StartAssessment(responsData: data)));
          }
        } else {
            _isError = true;
            if(_isError == true){
              AppUtils.showInSnackBar(_scaffoldKey,AppMessage.kError_NoInternet);
            }
        }

      } else {
         AppUtils.showInSnackBar(_scaffoldKey, AppMessage.kError_NoAssessment);
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
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    txtSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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