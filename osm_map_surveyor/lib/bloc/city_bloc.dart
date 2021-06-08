import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_map_surveyor/events/city_event.dart';
import 'package:osm_map_surveyor/models/district.dart';
import 'package:osm_map_surveyor/repositories/city_repository.dart';
import 'package:osm_map_surveyor/states/city_state.dart';

class CityBloc  extends Bloc<CityEvent, CityState> {
  CityRepository _cityRepository = CityRepository();

  CityBloc({@required CityRepository cityRepository}) : assert(CityRepository != null),
    _cityRepository = cityRepository;

  // list district controller
  final _listDistrictController = StreamController<List<District>>();
  StreamSink<List<District>> get listDistrictSink => _listDistrictController.sink;
  Stream<List<District>> get listDistrictStream => _listDistrictController.stream;
  Stream<CityState> getListDistrict() async* {
    final rs = await _cityRepository.fetchListDistrict();
    yield LoadListDistrictState();
    yield LoadListDistrictFinishState(listDistrict: rs);
  }

  @override
  CityState get initialState => LoadInitCityState();

  @override
  Future<void> close() {
    _listDistrictController.close();
    return super.close();
  }

  @override
  Stream<CityState> mapEventToState(CityEvent event) async* {
    if (event is LoadListDistrict) {
      yield* getListDistrict();
    }
  }
  
}