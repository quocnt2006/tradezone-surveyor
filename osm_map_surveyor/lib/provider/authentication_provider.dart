import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:osm_map_surveyor/models/account.dart';
import 'package:osm_map_surveyor/screens/general_page.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/utilities/base_url.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseMessaging _fcm = FirebaseMessaging();
Account currentUserWithToken;

class AuthenticationProvider {
  Future<Account> fetchUser(String _idToken, String fcmToken) async {
    final prefs = await SharedPreferences.getInstance();
    String bodyString = '{"idToken":"' + _idToken + '","fcmToken":"' + fcmToken + '"}';
    final http.Response response = await http.post(
      BaseUrl.authenticate,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: bodyString
    );
    if (response.statusCode == 200) {
      Account rs = Account.fromJson(JwtDecoder.decode(response.body));
      if (rs.role == 2) {
        prefs.setString("JwtToken", response.body);
        currentUserWithToken = rs;
        return rs;
      } else {
        signOut();
        return rs;
      }
    } else {
      signOut();
      throw Exception('Failed to load user');
    }
  }

  Future<Account> fetchUserByJWT() async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    String bodyString = '{"jwt":"' + jwtToken + '"}';
    final http.Response response = await http.post(
      BaseUrl.verifyJwt,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: bodyString
    );
    if (response.statusCode == 200) {
      Account rs;
      Map<String, dynamic> _jsonBody = jsonDecode(response.body);
      if (!_jsonBody['refreshToken'].isEmpty) {
        rs = Account.fromJson(JwtDecoder.decode(_jsonBody['refreshToken']));
        if (rs.role == 2) {
          prefs.setString("JwtToken", _jsonBody['refreshToken']);
          currentUserWithToken = rs;
          return rs;
        } else {
          signOut();
          return null;
        }
      } else {
        rs = Account.fromJson(JwtDecoder.decode(_jsonBody['jwt']));
        if (rs.role == 2) {
          prefs.setString("JwtToken", _jsonBody['jwt']);
          currentUserWithToken = rs;
          return rs;
        } else {
          signOut();
          return null;
        }
      }
    } else {
      signOut();
      throw Exception('Failed to load user');
    }
  }

  void signOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    currentUserWithToken = null;
    fcm.deleteInstanceID();
    await _auth.signOut();
    await googleSignIn.signOut();
    initListBuildingTypes.clear();
    initListBuildingTypeNames.clear();
    initListNeedSurveyBuildings.clear();
    initListBrands.clear();
    initListBrandNames.clear();
    initListNeedSurveyStores.clear();
    initListNeedSurveySystemZonePolygons.clear();
    initListNeedSurveySystemZone.clear();
    initListNeedSurveyBuildingPolygons.clear();
    initListSegments.clear();
    initListStorePointsOnMap.clear();
    initListHistory.clear();
    initListCampusPolygons.clear();
    initListNeedSurveySystemZoneForDrawPolygons.clear();
  }
}

class FirebaseNetworkProvider {
  AuthenticationProvider _authenticationProvider = new AuthenticationProvider();

  Future<Account> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final AuthResult authResult = await _auth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;
      final tokenId = await user.getIdToken();
      currentUserWithToken = await _authenticationProvider.fetchUser(
        tokenId.token, 
        await _fcm.getToken()
      );
      if (currentUserWithToken != null) {
        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);
        final FirebaseUser currentUser = await _auth.currentUser();
        assert(user.uid == currentUser.uid);
        return currentUserWithToken;
      } else {
        return null;
      }
    } catch(e) {
      return null;
    }
  }

  Future signOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    currentUserWithToken = null;
    fcm.deleteInstanceID();
    await _auth.signOut();
    await googleSignIn.signOut();
    initListBuildingTypes.clear();
    initListBuildingTypeNames.clear();
    initListNeedSurveyBuildings.clear();
    initListBrands.clear();
    initListBrandNames.clear();
    initListNeedSurveyStores.clear();
    initListNeedSurveySystemZonePolygons.clear();
    initListNeedSurveySystemZone.clear();
    initListNeedSurveyBuildingPolygons.clear();
    initListSegments.clear();
    initListStorePointsOnMap.clear();
    initListHistory.clear();
  }

  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    AuthenticationProvider _authenticationProvider = AuthenticationProvider();
    String jwtToken = prefs.getString("JwtToken");
    if (jwtToken != null) {
      currentUserWithToken = await _authenticationProvider.fetchUserByJWT();
      return true;
    } else
      return false;
  }
}
