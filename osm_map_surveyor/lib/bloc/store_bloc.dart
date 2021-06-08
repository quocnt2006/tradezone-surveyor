import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geodesy/geodesy.dart';
import 'package:osm_map_surveyor/events/store_event.dart';
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/models/liststores.dart';
import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/models/store.dart';
import 'package:osm_map_surveyor/models/storepost.dart';
import 'package:osm_map_surveyor/repositories/store_repository.dart';
import 'package:osm_map_surveyor/states/store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  StoreRepository _storeRepository = StoreRepository();

  StoreBloc({@required StoreRepository storeRepository}) : assert(StoreRepository != null),
    _storeRepository = storeRepository;

  // store four bounds controller
  final _storeFourBoundsController = StreamController<String>();
  StreamSink<String> get storeFourboundsSink => _storeFourBoundsController.sink;
  Stream<String> get storeFourboundsStream => _storeFourBoundsController.stream;

  Stream<StoreState> getStoreByFourBounds(
    LatLng northWest,
    LatLng northEast,
    LatLng southEast,
    LatLng southWest) async* {
    final rs = await _storeRepository.fetchStoresByFourBounds(northWest, northEast, southEast, southWest);
    storeFourboundsSink.add(rs);
    yield LoadStoreByFourBoundsDataState();
    yield LoadStoreByFourBoundsDataFinishState(rs: rs);
  }

  // list store buildings controller
  final _listStoreBuildingsController = StreamController<List<Building>>();
  StreamSink<List<Building>> get listStoreBuildingsSink => _listStoreBuildingsController.sink;
  Stream<List<Building>> get listStoreBuildingsStream => _listStoreBuildingsController.stream;
  Stream<StoreState> getListStoreBuildings(LatLng point) async* {
    final rs = await _storeRepository.fetchListBuildings(point);
    listStoreBuildingsSink.add(rs);
    yield LoadListStoreBuildingsState();
    yield LoadListStoreBuildingsFinishState(listBuildings: rs);
  }

  //  add new store controller
  final _addStoreController = StreamController<bool>();
  StreamSink<bool> get addStoreSink => _addStoreController.sink;
  Stream<bool> get addStoreStream => _addStoreController.stream;
  Stream<StoreState> addStore(StorePost store) async* {
    final rs = await _storeRepository.addStore(store);
    yield AddStoreState();
    yield AddStoreSucessState(isSuccess: rs);
  }

  // list need survey store controller
  final _listNeedSurveyStoresController = StreamController<ListStores>();
  StreamSink<ListStores> get listNeedSurveyStoresSink => _listNeedSurveyStoresController.sink;
  Stream<ListStores> get listNeedSurveyStoresStream => _listNeedSurveyStoresController.stream;
  Stream<StoreState> getListNeedSurveyBuildings() async* {
    final rs = await _storeRepository.fetchNeedSurveyStores();
    listNeedSurveyStoresSink.add(rs);
    yield LoadNeedSurveyStoresState();
    yield LoadNeedSurveyStoresFinishState(listStores: rs);
  }

  // list street segments by building id controller
  final _listStreetSegmentsByStoreIdController = StreamController<ListStreetSegments>();
  StreamSink<ListStreetSegments> get listStreetSegmentsByStoreIdSink => _listStreetSegmentsByStoreIdController.sink;
  Stream<ListStreetSegments> get listStreetSegmentsByStoreIdStream => _listStreetSegmentsByStoreIdController.stream;
  Stream<StoreState> getListStreetSegmentByStoreId(int id) async* {
    final rs = await _storeRepository.fetchListStreetSegmentByStoreId(id);
    listStreetSegmentsByStoreIdSink.add(rs);
    yield LoadListStreetSegmentsByStoreIdState();
    yield LoadListStreetSegmentsByStoreIdFinishState(listStreetSegments: rs);
  }

  //  update store controller
  final _updateStoreController = StreamController<bool>();
  StreamSink<bool> get updateStoreSink => _updateStoreController.sink;
  Stream<bool> get updateStoreStream => _updateStoreController.stream;
  Stream<StoreState> updateStore(StorePost store) async* {
    final rs = await _storeRepository.updateStore(store);
    yield UpdateStoreState();
    yield UpdateStoreSucessState(isSuccess: rs);
  }

  // delete store controller
  final _deleteStoreController = StreamController<bool>();
  StreamSink<bool> get deleteStoreSink => _deleteStoreController.sink;
  Stream<bool> get deleteStoreStream => _deleteStoreController.stream;
  Stream<StoreState> deleteStore(int id) async* {
    final rs = await _storeRepository.deleteStoreById(id);
    yield DeleteStoreState();
    yield DeleteStoreSucessState(isSuccess: rs);
  }

  // get store by id controller
  final _fetchStoreByIdController = StreamController<Store>();
  StreamSink<Store> get fetchStoreByIdSink => _fetchStoreByIdController.sink;
  Stream<Store> get fetchStoreByIdStream => _fetchStoreByIdController.stream;
  Stream<StoreState> fetchStoreById(int id) async* {
    final rs = await _storeRepository.fetchStoreById(id);
    yield LoadStoreByIdState();
    yield LoadStoreByIdFinishState(store: rs);
  }

  // List need survey stores on map controller
  final _listNeedSurveyStoresMapController = StreamController<String>();
  StreamSink<String> get listNeedSurveyStoresMapSink => _listNeedSurveyStoresMapController.sink;
  Stream<String> get listNeedSurveyStoresMapStream => _listNeedSurveyStoresMapController.stream;
  Stream<StoreState> fetchListNeedSurveyStoresMap() async* {
    final rs = await _storeRepository.fetchNeedSurveyStoresMap();
    yield LoadListNeedSurveyStoresMapState();
    yield LoadListNeedSurveyStoresMapFinishState(rs: rs);
  }

  // check store location
  final _checkStoreLocationController = StreamController<bool>();
  StreamSink<bool> get checkStoreLocationSink => _checkStoreLocationController.sink;
  Stream<bool> get checkStoreLocationStream => _checkStoreLocationController.stream;
  Stream<StoreState> checkStoreLocation(LatLng latlng) async* {
    final rs = await _storeRepository.checkStoreLocation(latlng);
    yield LoadCheckStoreLocationState();
    yield LoadCheckStoreLocationFinishState(rs: rs);
  }

  @override
  StoreState get initialState => LoadInitStoreDataState();

  @override
  Future<void> close() {
    _storeFourBoundsController.close();
    _listStoreBuildingsController.close();
    _addStoreController.close();
    _listNeedSurveyStoresController.close();
    _listStreetSegmentsByStoreIdController.close();
    _updateStoreController.close();
    _deleteStoreController.close();
    _fetchStoreByIdController.close();
    _listNeedSurveyStoresMapController.close();
    _checkStoreLocationController.close();
    return super.close();
  }

  @override
  Stream<StoreState> mapEventToState(StoreEvent event) async* {
    if (event is LoadStoresByFourBounds) {
      yield* getStoreByFourBounds(event.northWest, event.northEast, event.southEast, event.southWest);
    } else if (event is LoadListStoreBuildings) {
      yield* getListStoreBuildings(event.point);
    } else if (event is AddStore) {
      yield* addStore(event.store);
    } else if (event is LoadNeedSurveyStores) {
      yield* getListNeedSurveyBuildings();
    } else if (event is LoadListStreetSegmentsByStoreId) {
      yield* getListStreetSegmentByStoreId(event.id);
    } else if (event is UpdateStore) {
      yield* updateStore(event.store);
    } else if (event is DeleteStore) {
      yield* deleteStore(event.id);
    } else if (event is LoadStoreById) {
      yield* fetchStoreById(event.id);
    } else if (event is LoadListNeedSurveyStoresMap) {
      yield* fetchListNeedSurveyStoresMap();
    } else if (event is LoadCheckStoreLocation) {
      yield* checkStoreLocation(event.point);
    }
  }
}
