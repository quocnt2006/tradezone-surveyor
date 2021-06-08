import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/models/account.dart';

@immutable
abstract class AccountState extends Equatable {}

class InitAccountState extends AccountState {
  @override
  List<Object> get props => [];
}

class UpdateAccountState extends AccountState {
  @override
  List<Object> get props => [];
}

class UpdateAccountFinishState extends AccountState {
  final Account account;
  UpdateAccountFinishState({Key key, @required this.account});
  @override
  List<Object> get props => [account];
}