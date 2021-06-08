import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_map_surveyor/events/brand_event.dart';
import 'package:osm_map_surveyor/models/brand.dart';
import 'package:osm_map_surveyor/models/store.dart';
import 'package:osm_map_surveyor/repositories/brand_repository.dart';
import 'package:osm_map_surveyor/states/brand_state.dart';

class BrandBloc extends Bloc<BrandEvent, BrandState> {
  BrandRepository _brandRepository = BrandRepository();
  BrandBloc({@required BrandRepository brandRepository}) : assert(BrandRepository != null),
    _brandRepository = brandRepository;

  // load brands controller
  final _listBrandsController = StreamController<List<Brand>>();
  StreamSink<List<Brand>> get listBrandsSink => _listBrandsController.sink;
  Stream<List<Brand>> get listBrandsStream => _listBrandsController.stream;

  Stream<BrandState> getListBrands() async* {
    final rs = await _brandRepository.fetchListBrands();
    listBrandsSink.add(rs);
    yield LoadBrandsState();
    yield LoadBrandsFinishState(listBrands: rs);
  }

  // load brand store controller
  final _listBrandStoresController = StreamController<List<Store>>();
  StreamSink<List<Store>> get listBrandStoresSink => _listBrandStoresController.sink;
  Stream<List<Store>> get listBrandStoresStream => _listBrandStoresController.stream;

  Stream<BrandState> getListBrandStores(int id) async* {
    final rs = await _brandRepository.fetchListBrandStores(id);
    listBrandStoresSink.add(rs);
    yield LoadBrandStoresState();
    yield LoadBrandStoresFinishState(listStores: rs);
  }

  @override
  BrandState get initialState => LoadInitState();

  @override
  Future<void> close() {
    _listBrandsController.close();
    _listBrandStoresController.close();
    return super.close();
  }

  @override
  Stream<BrandState> mapEventToState(BrandEvent event) async* {
    if (event is LoadBrands) {
      yield* getListBrands();
    } if (event is LoadBrandStores) {
      yield* getListBrandStores(event.id);
    }
  }
}
