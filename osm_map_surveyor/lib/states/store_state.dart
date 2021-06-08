import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/models/liststores.dart';
import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/models/store.dart';

@immutable
abstract class StoreState extends Equatable {}

class LoadStoreDataState extends StoreState {
  @override
  List<Object> get props => [];
}

class LoadInitStoreDataState extends StoreState {
  @override
  List<Object> get props => [];
}

class LoadStoreByFourBoundsDataState extends StoreState {
  @override
  List<Object> get props => [];
}

class LoadStoreByFourBoundsDataFinishState extends StoreState {
  final String rs;
  LoadStoreByFourBoundsDataFinishState({Key key, this.rs});

  @override
  List<Object> get props => [rs];
}

class LoadListStoreBuildingsState extends StoreState {
  @override
  List<Object> get props => [];
}

class LoadListStoreBuildingsFinishState extends StoreState {
  final List<Building> listBuildings;
  LoadListStoreBuildingsFinishState({Key key, this.listBuildings});

  @override
  List<Object> get props => [listBuildings];
}

class AddStoreState extends StoreState {
  @override
  List<Object> get props => [];
}

class AddStoreSucessState extends StoreState {
  final bool isSuccess;
  AddStoreSucessState({Key key, this.isSuccess});

  @override
  List<Object> get props => [isSuccess];
}

class LoadNeedSurveyStoresState extends StoreState {
  @override
  List<Object> get props => [];
}

class LoadNeedSurveyStoresFinishState extends StoreState {
  final ListStores listStores;
  LoadNeedSurveyStoresFinishState({Key key, this.listStores});

  @override
  List<Object> get props => [listStores];
}

class LoadListStreetSegmentsByStoreIdState extends StoreState {
  @override
  List<Object> get props => [];
}

class LoadListStreetSegmentsByStoreIdFinishState extends StoreState {
  final ListStreetSegments listStreetSegments;
  LoadListStreetSegmentsByStoreIdFinishState({Key key, @required this.listStreetSegments});

  @override
  List<Object> get props => [listStreetSegments];
}

class UpdateStoreState extends StoreState {
  @override
  List<Object> get props => [];
}

class UpdateStoreSucessState extends StoreState {
  final bool isSuccess;
  UpdateStoreSucessState({Key key, this.isSuccess});

  @override
  List<Object> get props => [isSuccess];
}

class DeleteStoreState extends StoreState{
  @override
  List<Object> get props => [];
}

class DeleteStoreSucessState extends StoreState {
  final bool isSuccess;
  DeleteStoreSucessState({Key key, this.isSuccess});

  @override
  List<Object> get props => [isSuccess];
}

class LoadStoreByIdState extends StoreState {
  @override
  List<Object> get props => [];
}

class LoadStoreByIdFinishState extends StoreState {
  final Store store;
  LoadStoreByIdFinishState({Key key, this.store});
  @override
  List<Object> get props => [store];
}

class LoadListNeedSurveyStoresMapState extends StoreState {
  @override
  List<Object> get props => [];
}

class LoadListNeedSurveyStoresMapFinishState extends StoreState {
  final String rs;
  LoadListNeedSurveyStoresMapFinishState({Key key, this.rs});
  
  @override
  List<Object> get props => [rs];
}

class LoadCheckStoreLocationState extends StoreState {
  @override
  List<Object> get props => [];
}

class LoadCheckStoreLocationFinishState extends StoreState {
  final bool rs;
  LoadCheckStoreLocationFinishState({Key key, this.rs});
  
  @override
  List<Object> get props => [rs];
}