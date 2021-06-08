import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:meta/meta.dart';
import 'package:osm_map_surveyor/models/storepost.dart';

@immutable
abstract class StoreEvent extends Equatable {
  
}

class LoadStores extends StoreEvent {
  @override
  String toString() => 'LoadStores';

  @override
  List<Object> get props => [];
}

class LoadInitStores extends StoreEvent {
  @override
  String toString() => 'LoadInitStores';

  @override
  List<Object> get props => [];
}

class LoadStoresByFourBounds extends StoreEvent {
  final LatLng northWest;
  final LatLng northEast;
  final LatLng southWest;
  final LatLng southEast;
  LoadStoresByFourBounds(
      {Key key,
      @required this.northWest,
      @required this.northEast,
      @required this.southEast,
      @required this.southWest});
  @override
  String toString() => 'LoadStoresByFourBounds';

  @override
  List<Object> get props => [northWest, northEast, southWest, southEast];
}

class AddStore extends StoreEvent {
  final StorePost store;
  AddStore({Key key, this.store});
  @override
  String toString() => 'AddStore';

  @override
  List<Object> get props => [store];
}

class LoadListStoreBuildings extends StoreEvent {
  final LatLng point;
  LoadListStoreBuildings({Key key, this.point});
  @override
  String toString() => 'LoadListStoreBuildings';

  @override
  List<Object> get props => [point];
}

class LoadNeedSurveyStores extends StoreEvent {
  @override
  String toString() => 'LoadNeedSurveyBuilding';

  @override
  List<Object> get props => [];
}

class LoadListStreetSegmentsByStoreId extends StoreEvent {
  final int id;
  LoadListStreetSegmentsByStoreId({Key key, @required this.id});
  @override
  String toString() => 'LoadListStreetSegmentsByStoreId';

  @override
  List<Object> get props => [id];
}

class UpdateStore extends StoreEvent {
  final StorePost store;
  UpdateStore({Key key, this.store});
  @override
  String toString() => 'AddStore';

  @override
  List<Object> get props => [store];
}

class DeleteStore extends StoreEvent {
  final int id;
  DeleteStore({Key key, this.id});

  @override
  String toString() => 'DeleteStore';

  @override
  List<Object> get props => [id];
}

class LoadStoreById extends StoreEvent {
  final int id;
  LoadStoreById({Key key, this.id});

  @override
  String toString() => 'LoadStoreById';


  @override
  List<Object> get props => [id];
}

class LoadListNeedSurveyStoresMap extends StoreEvent {
  @override
  String toString() => 'LoadListNeedSurveyStoresMap';

  @override
  List<Object> get props => [];
}

class LoadCheckStoreLocation extends StoreEvent {
  final LatLng point;
  LoadCheckStoreLocation({Key key, this.point});
  
  @override
  String toString() => 'LoadCheckStoreLocation';

  @override
  List<Object> get props => [point];
}