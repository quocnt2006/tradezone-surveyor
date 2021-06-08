import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/models/account.dart';

@immutable
abstract class AccountEvent extends Equatable {}

class UpdateAccount extends AccountEvent {
  final Account account; 
  UpdateAccount({Key key, @required this.account});

  @override
  String toString() => 'UpdateAccount';

  @override
  List<Object> get props => [account];
}