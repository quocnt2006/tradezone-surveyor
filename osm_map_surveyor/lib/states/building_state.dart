import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/models/buildinganalysis.dart';
import 'package:osm_map_surveyor/models/buildingtypes.dart';
import 'package:osm_map_surveyor/models/campus.dart';
import 'package:osm_map_surveyor/models/listbuildings.dart';
import 'package:osm_map_surveyor/models/liststreetsegments.dart';

@immutable
abstract class BuildingState extends Equatable {}

class LoadBuildingDataState extends BuildingState {
  @override
  List<Object> get props => [];
}

class LoadInitBuildingDataState extends BuildingState {
  @override
  List<Object> get props => [];
}

class LoadBuildingByFourBoundsDataState extends BuildingState {
  @override
  List<Object> get props => [];
}

class LoadBuildingByFourBoundsFinishDataState extends BuildingState {
  final String rs;
  LoadBuildingByFourBoundsFinishDataState({Key key, this.rs});

  @override
  List<Object> get props => [rs];
}

class LoadCampusDataState extends BuildingState {
  @override
  List<Object> get props => [];
}

class LoadCampusFinishDataState extends BuildingState {
  final String rs;
  LoadCampusFinishDataState({Key key, this.rs});

  @override
  List<Object> get props => [rs];
}

class LoadBuildingDetailsByIdState extends BuildingState {
  @override
  List<Object> get props => [];
}

class LoadBuildingDetailsByIdFinishState extends BuildingState {
  final Building building;
  LoadBuildingDetailsByIdFinishState({Key key, this.building});

  @override
  List<Object> get props => [];
}

class LoadBuildingListTypesState extends BuildingState {
  @override
  List<Object> get props => [];
}

class LoadBuildingListTypesFinishState extends BuildingState {
  final List<BuildingType> listTypes;
  LoadBuildingListTypesFinishState({Key key, @required this.listTypes});

  @override
  List<Object> get props => [listTypes];
}

class LoadBuildingCampusState extends BuildingState {
  @override
  List<Object> get props => [];
}

class LoadBuildingCampusFinishState extends BuildingState {
  final Campus campus;
  LoadBuildingCampusFinishState({Key key, @required this.campus});

  @override
  List<Object> get props => [campus];
}

class AddBuildingState extends BuildingState {
  @override
  List<Object> get props => [];
}

class AddBuildingSucessState extends BuildingState {
  final bool isSuccess;
  AddBuildingSucessState({Key key, @required this.isSuccess});

  @override
  List<Object> get props => [isSuccess];
}

class DeleteBuildingState extends BuildingState {
  @override
  List<Object> get props => [];
}

class DeleteBuildingSucessState extends BuildingState {
  final bool isSuccess;
  DeleteBuildingSucessState({Key key, @required this.isSuccess});

  @override
  List<Object> get props => [isSuccess];
}


class UpdateBuildingState extends BuildingState {
  @override
  List<Object> get props => [];
}

class UpdateBuildingSucessState extends BuildingState {
  final Building building;
  UpdateBuildingSucessState({Key key, @required this.building});
  
  @override
  List<Object> get props => [building];
}

class LoadNeedSurveyBuildingsState extends BuildingState {
  @override
  List<Object> get props => [];
}

class LoadNeedSurveyBuildingsFinishState extends BuildingState {
  final ListBuildings listBuildings;
  LoadNeedSurveyBuildingsFinishState({Key key, @required this.listBuildings});

  @override
  List<Object> get props => [listBuildings];
}

class LoadListStreetSegmentsByBuildingIdState extends BuildingState {
  @override
  List<Object> get props => [];
}

class LoadListStreetSegmentsByBuildingIdFinishState extends BuildingState {
  final ListStreetSegments listStreetSegments;
  LoadListStreetSegmentsByBuildingIdFinishState({Key key, @required this.listStreetSegments});

  @override
  List<Object> get props => [listStreetSegments];
}

class LoadListNeedSurveyBuildingsMapState extends BuildingState {
  @override
  List<Object> get props => [];
}

class LoadListNeedSurveyBuildingsMapFinishState extends BuildingState {
  final String rs;
  LoadListNeedSurveyBuildingsMapFinishState({Key key, this.rs});

  @override
  List<Object> get props => [rs];
}

class SaveBuildingAnalysisState extends BuildingState {
  @override
  List<Object> get props => [];
}

class SaveBuildingAnalysisFinishState extends BuildingState {
  final BuildingAnalysis buildingAnalysis;
  SaveBuildingAnalysisFinishState({Key key, this.buildingAnalysis});

  @override
  List<Object> get props => [buildingAnalysis];
}

class LoadListBuildingAnalysisState extends BuildingState {
  @override
  List<Object> get props => [];
}

class LoadListBuildingAnalysisFinishState extends BuildingState {
  final List<BuildingAnalysis> listBuildingAnalysis;
  LoadListBuildingAnalysisFinishState({Key key, this.listBuildingAnalysis});

  @override
  List<Object> get props => [listBuildingAnalysis];
}

class DeleteBuildingAnalysisState extends BuildingState {
  @override
  List<Object> get props => [];
}

class UpdateBuildingAnalysisState extends BuildingState {
  @override
  List<Object> get props => [];
}

class UpdateBuildingAnalysisFinishState extends BuildingState {
  final BuildingAnalysis buildingAnalysis;
  UpdateBuildingAnalysisFinishState({Key key, this.buildingAnalysis});
  
  @override
  List<Object> get props => [buildingAnalysis];
}
