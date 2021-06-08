import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/models/segment.dart';

@immutable
abstract class SegmentState extends Equatable {}

class LoadInitSegmentState extends SegmentState {
  @override
  List<Object> get props => [];
}

class LoadListSegmentsState extends SegmentState {
  @override
  List<Object> get props => [];
}

class LoadListSegmentsFinishState extends SegmentState {
  final List<Segment> listSegments;
  LoadListSegmentsFinishState({Key key, this.listSegments});
  @override
  List<Object> get props => [listSegments];
}