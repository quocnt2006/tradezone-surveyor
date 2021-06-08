import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class SegmentEvent extends Equatable {}

class LoadListSegments extends SegmentEvent {
  @override
  List<Object> get props => [];
}