import "package:latlong/latlong.dart" as latLng;
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/models/buildinganalysis.dart';
import 'package:osm_map_surveyor/models/buildingpost.dart';
import 'package:osm_map_surveyor/models/buildingtypes.dart';
import 'package:osm_map_surveyor/models/campus.dart';
import 'package:osm_map_surveyor/models/listbuildings.dart';
import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/provider/building_provider.dart';

class BuildingRepository {
  BuildingProvider _buildingProvider = BuildingProvider();

  Future<String> fetchBuildingByFourBounds(
    latLng.LatLng northWest,
    latLng.LatLng northEast,
    latLng.LatLng southEast, 
    latLng.LatLng southWest) async {
    return await _buildingProvider.fetchBuildingByFourBounds(northWest, northEast, southEast, southWest);
  }

  Future<Building> fetchBuildingById(int id) async {
    return await _buildingProvider.fetchBuildingById(id);
  }

  Future<bool> addBuilding(BuildingPost building) async {
    return await _buildingProvider.addBuilding(building);
  }

  Future<List<BuildingType>> fetchListBuildingTypes() async {
    return await _buildingProvider.fetchListBuildingTypes();
  }

  Future<Campus> fetchCampus(String geomBuilding) async {
    return await _buildingProvider.fetchCampus(geomBuilding);
  }

  Future<ListBuildings> fetchNeedSurveyBuildings() async {
    return await _buildingProvider.fetchNeedSurveyBuildings();
  }

  Future<ListStreetSegments> fetchListStreetSegmentByBuildingId(int id) async {
    return await _buildingProvider.fetchListStreetSegmentsByBuildingId(id);
  }

  Future<Building> fetchUpdateBuilding(BuildingPost building) async {
    return await _buildingProvider.fetchUpdateBuilding(building);
  }

  Future<bool> deleteBuildingById(int id) async {
    return await _buildingProvider.deleteBuildingById(id);
  }

  Future<String> fetchNeedSurveyBuildingsMap() async {
    return await _buildingProvider.fetchNeedSurveyBuildingsMap();
  }

  Future<BuildingAnalysis> saveBuildingAnalysis(BuildingAnalysis buildingAnalysis) async {
    return await _buildingProvider.saveBuildingAnalysis(buildingAnalysis);
  }

  Future<List<BuildingAnalysis>> fetchListBuildingAnalysis(int id) async {
    return await _buildingProvider.fetchListBuildingAnalysis(id);
  }

  Future<BuildingAnalysis> deleteBuildingAnalysis(int buildingId, int categoryId) async {
    return await _buildingProvider.deleteBuildingAnalysis(buildingId, categoryId);
  }

  Future<BuildingAnalysis> updateBuildingAnalysis(BuildingAnalysis buildingAnalysis) async {
    return await _buildingProvider.updateBuildingAnalysis(buildingAnalysis);
  }

  Future<String> fetchCampusMap() async {
    return await _buildingProvider.fetchCampusMap();
  }
}
