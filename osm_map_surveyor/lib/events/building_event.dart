import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:osm_map_surveyor/models/buildinganalysis.dart';
import 'package:osm_map_surveyor/models/buildingpost.dart';

@immutable
abstract class BuildingEvent extends Equatable {}

class LoadBuilding extends BuildingEvent {
  @override
  String toString() => 'LoadBuilding';

  @override
  List<Object> get props => [];
}

class LoadInitBuilding extends BuildingEvent {
  @override
  String toString() => 'LoadInitBuilding';

  @override
  List<Object> get props => [];
}

class LoadListBuildingTypes extends BuildingEvent {
  @override
  String toString() => 'LoadListBuildingTypes';

  @override
  List<Object> get props => [];
}

class LoadBuildingCampus extends BuildingEvent {
  final String geomBuilding;
  LoadBuildingCampus({Key key, @required this.geomBuilding});
  @override
  String toString() => 'LoadBuildingCampus';

  @override
  List<Object> get props => [geomBuilding];
}

class AddBuilding extends BuildingEvent {
  final BuildingPost building;
  AddBuilding({Key key, @required this.building});
  @override
  String toString() => 'AddBuilding';

  @override
  List<Object> get props => [building];
}

class DeleteBuilding extends BuildingEvent {
  final int id;
  DeleteBuilding({Key key, @required this.id});
  @override
  String toString() => 'DeleteBuilding';

  @override
  List<Object> get props => [id];
}

class UpdateBuilding extends BuildingEvent {
  final BuildingPost building;
  UpdateBuilding({Key key, @required this.building});
  @override
  String toString() => 'UpdateBuilding';

  @override
  List<Object> get props => [building];
}

class LoadBuildingByFourBounds extends BuildingEvent {
  final latLng.LatLng northWest;
  final latLng.LatLng northEast;
  final latLng.LatLng southWest;
  final latLng.LatLng southEast;
  LoadBuildingByFourBounds(
      {Key key,
      @required this.northWest,
      @required this.northEast,
      @required this.southEast,
      @required this.southWest});
  @override
  String toString() => 'LoadBuildingByFourBounds';

  @override
  List<Object> get props => [northWest, northEast, southWest, southEast];
}

class LoadCampus extends BuildingEvent {
  @override
  String toString() => 'LoadCampus';

  @override
  List<Object> get props => [];
}

class LoadBuildingDetailsById extends BuildingEvent {
  final int id;
  LoadBuildingDetailsById({Key key, @required this.id});
  @override
  String toString() => 'LoadBuildingDetailsById';

  @override
  List<Object> get props => [id];
}

class LoadNeedSurveyBuildings extends BuildingEvent {
  @override
  String toString() => 'LoadNeedSurveyBuildings';

  @override
  List<Object> get props => [];
}

class LoadListStreetSegmentsByBuildingId extends BuildingEvent {
  final int id;
  LoadListStreetSegmentsByBuildingId({Key key, @required this.id});

  @override
  String toString() => 'LoadListStreetSegmentsByBuildingId';

  @override
  List<Object> get props => [id];
}

class LoadListNeedSurveyBuildingsMap extends BuildingEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'LoadListNeedSurveyBuildingsMap';
}

class SaveBuildingAnalysis extends BuildingEvent {
  final BuildingAnalysis buildingAnalysis;
  SaveBuildingAnalysis({Key key, this.buildingAnalysis});

  @override
  List<Object> get props => [buildingAnalysis];

  @override
  String toString() => 'SaveBuildingAnalysis';
}

class LoadListBuildingAnalysis extends BuildingEvent {
  final int id;
  LoadListBuildingAnalysis({Key key, this.id});

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'LoadListBuildingAnalysis';
}

class DeleteBuildingAnalysis extends BuildingEvent {
  final int buildingId;
  final int categoryId;
  DeleteBuildingAnalysis({Key key, this.buildingId, this.categoryId});

  @override
  List<Object> get props => [buildingId, categoryId];

  @override
  String toString() => 'DeleteBuildingAnalysis';
}

class UpdateBuildingAnalysis extends BuildingEvent {
  final BuildingAnalysis buildingAnalysis;
  UpdateBuildingAnalysis({Key key, this.buildingAnalysis});

  @override
  List<Object> get props => [buildingAnalysis];

  @override
  String toString() => 'UpdateBuildingAnalysis';
}