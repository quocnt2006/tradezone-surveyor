import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_map_surveyor/events/history_event.dart';
import 'package:osm_map_surveyor/models/history.dart';
import 'package:osm_map_surveyor/repositories/history_repository.dart';
import 'package:osm_map_surveyor/states/history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryRepository _historyRepository = HistoryRepository();
  HistoryBloc({@required HistoryRepository historyRepository}) : assert(HistoryRepository != null),
    _historyRepository = historyRepository;

  // get list history
  final _fetchListHistoryController = StreamController<List<History>>();
  StreamSink<List<History>> get fetchListHistorySink => _fetchListHistoryController.sink;
  Stream<List<History>> get fetchListHistoryStream => _fetchListHistoryController.stream;
  Stream<HistoryState> fetchListHistory() async* {
    final rs = await _historyRepository.fetchListHistory();
    yield LoadListHistoryState();
    yield LoadListHistoryFinishState(listHistory: rs);
  }

  @override
  HistoryState get initialState => LoadInitHistoryState();

  @override
  Future<void> close() {
    _fetchListHistoryController.close();
    return super.close();
  }

  @override
  Stream<HistoryState> mapEventToState(HistoryEvent event) async* {
    if (event is LoadListHistory) {
      yield* fetchListHistory();
    }
  }
}