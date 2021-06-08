import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:osm_map_surveyor/bloc/authentication_bloc.dart';
import 'package:osm_map_surveyor/events/authentication_event.dart';
import 'package:osm_map_surveyor/provider/authentication_provider.dart';
import 'package:osm_map_surveyor/repositories/account_repository.dart';
import 'package:osm_map_surveyor/screens/general_page.dart';
import 'package:osm_map_surveyor/screens/sign_in_page.dart';
import 'package:osm_map_surveyor/screens/profile/profile_page.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';

Widget appEndDrawer(BuildContext context) {
  // ignore: close_sinks
  final AuthenticationBloc _authenticationBloc =
      AuthenticationBloc(accountRepository: AccountRepository());
  return Theme(
    data: Theme.of(context).copyWith(
       canvasColor: Config.secondColor.withOpacity(0.75),
    ), 
    child: Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.08,
                    backgroundImage: currentUserWithToken.imageUrl != null
                      ? NetworkImage(
                        currentUserWithToken.imageUrl,
                      )
                      : SvgPicture.asset(
                        Config.userSvgIcon,
                        fit: BoxFit.fill,
                      ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                  Text(
                    currentUserWithToken.fullname,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Config.textSizeSmall,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text(
                    currentUserWithToken.email,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: Config.textSizeSuperSmall,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.1,
                      ),
                      side: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      _authenticationBloc.add(LoggedOut());
                      Navigator.popUntil(context, (route) => true);
                      Navigator.of(context).pop(
                        MaterialPageRoute(
                          builder: (context) {
                            return GeneralPage();
                          },
                        ),
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return LoginScreen();
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Center(
                        child: Text(
                          'Sign out',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Config.textSizeSuperSmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ), 
            SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
            FlatButton(
              onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              }, 
              child: Container(
                alignment: Alignment.centerRight,
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.person,
                      color: Colors.white,
                      size: MediaQuery.of(context).size.height * 0.035,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02,
                      ),
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: Config.textSizeSmall,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    )
  );
}
