import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_map_surveyor/events/systemzone_event.dart';
import 'package:osm_map_surveyor/models/listbuildings.dart';
import 'package:osm_map_surveyor/models/liststores.dart';
import 'package:osm_map_surveyor/models/listsystemzone.dart';
import 'package:osm_map_surveyor/repositories/systemzone_repository.dart';
import 'package:osm_map_surveyor/states/systemzone_state.dart';

class SystemZoneBloc extends Bloc<SystemZoneEvent, SystemZoneState> {
  SystemZoneRepository _systemZoneRepository = SystemZoneRepository();
  SystemZoneBloc({@required SystemZoneRepository systemZoneRepository}) : assert(SystemZoneRepository != null),
    _systemZoneRepository = systemZoneRepository;
  
  // need survey system zone on Map
  final _needSurveySystemZoneMapController = StreamController<String>();
  StreamSink<String> get needSurveySystemZoneMapSink => _needSurveySystemZoneMapController.sink;
  Stream<String> get needSurveySystemZoneMapStream => _needSurveySystemZoneMapController.stream;
  Stream<SystemZoneState> getNeedSurveySystemZoneMap() async * {
    final rs = await _systemZoneRepository.fetchNeedSurveySystemZoneMap();
    yield LoadNeedSurveySystemZoneMapState();
    yield LoadNeedSurveySystemZoneMapFinishState(rs: rs);
  }

  // get list system zone
  final _getListSystemZoneController = StreamController<ListSystemZone>();
  StreamSink<ListSystemZone> get listSystemZoneSink => _getListSystemZoneController.sink;
  Stream<ListSystemZone> get listSystemZoneStream => _getListSystemZoneController.stream;
  Stream<SystemZoneState> getListSystemZone(int districtId, int page, int pageSize, bool isMe) async* {
    final rs = await _systemZoneRepository.getListSystemZone(districtId, page, pageSize, isMe);
    if (isMe != null) {
      if (isMe) {
        yield LoadListSystemZoneIsMeState();
        yield LoadListSystemZoneIsMeFinishState(listSystemZone: rs);
      }
    } else {
      yield LoadListSystemZoneState();
      yield LoadListSystemZoneFinishState(listSystemZone: rs);
    }
  }

  // get list system zone buildings
  final _getListSystemZoneBuildingsController = StreamController<ListBuildings>();
  StreamSink<ListBuildings> get listSystemZoneBuildingsSink => _getListSystemZoneBuildingsController.sink;
  Stream<ListBuildings> get listSystemZoneBuildingsStream => _getListSystemZoneBuildingsController.stream;
  Stream<SystemZoneState> getListSystemZoneBuildings(int id, int page, int pageSize) async* {
    final rs = await _systemZoneRepository.getListSystemZoneBuilding(id, page, pageSize);
    yield LoadListSystemZoneBuildingsState();
    yield LoadListSystemZoneBuildingsFinishState(listBuildings: rs);
  }

  // get list system zone stores
  final _getListSystemZoneStoresController = StreamController<ListStores>();
  StreamSink<ListStores> get listSystemZoneStoresSink => _getListSystemZoneStoresController.sink;
  Stream<ListStores> get listSystemZoneStoresStream => _getListSystemZoneStoresController.stream;
  Stream<SystemZoneState> getListSystemZoneStores(int id, int page, int pageSize) async* {
    final rs = await _systemZoneRepository.getListSystemZoneStores(id, page, pageSize);
    yield LoadListSystemZoneStoresState();
    yield LoadListSystemZoneStoresFinishState(listStores: rs);
  }

  @override
  Future<void> close() {
    _needSurveySystemZoneMapController.close();
    _getListSystemZoneController.close();
    _getListSystemZoneBuildingsController.close();
    _getListSystemZoneStoresController.close();
    return super.close();
  }

  @override
  get initialState => InitSystemZoneState();

  @override
  Stream<SystemZoneState> mapEventToState(SystemZoneEvent event) async* {
    if (event is LoadNeedSurveySystemZoneMap) {
      yield* getNeedSurveySystemZoneMap();
    } else if (event is LoadListSystemZone) {
      yield* getListSystemZone(event.districtId, event.page, event.pageSize, event.isMe);
    } else if (event is LoadListSystemZoneBuildings) {
      yield* getListSystemZoneBuildings(event.id, event.page, event.pageSize);
    } else if (event is LoadListSystemZoneStores) {
      yield* getListSystemZoneStores(event.id, event.page, event.pageSize);
    }
  }
}