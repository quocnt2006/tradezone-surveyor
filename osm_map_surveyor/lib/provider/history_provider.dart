import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:osm_map_surveyor/models/history.dart';
import 'package:osm_map_surveyor/models/listhistories.dart';
import 'package:osm_map_surveyor/utilities/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryProvider {
  Future<List<History>> fetchListHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.history,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      }
    );
    if (response.statusCode == 200) {
      ListHistories listHistory;
      listHistory = new ListHistories.fromJson(jsonDecode(response.body));
      List<History> rs = listHistory.results.toList();
      return rs;
    } else if (response.statusCode == 204 ) {
      List<History> rs = new List<History>();
      return rs;
    } else {
      return null;
    }
  }
}