import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:osm_map_surveyor/events/authentication_event.dart';
import 'package:osm_map_surveyor/models/account.dart';
import 'package:osm_map_surveyor/repositories/account_repository.dart';
import 'package:osm_map_surveyor/states/authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AccountRepository _accountRepository = AccountRepository();
  Account _user;


  final _userStreamController = StreamController<Account>();

  StreamSink<Account> get userSink => _userStreamController.sink;
  Stream<Account> get streamUser => _userStreamController.stream;

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _accountRepository.checkLogin();

      if (isSignedIn == true) {
          userSink.add(_user);
          yield Authenticated(_user);
      } else {
        yield InitUnauthorized();
      }
    } catch (c) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapSignInwithGoogleToState() async* {
    try {
      _user = await _accountRepository.signInWithGoogle();
      if (_user != null) {       
        if (_user.role == 2) {
          userSink.add(_user);
          yield Authenticated(_user);
        } else {
          yield Unpermitted();
          yield UnpermittedFinishState();
        }
      } else {
        yield NoLoginState();
        yield NoLoginFinishState();
      }
    } catch (c) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    _accountRepository.signOut();
  }

  Stream<AuthenticationState> _mapLoadingFailLoggedOutToState() async* {
    yield LoadingFailUnAuthenticated();
    _accountRepository.signOut();
  }

  AuthenticationBloc({@required AccountRepository accountRepository}) : assert(accountRepository != null),
    _accountRepository = accountRepository;

  @override
  AuthenticationState get initialState => Uninitialized();
  
  @override
  Future<void> close() {
    _userStreamController.close();
    return super.close();
  }

  @override
  Stream<AuthenticationState> mapEventToState(event) async*{
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is SignInWithGoogle) {
      yield* _mapSignInwithGoogleToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    } else if (event is LoggedOutWithLoadingFail) {
      yield* _mapLoadingFailLoggedOutToState();
    }
  }
  
}