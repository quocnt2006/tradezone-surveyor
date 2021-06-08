import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_map_surveyor/bloc/store_bloc.dart';
import 'package:osm_map_surveyor/events/store_event.dart';
import 'package:osm_map_surveyor/provider/authentication_provider.dart';
import 'package:osm_map_surveyor/repositories/store_repository.dart';
import 'package:osm_map_surveyor/screens/drawer/drawer_view.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/screens/storegeneral/createstore/create_store_screen.dart';
import 'package:osm_map_surveyor/screens/storegeneral/updatestore/update_store_screen.dart';
import 'package:osm_map_surveyor/states/store_state.dart';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:osm_map_surveyor/models/store.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreGeneralPage extends StatefulWidget {
  StoreGeneralPage({Key key}) : super(key: key);

  @override
  _StoreGeneralPageState createState() => _StoreGeneralPageState();
}

class _StoreGeneralPageState extends State<StoreGeneralPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String subHeaderContext = Config.subHeaderNeedSurveyStoreContext;
  List<Store> listDraftStores;
  List<Store> listAllNeedSurveyStores;
  List<Store> listNeedSurveyStores;
  Map<int, int> listNeedSurveyDraftStoresId = Map<int, int>();
  String dropdownSystemZoneValue;

  List<String>  _listSystemZoneNames = List<String>();
  bool _isDraft = false;
  bool _isReload;
  StoreBloc _storeBloc;

  @override
  void initState() {
    super.initState();
    _storeBloc = StoreBloc(storeRepository: StoreRepository());
    initDraftStores();
    initNeedSurveyStore();
    setListSystemZones();
    _isReload = false;
  }

  void setListSystemZones() {
    _listSystemZoneNames.add(' All system zone');
    initListNeedSurveySystemZone.forEach((systemzone) {
      _listSystemZoneNames.add(
        systemzone.id.toString() + ' ' + systemzone.name.toString()
      );
    });
    dropdownSystemZoneValue = _listSystemZoneNames[0].toString();
  }

  void initDraftStores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        int i = 1;
        bool isNotFound = false;
        while (!isNotFound) {
          String storePrefs = prefs.getString(Config.draftStore + i.toString());
          if (storePrefs == null) {
            isNotFound = true;
          } else {
            if (listDraftStores == null) {
              listDraftStores = [];
            }
            Store tmp = Store.fromJson(jsonDecode(storePrefs));
            listDraftStores.add(tmp);
            i += 1;
          }
        }
      },
    );
  }

  void initNeedSurveyStore() async {
    listNeedSurveyDraftStoresId = await getNeedSurveyDraftStores(initListNeedSurveyStores.toList());
    setState(() {
      listAllNeedSurveyStores = initListNeedSurveyStores.toList();
      listNeedSurveyStores = listAllNeedSurveyStores.toList();
    });
  }

  Future<Map<int, int>> getNeedSurveyDraftStores(List<Store> listStores) async {
    final prefs = await SharedPreferences.getInstance();
    Map<int, int> listNeedSurveyDraftStoresIdTmp = Map<int, int>();
    for (var store in listStores) {
      String storePrefs = prefs.getString(Config.draftUpdateStore + store.id.toString());
      if (storePrefs != null) {
        listNeedSurveyDraftStoresIdTmp.addAll({store.id : store.id});
      }
    }
    return listNeedSurveyDraftStoresIdTmp;
  }

  @override
  void dispose() {
    super.dispose();
    _storeBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: appBar(context),
      body: body(context),
      endDrawer: appEndDrawer(context),
      floatingActionButton: floatingActionButton(context),
    );
  }

  Widget appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(
        color: Config.iconThemeColor,
      ),
      backgroundColor: Config.secondColor,
      title: Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Store',
                style: TextStyle(
                  fontSize: Config.textSizeMedium,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Container(
          margin: EdgeInsets.all(
            MediaQuery.of(context).size.width * 0.02,
          ),
          child: GestureDetector(
            onTap: () {
              openEndDrawer();
            },
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.05,
              backgroundImage: currentUserWithToken.imageUrl != null
                ? NetworkImage(
                  currentUserWithToken.imageUrl,
                )
                : SvgPicture.asset(
                  Config.userSvgIcon,
                  fit: BoxFit.fill,
                ),
            ),
          )
        )
      ],
    );
  }

  Widget body(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: RefreshIndicator(
        color: Config.secondColor,
        child: ListView(
          children: <Widget>[
            subTotalHeader(context),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.0025,
              child: Container(
                color: Config.secondColor,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.025),
            _isDraft ? listDraftStoreWidget(context) : SizedBox(),
            !_isDraft ? listNeedSurveyStoresWidget(context) : SizedBox(),
            needSurveyStoresBlocListener(),
          ],
        ),
        onRefresh: refreshNeedSurveyStores,
      ),
    );
  }

  Widget needSurveyStoresBlocListener() {
    return BlocListener(
      bloc: _storeBloc,
      listener: (BuildContext context,StoreState state) async {
        if (state is LoadNeedSurveyStoresFinishState) {
          listNeedSurveyDraftStoresId = await getNeedSurveyDraftStores(initListNeedSurveyStores.toList());
          setState(() {
            initListNeedSurveyStores = state.listStores.results.toList();
            listAllNeedSurveyStores = initListNeedSurveyStores.toList();
            onSystemzoneChange(null);
            _isReload = false;
          });
        }
      },
      child: SizedBox(),
    );
  }

  Widget subTotalHeader(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: !_isDraft
                ? MediaQuery.of(context).size.height * 0.1675
                : MediaQuery.of(context).size.height * 0.1225,
      child: Stack(
        children: [
          if (!_isDraft) Positioned(
            bottom: MediaQuery.of(context).size.height * 0.01,
            left: MediaQuery.of(context).size.width * 0.075,
            right: MediaQuery.of(context).size.width * 0.075,
            child: dropdownNeedSurveySystemzZone(context),
          ),
          subHeader(context),
        ],
      ),
    );
  }

  Widget subHeader(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05,
        top: MediaQuery.of(context).size.height * 0.01,
      ),
      height: MediaQuery.of(context).size.height * 0.09,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Config.secondColor,
          width: MediaQuery.of(context).size.height * 0.001,
        ),
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width * 0.02,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 3,
            offset: Offset(2, 4), // Shadow position
          ),
        ],
      ),
      child: FlatButton(
        onPressed: () {
          setState(() {
            if (_isDraft) {
              _isDraft = false;
              subHeaderContext = Config.subHeaderNeedSurveyStoreContext;
            } else {
              _isDraft = true;
              subHeaderContext = Config.subHeaderDraftStoreContext;
            }
          });
        },
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.05,
              margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.03,
              ),
              child: _isDraft
                ? SvgPicture.asset(
                    Config.draftSvgIcon,
                    height: MediaQuery.of(context).size.height * 0.05,
                    color: Config.secondColor, 
                  )
                : SvgPicture.asset(
                    Config.surveyBuildingSvgIcon,
                    height: MediaQuery.of(context).size.height * 0.05,
                    color: Config.secondColor, 
                  ),
            ),
            Expanded(
              child: Text(
                subHeaderContext,
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.03,
              ),
              width: MediaQuery.of(context).size.width * 0.2,
              child: _isDraft
                ? listDraftStores != null
                  ? Text(
                      listDraftStores.length.toString() + (listDraftStores.length < 2 ? " store" : " stores"),
                    )
                  : SizedBox()
                : listNeedSurveyStores != null
                  ? Text(
                      listNeedSurveyStores.length.toString() + (listNeedSurveyStores.length == 1 ? " store" : " stores"),
                    )
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        goToCreateStorePage(null, null);
      },
      child: Icon(Icons.add),
      backgroundColor: Config.secondColor,
      foregroundColor: Colors.white,
    );
  }

  Widget dropdownNeedSurveySystemzZone(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Config.secondColor,
        border: Border.all(
          color: Config.secondColor,
        ),
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width * 0.02,
        ),
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.065,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.02,
        right: MediaQuery.of(context).size.width * 0.02,
        top: MediaQuery.of(context).size.height * 0.0075,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdownSystemZoneValue,
            icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
            style: TextStyle(
              color: Colors.white70,
              fontSize: Config.textSizeSmall * 0.9,
            ),
            onChanged: (String systemZoneValue) {
              setState(() {
                onSystemzoneChange(systemZoneValue);
              });
            },
            items: _listSystemZoneNames.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.substring(value.indexOf(' '), value.length)),
              );
            }).toList(),
        ),
      )
    );
  }

  Widget listNeedSurveyStoresWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: <Widget>[
          if (listNeedSurveyStores != null && _isReload == false)
            for (final store in listNeedSurveyStores)
              listNeedSurveyDraftStoresId.containsKey(store.id)
                ? storeWidget(context, store, null, store.id.toString())
                : storeWidget(context, store, null, null),
          if (_isReload == true) circularProgressCustom(),
        ],
      ),
    );
  }

  Widget circularProgressCustom() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.005,
      child: LinearProgressIndicator(
        backgroundColor: Config.thirdColor,
        valueColor: AlwaysStoppedAnimation<Color>(Config.secondColor),
      ),
    );
  }

  Widget listDraftStoreWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: <Widget>[
          if (listDraftStores == null)
            Icon(
              Icons.cancel,
              size: MediaQuery.of(context).size.width * 0.1,
            ),
          if (listDraftStores == null)
            Text(
              "No draft store here!",
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            ),
          if (listDraftStores != null)
            for (var i = 0; i < listDraftStores.length; i++)
              storeWidget(context, listDraftStores[i], (i + 1).toString(), null),
        ],
      ),
    );
  }

  Widget storeWidget(
    BuildContext context,
    Store store,
    String shareDraftPreferenceId,
    String shareNeedSurveyDraftPreferenceId) {
    return FlatButton(
      onPressed: () {
        if (shareDraftPreferenceId != null) {
          goToCreateStorePage(store, shareDraftPreferenceId);
        } else {
          goToUpdateStorePage(store, shareNeedSurveyDraftPreferenceId);
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.02,
          bottom: MediaQuery.of(context).size.height * 0.005,
          top: MediaQuery.of(context).size.height * 0.005,
        ),
        height: MediaQuery.of(context).size.height * 0.075,
        decoration: BoxDecoration(
          color: Config.thirdColor,
          border: Border.all(
            color: Config.secondColor,
            width: MediaQuery.of(context).size.height * 0.001,
          ),
          borderRadius: BorderRadius.circular(
            MediaQuery.of(context).size.width * 0.02,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 2,
              offset: Offset(2, 3), // Shadow position
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.1,
              height: MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
              ),
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.02,
              ),
              padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.02,
              ),
              child: store.imageUrl == null
                ? SvgPicture.asset(
                    Config.shopSvgIcon,
                    color: Config.secondColor,
                  )
                : Image.network(store.imageUrl),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.02,
                ),
                child: store.name == null
                  ? Text("No name")
                  : store.name.isEmpty
                    ? Text("No name")
                    : store.name.length > 43
                      ? Tooltip(
                          message: store.name,
                          child: Text(store.name.substring(0, 40) + "..."),
                        )
                      : Text(store.name),
              ),
            ),
            if (shareNeedSurveyDraftPreferenceId != null)
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(),
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.02,
                ),
                child: Center(
                  child: Text("Surveying"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  Future<Null> refreshNeedSurveyStores() async {
    setState(() {
      if (!_isReload) {
        _isReload = true;
        _storeBloc.add(LoadNeedSurveyStores());}
    });
  }

  void onSystemzoneChange(String value) {
    setState(() {
      if (value != null) dropdownSystemZoneValue = value.toString();
      if (dropdownSystemZoneValue == _listSystemZoneNames[0]) {
        listNeedSurveyStores.clear();
        listNeedSurveyStores = listAllNeedSurveyStores.toList();
      } else {
        listNeedSurveyStores.clear();
        listAllNeedSurveyStores.forEach((store) {
          if (store.systemzoneId == int.parse(dropdownSystemZoneValue.split(' ')[0])) {
            listNeedSurveyStores.add(store);
          }
        });
      }      
    });
  }

  void goToCreateStorePage(Store store, String sharePreferenceId) async {
    final prefs = await SharedPreferences.getInstance();
    dynamic rs;
    if (store != null && sharePreferenceId != null) {
      rs = await Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => CreateStoreScreen(initStore: store, sharePreferenceId: sharePreferenceId,))
      );
    } else {
      rs = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateStoreScreen()));
    }

    if (rs != null) {
      setState(() {
        listDraftStores = null;
        int i = 1;
        bool isNotFound = false;
        while (!isNotFound) {
          String storePrefs = prefs.getString(Config.draftStore + i.toString());
          if (storePrefs == null) {
            isNotFound = true;
          } else {
            if (listDraftStores == null) {
              listDraftStores = [];
            }
            Store tmp = Store.fromJson(jsonDecode(storePrefs));
            listDraftStores.add(tmp);
            i += 1;
          }
        }
      });
      if (rs[1]) {
      } else {
        if (rs[0]) {
          showToast(Config.addStoreSuccessMessage, true);
        } else {
          showToast(Config.saveDraftStoreSuccessMessage, true);
        }
      }
    }
  }
  
  void goToUpdateStorePage(
    Store store, String shareNeedSurveyDraftPreferenceId
  ) async {
    dynamic rs;
    rs = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateStoreScreen(
          // initStore: store,
          // sharePreferenceId: shareNeedSurveyDraftPreferenceId,
        )
      )
    );
    if (rs != null) {
      if (rs[1]) {
        _isReload = true;
        _storeBloc.add(LoadNeedSurveyStores());
        if (rs[2]) {
          showToast(Config.deleteStoreSuccessMessage, true);
        } else {
          showToast(Config.deleteStoreFailMessage, false);
        }
      } else {
        _isReload = true;
        _storeBloc.add(LoadNeedSurveyStores());
        if (rs[0]) {
          showToast(Config.updateNeedSurveyStoreSuccessMessage, true);
        } else {
          showToast(Config.saveNeedSurveyDraftStoreSuccessMessage, true);
        }
      }
    }
  }

  showToast(String message,bool isSuccess) {
    Toast.show(
      message,
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.BOTTOM,
      backgroundColor: isSuccess ? Colors.greenAccent : Colors.redAccent,
      backgroundRadius: MediaQuery.of(context).size.width * 0.01,
    );
  }
}
