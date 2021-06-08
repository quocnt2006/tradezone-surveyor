import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class SystemZoneEvent extends Equatable {}

class LoadNeedSurveySystemZoneMap extends SystemZoneEvent {
  @override
  String toString() => 'LoadNeedSurveySystemZoneMap';

  @override
  List<Object> get props => [];
}

class LoadListSystemZone extends SystemZoneEvent {
  final int districtId;
  final int page;
  final int pageSize;
  final bool isMe;
  LoadListSystemZone({Key key, this.districtId, this.page, this.pageSize, this.isMe});

  @override
  String toString() => 'LoadListSystemZone';

  @override
  List<Object> get props => [districtId, page, pageSize, isMe];
}

class LoadListSystemZoneBuildings extends SystemZoneEvent {
  final int id;
  final int page;
  final int pageSize;
  LoadListSystemZoneBuildings({Key key, this.id, this.page, this.pageSize});

  @override
  String toString() => 'LoadListSystemZoneBuildings';

  @override
  List<Object> get props => [id, page, pageSize];
}

class LoadListSystemZoneStores extends SystemZoneEvent {
  final int id;
  final int page;
  final int pageSize;
  LoadListSystemZoneStores({Key key, this.id, this.page, this.pageSize});

  @override
  String toString() => 'LoadListSystemZoneStores';

  @override
  List<Object> get props => [id, page, pageSize];
}
