import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_map_surveyor/events/building_event.dart';
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/models/buildinganalysis.dart';
import 'package:osm_map_surveyor/models/buildingpost.dart';
import 'package:osm_map_surveyor/models/buildingtypes.dart';
import 'package:osm_map_surveyor/models/campus.dart';
import 'package:osm_map_surveyor/models/listbuildings.dart';
import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/repositories/building_repository.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:osm_map_surveyor/states/building_state.dart';

class BuildingBloc extends Bloc<BuildingEvent, BuildingState> {
  BuildingRepository _buildingRepository = BuildingRepository();
  BuildingBloc({@required BuildingRepository buildingRepository}) : assert(BuildingRepository != null),
    _buildingRepository = buildingRepository;

  // building on map controller
  final _buildingFourBoundsController = StreamController<String>();
  StreamSink<String> get buildingFourboundsSink => _buildingFourBoundsController.sink;
  Stream<String> get buildingFourboundsStream => _buildingFourBoundsController.stream;
  Stream<BuildingState> getBuildingByFourBounds(
    latLng.LatLng northWest, 
    latLng.LatLng northEast,
    latLng.LatLng southEast,
    latLng.LatLng southWest) async* {
    final rs = await _buildingRepository.fetchBuildingByFourBounds(northWest, northEast, southEast, southWest);
    buildingFourboundsSink.add(rs);
    yield LoadBuildingByFourBoundsDataState();
    yield LoadBuildingByFourBoundsFinishDataState(rs: rs);
  }

  // building details controller
  final _buildingDetailsController = StreamController<Building>();
  StreamSink<Building> get buildingDetailsSink => _buildingDetailsController.sink;
  Stream<Building> get buildingDetailsStream => _buildingDetailsController.stream;
  Stream<BuildingState> getBuildingDetailsById(int id) async* {
    final rs = await _buildingRepository.fetchBuildingById(id);
    buildingDetailsSink.add(rs);
    yield LoadBuildingDetailsByIdState();
    yield LoadBuildingDetailsByIdFinishState(building: rs);
  }

  // building add new controller
  final _addBuildingController = StreamController<bool>();
  StreamSink<bool> get addBuildingSink => _addBuildingController.sink;
  Stream<bool> get addBuildingStream => _addBuildingController.stream;
  Stream<BuildingState> addBuilding(BuildingPost building) async* {
    final rs = await _buildingRepository.addBuilding(building);
    yield AddBuildingState();
    yield AddBuildingSucessState(isSuccess: rs);
  }

  // building types controller
  final _listBuildingTypesController = StreamController<List<BuildingType>>();
  StreamSink<List<BuildingType>> get listBuildingTypesSink => _listBuildingTypesController.sink;
  Stream<List<BuildingType>> get listBuildingTypesStream => _listBuildingTypesController.stream;
  Stream<BuildingState> getBuildingListTypes() async* {
    final rs = await _buildingRepository.fetchListBuildingTypes();
    listBuildingTypesSink.add(rs);
    yield LoadBuildingListTypesState();
    yield LoadBuildingListTypesFinishState(listTypes: rs);
  }

  // building campus controller
  final _buildingCampusController = StreamController<Campus>();
  StreamSink<Campus> get buildingCampusSink => _buildingCampusController.sink;
  Stream<Campus> get buildingCampusStream => _buildingCampusController.stream;
  Stream<BuildingState> getBuildingCampus(String geomBuilding) async* {
    final rs = await _buildingRepository.fetchCampus(geomBuilding);
    buildingCampusSink.add(rs);
    yield LoadBuildingCampusState();
    yield LoadBuildingCampusFinishState(campus: rs);
  }

  // list need survey buildings controller
  final _listNeedSurveyBuildingsController = StreamController<ListBuildings>();
  StreamSink<ListBuildings> get listNeedSurveyBuildingsSink => _listNeedSurveyBuildingsController.sink;
  Stream<ListBuildings> get listNeedSurveyBuildingsStream => _listNeedSurveyBuildingsController.stream;
  Stream<BuildingState> getListNeedSurveyBuildings() async* {
    final rs = await _buildingRepository.fetchNeedSurveyBuildings();
    listNeedSurveyBuildingsSink.add(rs);
    yield LoadNeedSurveyBuildingsState();
    yield LoadNeedSurveyBuildingsFinishState(listBuildings: rs);
  }

  // list street segments by building id controller
  final _listStreetSegmentsByBuildingIdController = StreamController<ListStreetSegments>();
  StreamSink<ListStreetSegments> get listStreetSegmentsByBuildingIdSink => _listStreetSegmentsByBuildingIdController.sink;
  Stream<ListStreetSegments> get listStreetSegmentsByBuildingIdStream => _listStreetSegmentsByBuildingIdController.stream;
  Stream<BuildingState> getListStreetSegmenntsByBuildingId(int id) async* {
    final rs = await _buildingRepository.fetchListStreetSegmentByBuildingId(id);
    listStreetSegmentsByBuildingIdSink.add(rs);
    yield LoadListStreetSegmentsByBuildingIdState();
    yield LoadListStreetSegmentsByBuildingIdFinishState(listStreetSegments: rs);
  }

  // building update controller
  final _updateBuildingController = StreamController<Building>();
  StreamSink<Building> get updateBuildingSink => _updateBuildingController.sink;
  Stream<Building> get updateBuildingStream => _updateBuildingController.stream;
  Stream<BuildingState> updateBuilding(BuildingPost building) async* {
    final rs = await _buildingRepository.fetchUpdateBuilding(building);
    yield UpdateBuildingState();
    yield UpdateBuildingSucessState(building: rs);
  }

  // delete building controller
  final _deleteBuildingController = StreamController<bool>();
  StreamSink<bool> get deleteBuildingSink => _deleteBuildingController.sink;
  Stream<bool> get deleteBuildingStream => _deleteBuildingController.stream;
  Stream<BuildingState> deleteBuilding(int id) async* {
    final rs = await _buildingRepository.deleteBuildingById(id);
    yield DeleteBuildingState();
    yield DeleteBuildingSucessState(isSuccess: rs);
  }

  // list need survey buidings on map controller
  final _listNeedSurveyBuildingsMapController = StreamController<String>();
  StreamSink<String> get listNeedSurveyBuildingsMapSink => _listNeedSurveyBuildingsMapController.sink;
  Stream<String> get listNeedSurveyBuildingsMapStream => _listNeedSurveyBuildingsMapController.stream;
  Stream<BuildingState> fetchListNeedSurveyBuildingsMap() async* {
    final rs = await _buildingRepository.fetchNeedSurveyBuildingsMap();
    yield LoadListNeedSurveyBuildingsMapState();
    yield LoadListNeedSurveyBuildingsMapFinishState(rs: rs);
  }
  
  // save building analysis controller
  final _saveBuildingAnalysisController = StreamController<BuildingAnalysis>();
  StreamSink<BuildingAnalysis> get saveBuildingAnalysisSink => _saveBuildingAnalysisController.sink;
  Stream<BuildingAnalysis> get saveBuildingAnalysisStream => _saveBuildingAnalysisController.stream;
  Stream<BuildingState> saveBuildingAnalysis(BuildingAnalysis buildingAnalysis) async* {
    final rs = await _buildingRepository.saveBuildingAnalysis(buildingAnalysis);
    yield SaveBuildingAnalysisState();
    yield SaveBuildingAnalysisFinishState(buildingAnalysis: rs);
  }

  // get list building analysis by building id
  final _getListBuildingAnalysisController = StreamController<List<BuildingAnalysis>>();
  StreamSink<List<BuildingAnalysis>> get getListBuildingAnalysisSink => _getListBuildingAnalysisController.sink;
  Stream<List<BuildingAnalysis>> get getListBuildingAnalysisStream => _getListBuildingAnalysisController.stream;
  Stream<BuildingState> getListBuildingAnalysis(int id) async* {
    final rs = await _buildingRepository.fetchListBuildingAnalysis(id);
    yield LoadListBuildingAnalysisState();
    yield LoadListBuildingAnalysisFinishState(listBuildingAnalysis: rs);
  }

  // delete building analysis by building id, category id
  final _deleteBuildingAnalysisByIdController = StreamController<BuildingAnalysis>();
  StreamSink<BuildingAnalysis> get deleteBuildingAnalysisByIdSink => _deleteBuildingAnalysisByIdController.sink;
  Stream<BuildingAnalysis> get deleteBuildingAnalysisByIdStream => _deleteBuildingAnalysisByIdController.stream;
  Stream<BuildingState> deleteBuildingAnalysisById(int buildingId, int categoryId) async* {
    await _buildingRepository.deleteBuildingAnalysis(buildingId, categoryId);
    yield DeleteBuildingAnalysisState();
  }

  // update building analysis controller
  final _updateBuildingAnalysisController = StreamController<BuildingAnalysis>();
  StreamSink<BuildingAnalysis> get updateBuildingAnalysisSink => _updateBuildingAnalysisController.sink;
  Stream<BuildingAnalysis> get updateBuildingAnalysisStream => _updateBuildingAnalysisController.stream;
  Stream<BuildingState> updateBuildingAnalysis(BuildingAnalysis buildingAnalysis) async* {
    final rs = await _buildingRepository.updateBuildingAnalysis(buildingAnalysis);
    yield UpdateBuildingAnalysisState();
    yield UpdateBuildingAnalysisFinishState(buildingAnalysis: rs);
  }

  // campus on map controller
  final _campusFourBoundsController = StreamController<String>();
  StreamSink<String> get campusFourboundsSink => _campusFourBoundsController.sink;
  Stream<String> get campusFourboundsStream => _campusFourBoundsController.stream;
  Stream<BuildingState> getCampusMap() async* {
    final rs = await _buildingRepository.fetchCampusMap();
    campusFourboundsSink.add(rs);
    yield LoadCampusDataState();
    yield LoadCampusFinishDataState(rs: rs);
  }

  @override
  BuildingState get initialState => LoadInitBuildingDataState();

  @override
  Future<void> close() {
    _addBuildingController.close();
    _buildingFourBoundsController.close();
    _buildingDetailsController.close();
    _listBuildingTypesController.close();
    _buildingCampusController.close();
    _listNeedSurveyBuildingsController.close();
    _listStreetSegmentsByBuildingIdController.close();
    _updateBuildingController.close();
    _deleteBuildingController.close();
    _listNeedSurveyBuildingsMapController.close();
    _saveBuildingAnalysisController.close();
    _getListBuildingAnalysisController.close();
    _deleteBuildingAnalysisByIdController.close();
    _updateBuildingAnalysisController.close();
    _campusFourBoundsController.close();
    return super.close();
  }

  @override
  Stream<BuildingState> mapEventToState(BuildingEvent event) async* {
    if (event is LoadBuildingByFourBounds) {
      yield* getBuildingByFourBounds(event.northWest, event.northEast, event.southEast, event.southWest);
    } else if (event is LoadBuildingDetailsById) {
      yield* getBuildingDetailsById(event.id);
    } else if (event is AddBuilding) {
      yield* addBuilding(event.building);
    } else if (event is LoadListBuildingTypes) {
      yield* getBuildingListTypes();
    } else if (event is LoadBuildingCampus) {
      yield* getBuildingCampus(event.geomBuilding);
    } else if (event is LoadNeedSurveyBuildings) {
      yield* getListNeedSurveyBuildings();
    } else if (event is LoadListStreetSegmentsByBuildingId) {
      yield* getListStreetSegmenntsByBuildingId(event.id);
    } else if (event is UpdateBuilding) {
      yield* updateBuilding(event.building);
    } else if (event is DeleteBuilding) {
      yield* deleteBuilding(event.id);
    } else if (event is LoadListNeedSurveyBuildingsMap) {
      yield* fetchListNeedSurveyBuildingsMap();
    } else if (event is SaveBuildingAnalysis) {
      yield* saveBuildingAnalysis(event.buildingAnalysis);
    } else if (event is LoadListBuildingAnalysis) {
      yield* getListBuildingAnalysis(event.id);
    } else if (event is DeleteBuildingAnalysis) {
      yield* deleteBuildingAnalysisById(event.buildingId, event.categoryId);
    } else if (event is UpdateBuildingAnalysis) {
      yield* updateBuildingAnalysis(event.buildingAnalysis);
    } else if (event is LoadCampus) {
      yield* getCampusMap();
    }
  }
}
