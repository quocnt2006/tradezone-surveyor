import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_map_surveyor/events/segment_event.dart';
import 'package:osm_map_surveyor/models/segment.dart';
import 'package:osm_map_surveyor/repositories/segment_repository.dart';
import 'package:osm_map_surveyor/states/segment_state.dart';

class SegmentBloc extends Bloc<SegmentEvent, SegmentState> {
  SegmentRepository _segmentRepository = SegmentRepository();

  SegmentBloc({@required SegmentRepository segmentRepository}) : assert(SegmentRepository != null),
    _segmentRepository = segmentRepository;

  // get list segments
  final _listSegmentsController = StreamController<List<Segment>>();
  StreamSink<List<Segment>> get listSegmentsSink => _listSegmentsController.sink;
  Stream<List<Segment>> get listSegmentsStream => _listSegmentsController.stream;
  Stream<SegmentState> getLisSegments() async* {
    final rs = await _segmentRepository.fetchListSegments();
    listSegmentsSink.add(rs);
    yield LoadListSegmentsState();
    yield LoadListSegmentsFinishState(listSegments: rs);
  }

  @override
  SegmentState get initialState => LoadInitSegmentState();

  @override
  Future<void> close() {
    _listSegmentsController.close();
    return super.close();
  }

  @override
  Stream<SegmentState> mapEventToState(SegmentEvent event) async* {
    if (event is LoadListSegments) {
      yield* getLisSegments();
    } 
  }
}