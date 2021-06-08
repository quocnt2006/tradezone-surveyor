import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class CityEvent extends Equatable {}

class LoadListDistrict extends CityEvent {
  @override
  String toString() => 'LoadListDistrict';

  @override
  List<Object> get props => [];
}
