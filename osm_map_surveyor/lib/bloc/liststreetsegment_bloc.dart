import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_map_surveyor/events/liststreetsegment_event.dart';
import "package:latlong/latlong.dart";
import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/repositories/liststreetsegment_repository.dart';
import 'package:osm_map_surveyor/states/liststreetsegment_state.dart';

class ListStreetSegmentBloc extends Bloc<ListStreetSegmentEvent, ListStreetSegmentState> {
  ListStreetSegmentRepository _listStreetSegmentRepository = ListStreetSegmentRepository();

  ListStreetSegmentBloc({@required ListStreetSegmentRepository listStreetSegmentRepository}) : assert(ListStreetSegmentRepository != null),
    _listStreetSegmentRepository = listStreetSegmentRepository;

  // list Street segment controller
  final _listStreetSegmentController = StreamController<ListStreetSegments>();
  StreamSink<ListStreetSegments> get listStreetSegmentSink => _listStreetSegmentController.sink;
  Stream<ListStreetSegments> get listStreetSegmentStream => _listStreetSegmentController.stream;

  Stream<ListStreetSegmentState> getListStreetSegments(List<LatLng> points) async* {
    final rs = await _listStreetSegmentRepository.fetchListStreetSegments(points);
    listStreetSegmentSink.add(rs);
    yield LoadListStreetSegmentDataState();
    yield LoadListStreetSegmentDataFinishState(listStreetSegments: rs);
  }

  // list Street segment controller
  final _listStreetSegmentByPointController = StreamController<ListStreetSegments>();
  StreamSink<ListStreetSegments> get listStreetSegmentByPointSink => _listStreetSegmentByPointController.sink;
  Stream<ListStreetSegments> get listStreetSegmentByPointStream => _listStreetSegmentByPointController.stream;

  Stream<ListStreetSegmentState> getListStreetSegmentsByPoint(LatLng point) async* {
    final rs = await _listStreetSegmentRepository.fetchListStreetSegmentsByPoint(point);
    listStreetSegmentSink.add(rs);
    yield LoadListStreetSegmentByPointDataState();
    yield LoadListStreetSegmentByPointDataFinishState(listStreetSegments: rs);
  }

  @override
  ListStreetSegmentState get initialState => LoadInitListStreetSegmentDataState();

  @override
  Future<void> close() {
    _listStreetSegmentController.close();
    _listStreetSegmentByPointController.close();
    return super.close();
  }

  @override
  Stream<ListStreetSegmentState> mapEventToState(ListStreetSegmentEvent event) async* {
    if (event is LoadListStreetSegment) {
      yield* getListStreetSegments(event.points);
    } else if (event is LoadListStreetSegmentByPoint) {
      yield* getListStreetSegmentsByPoint(event.point);
    }
  }
}
