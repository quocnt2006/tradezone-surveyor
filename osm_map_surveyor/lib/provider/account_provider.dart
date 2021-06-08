import 'dart:convert';
import 'dart:io';
import 'package:osm_map_surveyor/models/account.dart';
import 'package:osm_map_surveyor/utilities/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class AccountProvider {
  Future<Account> updateAccount(Account account) async {
    final prefs = await SharedPreferences.getInstance();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String jwtToken = prefs.getString('JwtToken');
    String id = account.id.toString();
    account.id = null;
    dynamic bodyString = encoder.convert(account);
    final http.Response response = await http.put(
      BaseUrl.accountbyid(id),
      headers: {
        HttpHeaders.contentTypeHeader : 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: bodyString
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> bodyDecode = jsonDecode(response.body);
      prefs.setString('JwtToken', bodyDecode['jwt']);
      Account rs = Account.fromJsonResponse(bodyDecode);
      return rs;
    } else {
      throw Exception('Fail to update account');
    }
  } 
}