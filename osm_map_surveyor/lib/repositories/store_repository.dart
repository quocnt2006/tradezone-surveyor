import 'package:geodesy/geodesy.dart';
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/models/liststores.dart';
import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/models/store.dart';
import 'package:osm_map_surveyor/models/storepost.dart';
import 'package:osm_map_surveyor/provider/store_provider.dart';

class StoreRepository {
  StoreProvider _storeProvider = StoreProvider();

  Future<String> fetchStoresByFourBounds(
    LatLng northWest,
    LatLng northEast,
    LatLng southEast,
    LatLng southWest) async {
    return await _storeProvider.fetchStoresByFourBounds(northWest, northEast, southEast, southWest);
  }

  Future<List<Building>> fetchListBuildings(LatLng point) async {
    return await _storeProvider.fetchListBuildings(point);
  }

  Future<bool> addStore(StorePost store) async {
    return await _storeProvider.addStore(store);
  }

  Future<ListStores> fetchNeedSurveyStores() async {
    return await _storeProvider.fetchNeedSurveyStores();
  }

  Future<ListStreetSegments> fetchListStreetSegmentByStoreId(int id) async {
    return await _storeProvider.fetchListStreetSegmentsByStoreId(id);
  }

  Future<bool> updateStore(StorePost store) async {
    return await _storeProvider.updateStore(store);
  }

  Future<bool> deleteStoreById(int id) async {
    return await _storeProvider.deleteStoreById(id);
  }

  Future<Store> fetchStoreById(int id) async {
    return await _storeProvider.fetchStoreById(id);
  }

  Future<String> fetchNeedSurveyStoresMap() async {
    return await _storeProvider.fetchNeedSurveyStoresMap();
  }

  Future<bool> checkStoreLocation(LatLng latlng) async {
    return await _storeProvider.checkStoreLocation(latlng);
  }
}
