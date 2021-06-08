import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class BrandEvent extends Equatable {}

class LoadBrands extends BrandEvent {
  @override
  String toString() => 'LoadBrands';

  @override
  List<Object> get props => [];
}

class LoadBrandStores extends BrandEvent {
  final int id;
  LoadBrandStores({Key key, this.id});

  @override
  String toString() => 'LoadBrandStores';

  @override
  List<Object> get props => [id];
}