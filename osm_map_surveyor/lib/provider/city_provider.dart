import 'dart:convert';
import 'package:osm_map_surveyor/models/city.dart';
import 'package:osm_map_surveyor/models/district.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'; 
import 'package:http/http.dart' as http;
import 'package:osm_map_surveyor/utilities/base_url.dart';

class CityProvider {
  Future<List<District>> fetchListDistrict() async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("JwtToken");
    final http.Response response = await http.get(
      BaseUrl.wards,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
    );
    if (response.statusCode == 200) {
      City city = new City.fromJson(jsonDecode(response.body)[0]);
      List<District> rs = city.districts.toList();
      return rs;
    } else {
      return null;
    }
  }
}