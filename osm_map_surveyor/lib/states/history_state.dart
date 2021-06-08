import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/models/history.dart';

@immutable
abstract class HistoryState extends Equatable {}

class LoadInitHistoryState extends HistoryState {
  @override
  List<Object> get props => [];
}

class LoadListHistoryState extends HistoryState {
  @override
  List<Object> get props => [];
}

class LoadListHistoryFinishState extends HistoryState {
  final List<History> listHistory;
  LoadListHistoryFinishState({Key key, this.listHistory});

  @override
  List<Object> get props => [listHistory];
}