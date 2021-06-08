import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_map_surveyor/events/account_event.dart';
import 'package:osm_map_surveyor/models/account.dart';
import 'package:osm_map_surveyor/repositories/account_repository.dart';
import 'package:osm_map_surveyor/states/account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountRepository _accountRepository = AccountRepository();
  AccountBloc({@required AccountRepository accountRepository}) : assert(AccountRepository != null),
    _accountRepository = accountRepository;

  // update account controller
  final _updateAccountController = StreamController<Account>();
  StreamSink<Account> get updateAccountSink => _updateAccountController.sink;
  Stream<Account> get updateAccountStream => _updateAccountController.stream;
  Stream<AccountState> updateAccount(Account account) async* {
    final rs = await _accountRepository.updateAccount(account);
    updateAccountSink.add(rs);
    yield UpdateAccountState();
    yield UpdateAccountFinishState(account: rs);
  }
  
  @override
  Future<void> close() {
    _updateAccountController.close();
    return super.close();
  }

  @override
  get initialState => InitAccountState();

  @override
  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    if (event is UpdateAccount) {
      yield* updateAccount(event.account);
    }
  }
}