import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/models/account.dart';

@immutable
abstract class AuthenticationState extends Equatable {
  AuthenticationState([List props = const []]) : super();
}

class Uninitialized extends AuthenticationState {
  @override
  List<Object> get props => [];
}

class Authenticated extends AuthenticationState {
  final Account userAuthenticated;

  Authenticated(this.userAuthenticated) : super([userAuthenticated]);

  @override
  List<Object> get props => [userAuthenticated];

}

class Unauthenticated extends AuthenticationState {
  @override
  List<Object> get props => [];
}

class LoadingFailUnAuthenticated extends AuthenticationState {
  @override
  List<Object> get props => [];
}

class Unpermitted extends AuthenticationState {
  @override
  List<Object> get props => [];
}

class NoLoginState extends AuthenticationState {
  @override
  List<Object> get props => [];
}

class NoLoginFinishState extends AuthenticationState {
  @override
  List<Object> get props => [];
}

class UnpermittedFinishState extends AuthenticationState {
  @override
  List<Object> get props => [];
}

class InitUnauthorized extends AuthenticationState {
  @override
  List<Object> get props => [];
}