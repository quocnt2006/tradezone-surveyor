import 'package:osm_map_surveyor/models/account.dart';
import 'package:osm_map_surveyor/provider/account_provider.dart';
import 'package:osm_map_surveyor/provider/authentication_provider.dart';

class AccountRepository {
  FirebaseNetworkProvider _firebaseNetworkProvider = new FirebaseNetworkProvider();
  AccountProvider _accountProvider = new AccountProvider();

  Future<Account> signInWithGoogle() async{
    return await _firebaseNetworkProvider.signInWithGoogle();
  }
  Future<bool> signOut() async{
    return await _firebaseNetworkProvider.signOut();
  }
  Future<bool> checkLogin() async{
    return await _firebaseNetworkProvider.checkLogin();
  }

  Future<Account> updateAccount(Account account) async {
    return await _accountProvider.updateAccount(account);
  }
}