import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:osm_map_surveyor/models/brand.dart';
import 'package:osm_map_surveyor/models/store.dart';

@immutable
abstract class BrandState extends Equatable {}

class LoadBrandsState extends BrandState {
  @override
  List<Object> get props => [];
}

class LoadBrandsFinishState extends BrandState {
  final List<Brand> listBrands;
  LoadBrandsFinishState({Key key, @required this.listBrands});

  @override
  List<Object> get props => [listBrands];
}

class LoadInitState extends BrandState {
  @override
  List<Object> get props => [];
}

class LoadBrandStoresState extends BrandState {
  @override
  List<Object> get props => [];
}

class LoadBrandStoresFinishState extends BrandState {
  final List<Store> listStores;
  LoadBrandStoresFinishState({Key key, this.listStores});

  @override
  List<Object> get props => [listStores];
}
