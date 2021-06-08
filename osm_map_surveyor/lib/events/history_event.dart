import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class HistoryEvent extends Equatable {}

class LoadListHistory extends HistoryEvent {
  @override
  String toString() => 'LoadListHistory';

  @override
  List<Object> get props => [];
}