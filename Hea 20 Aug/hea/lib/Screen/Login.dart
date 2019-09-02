import 'package:flutter/material.dart';
import '../Utils/AppUtils.dart';
import 'package:flutter/rendering.dart';
import '../Utils/apimanager.dart';
import '../Utils/SharedPreferences.dart';
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  static final GlobalKey<FormState> _formKeylogin = GlobalKey<FormState>();
  static final GlobalKey<FormState> _formForgotPassKeylogin = GlobalKey<FormState>();
  static final GlobalKey<ScaffoldState> _scaffoldKeylogin = new GlobalKey<ScaffoldState>();
  
  static final ValueKey _userNameKey = Key("username");
  static final ValueKey _passwordKey = Key("pass");
  static final ValueKey _forgotPasswordUserNameKey = Key("forgotpassUserName");

  TextEditingController txtUserName = TextEditingController();
  TextEditingController txtForgotPassUserName = TextEditingController();
  TextEditingController txtPass = TextEditingController();
  FocusNode _focusNodeEmail = new FocusNode();
  FocusNode _focusNodePass = new FocusNode();

  bool _autoValidate = false;
  bool _autoValidateForgotpass = false;

  bool _isLoginLoading = false;
  bool _isError = false;

  bool _isLoginTapped = false;
  bool _isSendTapped = false;

  var message = AppMessage.kError_SomethingWentWrong;

  bool _obscureText = true;
  @override
    void initState(){
        super.initState();
        //txtUserName.text = 'ASSESSOR';
        //txtPass.text = 'Password';
    }

  @override
   void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
    void dispose(){
        super.dispose();
        txtUserName.dispose();
        txtForgotPassUserName.dispose();
        txtPass.dispose();

    }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeylogin,
      body: SafeArea(
          child: loginPage(context),
        )
    );
    //return LoginPage();
  }

  void _loginPress() async{
    setState(() {
          _isLoginLoading = true;
           _isLoginTapped = true;
      });
    FocusScope.of(context).requestFocus(new FocusNode());
    final bool isValid = _formKeylogin.currentState.validate();

    setState(() {
      _autoValidate = !isValid;
    });

    if (!isValid) {
      setState(() {
          _isLoginLoading = false;
          _isLoginTapped = false;
        });
      return;
    }

    if(await AppUtils.isNetwrokAvailabe(context) == true){
        
        String username = txtUserName.text ?? "";
        String password = txtPass.text ?? "";

        AppUtils.onPrintLog("username >> $username");
        AppUtils.onPrintLog("password >> $password");

        Map body = {
          AppKey.param_username:username,
          AppKey.param_password:password
        };

        var response =  await APIManager().httpRequest(APIType.public,APIMathods.login,body) as Map;
        var data;
        if(response != null){
            AppUtils.onPrintLog("response >> $response");
  
            if(response[ApiResponsKey.success] == true){
              if(response[ApiResponsKey.data] != null){
                data = response[ApiResponsKey.data];
                await SharedPreferencesManager.setObject(data, AppKey.appuser);
              }
            }else {
              
              if(response[ApiResponsKey.error] != null){
                  setState(() {
                    _isError = true;
                  });
                  Map error = response[ApiResponsKey.error];
                  if(error[ApiResponsKey.message] != null){
                    message = error[ApiResponsKey.message];
                  }
                  if(_isError == true){
                    AppUtils.showInSnackBar(_scaffoldKeylogin, message);
                  }
                }
            }
        }
        setState(() {
            _isLoginLoading = false;
            _isLoginTapped = false;
        });
        if(data != null){
          Navigator.of(context).pushNamed(AppRoute.routeHomeScreen);
        }
    } else {
      setState(() {
          _isLoginLoading = false;
           _isLoginTapped = false;
      });
        setState(() {
          _isError = true;
        });
        if(_isError == true){
          AppUtils.showInSnackBar(_scaffoldKeylogin, AppMessage.kError_NoInternet);
        }
    }
  }

  void _forgotPassPress() async {
    setState(() {
      _isLoginLoading = true;
      _isSendTapped = true;
    });
    FocusScope.of(context).requestFocus(new FocusNode());
    final bool isValid = _formForgotPassKeylogin.currentState.validate();
    setState(() {
      _autoValidateForgotpass = !isValid;
    });

    if (!isValid) {
      setState(() {
      _isLoginLoading = false;
      _isSendTapped = false;
    });
      return;
    }
    AppUtils.onPrintLog("pop  >> 7");
    Navigator.of(context).pop(context);
    var message = AppMessage.kError_SomethingWentWrong;
    if(await AppUtils.isNetwrokAvailabe(context) == true){
        
        String username = txtForgotPassUserName.text ?? "";
        AppUtils.onPrintLog("username >> $username");
         Map body = {
          AppKey.param_username:username,
        };
        var response =  await APIManager().httpRequest(APIType.public,APIMathods.resetPassword,body) as Map;
        var data;
        if(response != null){
           AppUtils.onPrintLog("response >> $response");
            if(response[ApiResponsKey.success] == true){
              if(response[ApiResponsKey.data] != null){
                data = response[ApiResponsKey.data];
                SharedPreferencesManager.setObject(data, AppKey.appuser);
              }
               message = AppMessage.kMsg_Reset;
            }else {
              
              if(response[ApiResponsKey.error] != null){
                  Map error = response[ApiResponsKey.error];
                  if(response[ApiResponsKey.message] != null){
                    message = error[ApiResponsKey.message];
                  }
              }

            }
        }
    }

      
      txtForgotPassUserName.text = '';
      AppUtils.showInSnackBar(_scaffoldKeylogin, message);
      setState(() {
          _isLoginLoading = false;
          _isSendTapped = false;
      });
  }

  Widget loginPage(BuildContext context) {
    return Stack(
        children: <Widget>[
          _showLoginBody(),
          _isLoginLoading?_showCircularProgress() : SizedBox(height: 0.0, width: 0.0,),
         ],
      );
  }

  Widget forgotPassPage() {
    return Stack(
        children: <Widget>[
          openForgotAPassPopupBox(),
          //_isForgotPassLoading?_showCircularProgress() : SizedBox(height: 0.0, width: 0.0,)
        ],
      );
  }



  Widget openForgotAPassPopupBox() {
    setState(() {
      _autoValidateForgotpass = false;
    });
     showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 0.0),
            content: 
            Container(
              width: 300.0,
              height: 250.0,
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
                                AppConstant.kHeader_ForogotPass,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: ThemeFont.font_pourceSanPro,
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.center,
                              ),
                    ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0,top: 10),
                    child:Form(
                      key: _formForgotPassKeylogin,
                      child: TextFormField(
                                      focusNode: _focusNodeEmail,
                                      key: _forgotPasswordUserNameKey,
                                      maxLines: 1,
                                      controller: txtForgotPassUserName,
                                      textAlign: TextAlign.left,
                                      textInputAction: TextInputAction.done,
                                        autocorrect: false,
                                        autovalidate: _autoValidateForgotpass,
                                        validator: (value) => 
                                                  value.isEmpty || value.trim().isEmpty ? AppMessage.kError_EnterUserName:null,
                                        onFieldSubmitted: (String value) => FocusScope.of(context).requestFocus(new FocusNode()),        
                                        style: TextStyle(
                                          color: ThemeColor.theme_dark,
                                          fontFamily: ThemeFont.font_pourceSanPro,
                                          fontSize: 18.0
                                        ),
                                        decoration: InputDecoration(
                                          hintText: AppConstant.kHint_UserName,
                                          hintStyle: TextStyle(color: Colors.grey),
                                        ),
                                        
                                      ),
                    )
                  ),
                  Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 30.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          color: ThemeColor.theme_blue,
                        ),
                        child: FlatButton(
                          onPressed: () => _isSendTapped?null:_forgotPassPress(),
                          child: Center(
                            child: Text(
                                AppConstant.kTitle_Send,
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
                ],
              ),
            ),
          );
        });
  }

  Widget _showLoginBody(){
      return Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Form(
              key: _formKeylogin,
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Center(
                      child: new Column(
                    children: <Widget>[
                      SizedBox(height: 100,),
                      Container(
                        //padding: EdgeInsets.all(50.0),
                        height: 120,
                        width: 120,
                        child: Center(
                          child: Image.asset(ThemeImage.image_logo),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      new Row(
                        children: <Widget>[
                          new Expanded(
                            child:  Padding(
                              padding: const EdgeInsets.only(left: 40.0),
                              child:  Text(
                                AppConstant.kHint_UserName,
                                style: TextStyle(
                                  color: ThemeColor.theme_blue,
                                  fontFamily: ThemeFont.font_pourceSanPro,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        child: Padding(
                        padding: EdgeInsets.only(left: 40.0,right: 40.0),
                        child: TextFormField(
                                key: _userNameKey,
                                maxLines: 1,
                                controller: txtUserName,
                                textAlign: TextAlign.left,
                                textInputAction: TextInputAction.next,
                                autocorrect: false,
                                autovalidate: _autoValidate,
                                validator: (value) => 
                                    value.isEmpty || value.trim().isEmpty ? AppMessage.kError_EnterUserName:null,
                                onFieldSubmitted: (String value) => 
                                  FocusScope.of(context).requestFocus(_focusNodePass),    
                                style: TextStyle(
                                  color: ThemeColor.theme_dark,
                                  fontFamily: ThemeFont.font_pourceSanPro,
                                  fontSize: 18.0
                                ),
                                decoration: InputDecoration(
                                  hintText: AppConstant.kHint_UserName,
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      new Row(
                        children: <Widget>[
                          new Expanded(
                            child: new Padding(
                              padding: const EdgeInsets.only(left: 40.0),
                              child: new Text(
                                AppConstant.kHint_Password,
                                style: TextStyle(
                                  color: ThemeColor.theme_blue,
                                  fontFamily: ThemeFont.font_pourceSanPro,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 0.0),
                        child: TextFormField(
                                key: _passwordKey,
                                controller: txtPass,
                                obscureText: _obscureText,
                                textAlign: TextAlign.left,
                                focusNode: _focusNodePass,
                                textInputAction: TextInputAction.done,
                                autovalidate: _autoValidate,
                                autocorrect: false,
                                validator: (value) => 
                                    value.isEmpty || value.trim().isEmpty ? AppMessage.kError_EnterPassword:null,
                                onFieldSubmitted: (String value) => FocusScope.of(context).requestFocus(new FocusNode()),
                                style: TextStyle(
                                  color: ThemeColor.theme_dark,
                                  fontFamily: ThemeFont.font_pourceSanPro,
                                  fontSize: 18.0
                                  ),
                                decoration: InputDecoration(
                                  hintText: AppConstant.kHint_SecurePassword,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText?Icons.visibility_off:Icons.visibility,
                                      color: ThemeColor.theme_blue,),
                                    onPressed: (){
                                      setState(() {
                                          _obscureText = !_obscureText;
                                      });
                                    }, 
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: new FlatButton(
                              child: new Text(
                                AppConstant.kTitle_ForgotPass,
                                style: TextStyle(
                                  color: ThemeColor.theme_blue,
                                  fontFamily: ThemeFont.font_pourceSanPro,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.end,
                              ),
                              onPressed: () => forgotPassPage(),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          color: ThemeColor.theme_blue,
                        ),
                        child: FlatButton(
                          onPressed: () => _isLoginTapped?null:_loginPress(),
                          child: Center(
                            child: Text(
                                AppConstant.kTitle_Login,
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
                      SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                
                  )
                )
              ),
            )
          ]
        )
      );
  }

  Widget _showCircularProgress(){
    if (_isLoginLoading) {
      return Center(child: CircularProgressIndicator());
    } 
  }
  
}

class EnsureVisibleWhenFocused extends StatefulWidget {
  const EnsureVisibleWhenFocused({
    Key key,
    @required this.child,
    @required this.focusNode,
    this.curve: Curves.ease,
    this.duration: const Duration(milliseconds: 100),
  }) : super(key: key);

  /// The node we will monitor to determine if the child is focused
  final FocusNode focusNode;

  /// The child widget that we are wrapping
  final Widget child;

  /// The curve we will use to scroll ourselves into view.
  ///
  /// Defaults to Curves.ease.
  final Curve curve;

  /// The duration we will use to scroll ourselves into view
  ///
  /// Defaults to 100 milliseconds.
  final Duration duration;

  @override
  _EnsureVisibleWhenFocusedState createState() => new _EnsureVisibleWhenFocusedState();
}

///
/// We implement the WidgetsBindingObserver to be notified of any change to the window metrics
///
class _EnsureVisibleWhenFocusedState extends State<EnsureVisibleWhenFocused> with WidgetsBindingObserver  {

  @override
  void initState(){
    super.initState();
    widget.focusNode.addListener(_ensureVisible);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    widget.focusNode.removeListener(_ensureVisible);
    super.dispose();
  }

  ///
  /// This routine is invoked when the window metrics have changed.
  /// This happens when the keyboard is open or dismissed, among others.
  /// It is the opportunity to check if the field has the focus
  /// and to ensure it is fully visible in the viewport when
  /// the keyboard is displayed
  /// 
  @override
  void didChangeMetrics(){
    if (widget.focusNode.hasFocus){
      _ensureVisible();
    }
  }

  ///
  /// This routine waits for the keyboard to come into view.
  /// In order to prevent some issues if the Widget is dismissed in the 
  /// middle of the loop, we need to check the "mounted" property
  /// 
  /// This method was suggested by Peter Yuen (see discussion).
  ///
  Future<Null> _keyboardToggled() async {
    if (mounted){
      EdgeInsets edgeInsets = MediaQuery.of(context).viewInsets;
      while (mounted && MediaQuery.of(context).viewInsets == edgeInsets) {
        await new Future.delayed(const Duration(milliseconds: 10));
      }
    }

    return;
  }

  Future<Null> _ensureVisible() async {
    // Wait for the keyboard to come into view
    await Future.any([new Future.delayed(const Duration(milliseconds: 300)), _keyboardToggled()]);

    // No need to go any further if the node has not the focus
    if (!widget.focusNode.hasFocus){
      return;
    }

    // Find the object which has the focus
    final RenderObject object = context.findRenderObject();
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(object);

    // If we are not working in a Scrollable, skip this routine
    if (viewport == null) {
        return;
    }

    // Get the Scrollable state (in order to retrieve its offset)
    ScrollableState scrollableState = Scrollable.of(context);
    assert(scrollableState != null);

    // Get its offset
    ScrollPosition position = scrollableState.position;
    double alignment;

    if (position.pixels > viewport.getOffsetToReveal(object, 0.0).offset) {
      // Move down to the top of the viewport
      alignment = 0.0;
    } else if (position.pixels < viewport.getOffsetToReveal(object, 1.0).offset){
      // Move up to the bottom of the viewport
      alignment = 1.0;
    } else {
      // No scrolling is necessary to reveal the child
      return;
    }

    position.ensureVisible(
      object,
      alignment: alignment,
      duration: widget.duration,
      curve: widget.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}