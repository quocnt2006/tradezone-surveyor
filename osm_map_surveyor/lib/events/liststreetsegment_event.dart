import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import "package:latlong/latlong.dart";

@immutable
abstract class ListStreetSegmentEvent extends Equatable {}

class LoadInitListStreetSegment extends ListStreetSegmentEvent {
  @override
  String toString() => 'LoadInitListStreetSegment';

  @override
  List<Object> get props => [];
}

class LoadListStreetSegment extends ListStreetSegmentEvent {
  final List<LatLng> points;
  LoadListStreetSegment({Key key, @required this.points});
  @override
  String toString() => 'LoadListStreetSegment';

  @override
  List<Object> get props => [points];
}

class LoadListStreetSegmentByPoint extends ListStreetSegmentEvent {
  final LatLng point;
  LoadListStreetSegmentByPoint({Key key, @required this.point});
  @override
  String toString() => 'LoadListStreetSegmentByPoint';

  @override
  List<Object> get props => [point];
}
