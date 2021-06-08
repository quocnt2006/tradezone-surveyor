import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/models/district.dart';

@immutable
abstract class CityState extends Equatable {}

class LoadInitCityState extends CityState {
  @override
  List<Object> get props => [];
}

class LoadListDistrictState extends CityState {
  @override
  List<Object> get props => [];
}

class LoadListDistrictFinishState extends CityState {
  final List<District> listDistrict;
  LoadListDistrictFinishState({Key key, this.listDistrict});
  
  @override
  List<Object> get props => [listDistrict];
}