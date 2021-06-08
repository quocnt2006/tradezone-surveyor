import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/models/liststreetsegments.dart';

@immutable
abstract class ListStreetSegmentState extends Equatable {}

class LoadInitListStreetSegmentDataState extends ListStreetSegmentState {
  @override
  List<Object> get props => [];
}

class LoadListStreetSegmentDataState extends ListStreetSegmentState {
  @override
  List<Object> get props => [];
}

class LoadListStreetSegmentDataFinishState extends ListStreetSegmentState {
  final ListStreetSegments listStreetSegments;
  LoadListStreetSegmentDataFinishState({Key key, @required this.listStreetSegments});

  @override
  List<Object> get props => [listStreetSegments];
}

class LoadListStreetSegmentByPointDataState extends ListStreetSegmentState {
  @override
  List<Object> get props => [];
}

class LoadListStreetSegmentByPointDataFinishState extends ListStreetSegmentState {
  final ListStreetSegments listStreetSegments;
  LoadListStreetSegmentByPointDataFinishState({Key key, @required this.listStreetSegments});

  @override
  List<Object> get props => [listStreetSegments];
}
