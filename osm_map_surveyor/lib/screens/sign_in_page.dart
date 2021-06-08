import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:osm_map_surveyor/bloc/authentication_bloc.dart';
import 'package:osm_map_surveyor/events/authentication_event.dart';
import 'package:osm_map_surveyor/repositories/account_repository.dart';
import 'package:osm_map_surveyor/screens/general_page.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/states/authentication_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/popup_utils.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AccountRepository _accountRepository = AccountRepository();
  AuthenticationBloc _authenticationBloc;
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    _authenticationBloc = AuthenticationBloc(accountRepository: _accountRepository);
    _authenticationBloc.add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Config.loadingBackgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            authenticateBlocListener(),
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                fit: StackFit.loose,
                children: <Widget>[
                  loginBox(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget authenticateBlocListener() {
    return BlocListener(
      bloc: _authenticationBloc,
      listener: (BuildContext context, AuthenticationState state) async {
        if (state is Authenticated) {
          final rs = await Navigator.push(context, MaterialPageRoute(builder: (context) => LoadingPage()));
          if (rs != null) {
            if (rs) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GeneralPage()));
            } else {
              _authenticationBloc.add(LoggedOutWithLoadingFail());
            }
          }
        } else if (state is UnpermittedFinishState) {
          PopupUtils.utilShowLoginDialog(Config.failLogin, Config.failBody, context);
          setState(() {
            _isLogin = false;
          });
        } else if (state is Unauthenticated) {
          PopupUtils.utilShowLoginDialog(Config.errorLogin, Config.errorBody, context);
          setState(() {
            _isLogin = false;
          });
        } else if (state is LoadingFailUnAuthenticated) {
          PopupUtils.utilShowLoginDialog(Config.loadingFail, Config.loadingFailBody, context);
          setState(() {
            _isLogin = false;
          });
        } else if (state is InitUnauthorized) {
          setState(() {
            _isLogin = false;
          });
        } else if (state is NoLoginFinishState) {
          setState(() {
            _isLogin = false;
          });
        }
      },
      child: SizedBox(),
    );
  }

  Widget loginBox(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.1,
      child: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.4),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.height * 0.01,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.height * 0.01
                ),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.06,
              child: !_isLogin? SignInButton(
                Buttons.Google,
                text: "Sign in with Google", 
                onPressed:() {
                  _authenticationBloc.add(SignInWithGoogle());
                  setState(() {
                    _isLogin = true;
                  });
                },
              ) 
              : RaisedButton(
                onPressed: null,
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
