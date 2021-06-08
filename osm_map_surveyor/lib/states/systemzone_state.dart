import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/models/listbuildings.dart';
import 'package:osm_map_surveyor/models/liststores.dart';
import 'package:osm_map_surveyor/models/listsystemzone.dart';

@immutable
abstract class SystemZoneState extends Equatable {}

class InitSystemZoneState extends SystemZoneState {
  @override
  List<Object> get props => [];
}

class LoadNeedSurveySystemZoneMapState extends SystemZoneState {
  @override
  List<Object> get props => [];
}

class LoadNeedSurveySystemZoneMapFinishState extends SystemZoneState {
  final String rs;
  LoadNeedSurveySystemZoneMapFinishState({Key key, this.rs});

  @override
  List<Object> get props => [rs];
}

class LoadListSystemZoneState extends SystemZoneState {
  @override
  List<Object> get props => [];
}

class LoadListSystemZoneFinishState extends SystemZoneState {
  final ListSystemZone listSystemZone;
  LoadListSystemZoneFinishState({Key key, this.listSystemZone});

  @override
  List<Object> get props => [listSystemZone];
}

class LoadListSystemZoneIsMeState extends SystemZoneState {
  @override
  List<Object> get props => [];
}

class LoadListSystemZoneIsMeFinishState extends SystemZoneState {
  final ListSystemZone listSystemZone;
  LoadListSystemZoneIsMeFinishState({Key key, this.listSystemZone});

  @override
  List<Object> get props => [listSystemZone];
}

class LoadListSystemZoneBuildingsState extends SystemZoneState {
  @override
  List<Object> get props => [];
}

class LoadListSystemZoneBuildingsFinishState extends SystemZoneState {
  final ListBuildings listBuildings;
  LoadListSystemZoneBuildingsFinishState({Key key, this.listBuildings});

  @override
  List<Object> get props => [listBuildings];
}

class LoadListSystemZoneStoresState extends SystemZoneState {
  @override
  List<Object> get props => [];
}

class LoadListSystemZoneStoresFinishState extends SystemZoneState {
  final ListStores listStores;
  LoadListSystemZoneStoresFinishState({Key key, this.listStores});

  @override
  List<Object> get props => [listStores];
}