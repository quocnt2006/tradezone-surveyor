import 'package:osm_map_surveyor/models/district.dart';
import 'package:osm_map_surveyor/provider/city_provider.dart';

class CityRepository {
  CityProvider _cityProvider = CityProvider();
  
  Future<List<District>> fetchListDistrict() async {
    return await _cityProvider.fetchListDistrict();
  }
}