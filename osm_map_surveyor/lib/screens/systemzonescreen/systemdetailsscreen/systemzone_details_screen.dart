import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geodesy/geodesy.dart';
import 'package:osm_map_surveyor/bloc/history_bloc.dart';  
import 'package:osm_map_surveyor/bloc/systemzone_bloc.dart';
import 'package:osm_map_surveyor/events/history_event.dart';
import 'package:osm_map_surveyor/events/systemzone_event.dart';
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/models/store.dart';
import 'package:osm_map_surveyor/models/systemzone.dart';
import 'package:osm_map_surveyor/provider/authentication_provider.dart';
import 'package:osm_map_surveyor/repositories/history_repository.dart';
import 'package:osm_map_surveyor/repositories/systemzone_repository.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/createbuilding/create_building_screen.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/draftbuilding/draft_building_screen.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/updatebuilding/update_building_screen.dart';
import 'package:osm_map_surveyor/screens/drawer/drawer_view.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/screens/storegeneral/createstore/create_store_screen.dart';
import 'package:osm_map_surveyor/screens/storegeneral/draftstore/draft_store_screen.dart';
import 'package:osm_map_surveyor/screens/storegeneral/updatestore/update_store_screen.dart';
import 'package:osm_map_surveyor/states/history_state.dart';
import 'package:osm_map_surveyor/states/systemzone_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/geolocator_utils.dart';
import 'package:osm_map_surveyor/utilities/popup_utils.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';

enum CreateOption { CreateBuilding, CreateStore, DraftBuilding, DraftStore }

class SystemZoneDetailsScreen extends StatefulWidget {
  final SystemZone initSystemZone;
  SystemZoneDetailsScreen({Key key, this.initSystemZone}) : super(key: key);
  @override
  _SystemZoneDetailsScreenState createState() => _SystemZoneDetailsScreenState(this.initSystemZone);
}

class _SystemZoneDetailsScreenState extends State<SystemZoneDetailsScreen> {
  final SystemZone initSystemZone;
  _SystemZoneDetailsScreenState(this.initSystemZone);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final ScrollController _scrollBuildingViewController = ScrollController();
  final ScrollController _scrollStoreViewController = ScrollController();
  static const double _endReachThreshold = 100;
  final int pageSize = 20;
  final int initPage = 1;

  SystemZoneBloc _systemZoneBloc;
  HistoryBloc _historyBloc;
  List<Building> _listBuilding;
  int _currentBuildingPage;
  int _totalBuildingPage;
  bool _isLoadingBuilding;
  bool _isLoadingBuildingMore;
  List<Store> _listStore;
  int _currentStorePage;
  int _totalStorePage;
  bool _isLoadingStore;
  bool _isLoadingStoreMore;
  LatLng _systemZoneCenter;

  @override
  void initState() { 
    super.initState();
    _systemZoneBloc = SystemZoneBloc(systemZoneRepository: SystemZoneRepository());
    _historyBloc = HistoryBloc(historyRepository: HistoryRepository());
    _listBuilding = new List<Building>();
    _listStore = new List<Store>();
    _currentBuildingPage = initPage;
    _isLoadingBuildingMore = false;
    _currentStorePage = initPage;
    _isLoadingStoreMore = false;
    _getSystemZoneCenter();
    _initFunction();
    _scrollBuildingViewController.addListener(_onBuildingScroll);
    _scrollStoreViewController.addListener(_onStoreScroll);
  }

  @override
  void dispose() { 
    _systemZoneBloc.close();
    _historyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(context),
      endDrawer: appEndDrawer(context),
      body: body(context),
      floatingActionButton: initSystemZone.isMySystemZone ? _floatingActionButton(context) : null,
    );
  }

  Widget appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios, 
          color: Colors.white,
          size: MediaQuery.of(context).size.height * 0.025,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      iconTheme: IconThemeData(
        color: Config.iconThemeColor,
      ),
      backgroundColor: Config.secondColor,
      title: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                initSystemZone.name.toString(),
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
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
              _openEndDrawer();
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

  Widget _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
        onPressed: () {
          showCreateDialog();
        },
        child: Icon(Icons.add),
        foregroundColor: Colors.white,
        backgroundColor: Config.secondColor
        );
  }

  Widget body(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            _blocListenerWidget(),
            DefaultTabController(
              length: 2, 
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.white,
                      pinned: true,
                      floating: true,
                      actions: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: TabBar(
                            indicatorColor: Config.redColor.withOpacity(0.75),
                            tabs: [
                              Container(
                                child: Text(
                                  'Building',
                                  style: TextStyle(
                                    fontSize: Config.textSizeSmall,
                                    color: Config.secondColor,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                              ),
                              Container(
                                child: Text(
                                  'Store',
                                  style: TextStyle(
                                    fontSize: Config.textSizeSmall,
                                    color: Config.secondColor,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                              ),
                            ]
                          ),
                        )
                      ],
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.825,
                            child: TabBarView(
                              children: [
                                _buildingView(context),
                                _storeView(context),
                              ]
                            ),
                          );
                        },
                        childCount: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blocListenerWidget() {
    return MultiBlocListener(
      listeners: [
        _systemZoneBlocListener(),
        _historyBlocListener(),
      ], 
      child: SizedBox(),
    );
  }

  Widget _systemZoneBlocListener() {
    return BlocListener(
      bloc: _systemZoneBloc,
      listener: (BuildContext context,SystemZoneState state) {
        if (state is LoadListSystemZoneBuildingsFinishState) {
          if (state.listBuildings != null) {
            if (_listBuilding.length == 0) {
              setState(() {
                if (_isLoadingBuilding) _isLoadingBuilding = false;
                if (_isLoadingBuildingMore) _isLoadingBuildingMore = false;
                _listBuilding = state.listBuildings.results.toList();
                _totalBuildingPage = state.listBuildings.totalNumberOfPages;
                _currentBuildingPage = state.listBuildings.pageNumber;
              });
            } else {
              setState(() {
                if (_isLoadingBuilding) _isLoadingBuilding = false;
                if (_isLoadingBuildingMore) _isLoadingBuildingMore = false;
                _listBuilding.addAll(state.listBuildings.results.toList());
                _totalBuildingPage = state.listBuildings.totalNumberOfPages;
                _currentBuildingPage = state.listBuildings.pageNumber;
              });
            }
          } else {
            PopupUtils.utilShowLoginDialog(Config.loadingSystemZoneBuildingFail, Config.loadingSystemZoneBuildingFailBody, context);
          }
        } else if (state is LoadListSystemZoneStoresFinishState) {
          if (state.listStores != null) {
            if (_listStore.length == 0) {
              setState(() {
                if (_isLoadingStore) _isLoadingStore = false;
                if (_isLoadingStoreMore) _isLoadingStoreMore = false;
                _listStore = state.listStores.results.toList();
                _totalStorePage = state.listStores.totalNumberOfPages;
                _currentStorePage = state.listStores.pageNumber;
              });
            } else {
              setState(() {
                if (_isLoadingStore) _isLoadingStore = false;
                if (_isLoadingStoreMore) _isLoadingStoreMore = false;
                _listStore.addAll(state.listStores.results.toList());
                _totalStorePage = state.listStores.totalNumberOfPages;
                _currentStorePage = state.listStores.pageNumber;
              });
            }
          } else {
            PopupUtils.utilShowLoginDialog(Config.loadingSystemZoneStoreFail, Config.loadingSystemZoneStoreFailBody, context);
          }
        }
      },
      child: SizedBox(),
    );
  }

  Widget _historyBlocListener() {
    return BlocListener(
      bloc: _historyBloc,
      listener: (BuildContext context,HistoryState state) {
        if (state is LoadListHistoryFinishState) {
          if (state.listHistory == null) {
            setState(() {
              initListHistory.clear();
              initListHistory = state.listHistory.toList();
            });
          }
        }
      },
      child: SizedBox(),
    );
  }

  Widget _buildingView(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.825,
      width: MediaQuery.of(context).size.width,
      child: _listBuildingWidget(context),
    );
  }

  Widget _storeView(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.825,
      width: MediaQuery.of(context).size.width,
      child: _listStoresWidget(context),
    );
  }

  Widget _listBuildingWidget(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.825,
      width: MediaQuery.of(context).size.width,
      child: CustomScrollView(
        controller: _scrollBuildingViewController,
        slivers: [
          if (_listBuilding.length > 0) SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return _buildingWidget(context, index);
              },
              childCount: _listBuilding.length,
            ),
          ),
          if (_listBuilding.length == 0 && !_isLoadingBuilding) SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  alignment: Alignment.center,
                  child: Text(
                    'No building available',
                  ),
                );
              },
              childCount: 1,
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoadingBuildingMore
              ? Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.01,
                  top: MediaQuery.of(context).size.height * 0.01,
                ),
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
              : SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _listStoresWidget(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.825,
      width: MediaQuery.of(context).size.width,
      child: CustomScrollView(
        controller: _scrollStoreViewController,
        slivers: [
          if (_listBuilding.length > 0) SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return _storeWidget(context, index);
              },
              childCount: _listStore.length,
            ),
          ),
          if (_listStore.length == 0 && !_isLoadingStore) SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  alignment: Alignment.center,
                  child: Text(
                    'No store available',
                  ),
                );
              },
              childCount: 1,
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoadingBuildingMore
              ? Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.01,
                  top: MediaQuery.of(context).size.height * 0.01,
                ),
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
              : SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildingWidget(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _goToUpdateBuildingScreen(_listBuilding[index].id);
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
                    color: Config.redColor,
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
              child: _listBuilding[index].imageUrl == null
                ? setIconBuilding(_listBuilding[index].type)
                : Image.network(_listBuilding[index].imageUrl),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.02,
                ),
                child: _listBuilding[index].name == null
                  ? Text("No name")
                  : _listBuilding[index].name.isEmpty
                    ? Text("No name")
                    : _listBuilding[index].name.length > 43
                      ? Tooltip(
                          message: _listBuilding[index].name,
                          child: Text(_listBuilding[index].name.substring(0, 40) + "..."),
                        )
                      : Text(_listBuilding[index].name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _storeWidget(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _goToUpdateStoreScreen(_listStore[index].id);
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
                    color: Config.redColor,
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
              child: _listStore[index].imageUrl == null
                ? SvgPicture.asset(
                    Config.shopSvgIcon,
                    color: Config.secondColor,
                  )
                : Image.network(_listStore[index].imageUrl),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.02,
                ),
                child: _listStore[index].name == null
                  ? Text("No name")
                  : _listStore[index].name.isEmpty
                    ? Text("No name")
                    : _listStore[index].name.length > 43
                      ? Tooltip(
                          message: _listStore[index].name,
                          child: Text(_listStore[index].name.substring(0, 40) + "..."),
                        )
                      : Text(_listStore[index].name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SvgPicture setIconBuilding(String type) {
    if (type != null) {
      if (type.contains("Educational")) {
        return SvgPicture.asset(
          Config.schoolSvgIcon,
          color: Config.secondColor,
        );
      } else if (type.contains("Residential")) {
        return SvgPicture.asset(
          Config.apartmentSvgIcon,
          color: Config.secondColor,
        );
      } else if (type.contains("Business")) {
        return SvgPicture.asset(
          Config.buildingDefaultSvgIcon,
          color: Config.secondColor,
        );
      } else if (type.contains("Industrial")) {
        return SvgPicture.asset(
          Config.industrialSvgIcon,
          color: Config.secondColor,
        );
      } else if (type.contains("Service")) {
        return SvgPicture.asset(
          Config.serviceSvgIcon,
          color: Config.secondColor,
        );
      }
    }
    return SvgPicture.asset(
      Config.buildingSvgIcon,
      color: Config.secondColor,
    );
  }

  void _initFunction() {
    _isLoadingBuilding = true;
    _systemZoneBloc.add(LoadListSystemZoneBuildings(id: initSystemZone.id, page: _currentBuildingPage, pageSize: pageSize));
    _isLoadingStore = true;
    _systemZoneBloc.add(LoadListSystemZoneStores(id:  initSystemZone.id, page: _currentStorePage, pageSize: pageSize));
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  void _onBuildingScroll() {
    if (_totalBuildingPage != null) {
      if (!_scrollBuildingViewController.hasClients ||
        _isLoadingBuilding ||
        _isLoadingBuildingMore ||
        _listBuilding.length == 0 ||
        _currentBuildingPage == _totalBuildingPage
      ) return;
    }

    final thresholdReached = _scrollBuildingViewController.position.extentAfter < _endReachThreshold;

    if (thresholdReached) {
      _onLoadBuildingMore();
    }
  }

  void _onLoadBuildingMore() {
    setState(() {
      _isLoadingBuildingMore = true;
    });
    _currentBuildingPage +=1;
    _systemZoneBloc.add(LoadListSystemZoneBuildings(id: initSystemZone.id, page: _currentBuildingPage, pageSize: _totalBuildingPage));
  }

  void _onStoreScroll() {
    if (_totalStorePage != null) {
      if (!_scrollStoreViewController.hasClients ||
        _isLoadingStore ||
        _isLoadingStoreMore ||
        _listStore.length == 0 ||
        _currentStorePage == _totalStorePage
      ) return;
    }

    final thresholdReached = _scrollStoreViewController.position.extentAfter < _endReachThreshold;

    if (thresholdReached) {
      _onLoadStoreMore();
    }
  }

  void _onLoadStoreMore() {
    setState(() {
      _isLoadingStoreMore = true;
    });
    _currentStorePage += 1;
    _systemZoneBloc.add(LoadListSystemZoneStores(id: initSystemZone.id, page: _currentStorePage, pageSize: pageSize));
  }

  void showCreateDialog() async {
    switch (await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Container(
              child: Text(
                "Create",
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                ),
              ),
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, CreateOption.CreateBuilding);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02,
                      ),
                      child: Text("Building"),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, CreateOption.DraftBuilding);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02,
                      ),
                      child: Text("From draft building"),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, CreateOption.CreateStore);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02,
                      ),
                      child: Text("Store"),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, CreateOption.DraftStore);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02,
                      ),
                      child: Text("From draft store"),
                    ),
                  ],
                ),
              ),
            ],
          );
        })) {
      case CreateOption.CreateBuilding:
        _goToCreateBuildingPage();
        break;
      case CreateOption.DraftBuilding:
        _goToCreateFromDraftBuildingPage();
        break;
      case CreateOption.CreateStore:
        _goToCreateStorePage();
        break;
      case CreateOption.DraftStore:
        _goToCreateFromDraftStorePage();
    }
  }
  
  void _goToCreateBuildingPage() async {
    dynamic rs = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => CreateBuildingScreen(systemZoneCenter: _systemZoneCenter,)
      ),
    ); 

    if (rs != null) {
      if (rs[1]) {
        showToast(context, Config.deleteDraftBuildingSuccessMessage, true);
      } else {
        if (rs[0]) {
          setState(() {
            _listBuilding.clear();
            _isLoadingBuilding = true;
            _currentBuildingPage = initPage;
            _isLoadingBuildingMore = false;
            _systemZoneBloc.add(LoadListSystemZoneBuildings(id: initSystemZone.id, page: _currentBuildingPage, pageSize: pageSize));
            _historyBloc.add(LoadListHistory());
            showToast(context, Config.addBuildingSuccessMessage, true);
          });
        } else {
          showToast(context, Config.saveDraftBuildingSuccessMessage, true);
        }
      }
    }
  }

  Future<void> _getSystemZoneCenter() async {
    dynamic geomDecode = jsonDecode(initSystemZone.geom);
    List<LatLng> listPointTmp = new List<LatLng>();
    geomDecode[0].forEach((point) {
      listPointTmp.add(new LatLng(point[1], point[0]));
    });
    _systemZoneCenter = getCenterPolygon(listPointTmp);
  }

  void _goToCreateStorePage() async {
    dynamic rs = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => CreateStoreScreen(
          systemZoneCenter: _systemZoneCenter, 
        )
      ),
    ); 

    if(rs != null) {
      if (rs[1]) {
      } else {
        if (rs[0]) {
          setState(() {
            _listStore.clear();
            _isLoadingStore = true;
            _currentStorePage = initPage;
            _isLoadingStoreMore = false;
            _systemZoneBloc.add(LoadListSystemZoneStores(id: initSystemZone.id, page: _currentStorePage, pageSize: pageSize));
            _historyBloc.add(LoadListHistory());
          });
          showToast(context, Config.addStoreSuccessMessage, true);
        } else {
          showToast(context, Config.saveDraftStoreSuccessMessage, true);
        }
      }
    }
  }

  _goToUpdateBuildingScreen(int id) async {
    dynamic rs = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateBuildingScreen(
          buildingId: id,
          systemZoneCenter: _systemZoneCenter,
        )
      )
    );

    if (rs != null) {
      if (rs[1]) {
        if (rs[2]) {
          setState(() {
            _listBuilding.clear();
            _isLoadingBuilding = true;
            _currentBuildingPage = initPage;
            _isLoadingBuildingMore = false;
            _systemZoneBloc.add(LoadListSystemZoneBuildings(id: initSystemZone.id, page: _currentBuildingPage, pageSize: pageSize));
            _historyBloc.add(LoadListHistory());
            showToast(context, Config.deleteBuildingSuccessMessage, true);
          });
        } else {
          showToast(context, Config.deleteBuildingFailMessage, false);
        }
      } else {
        if (rs[0]) {
          setState(() {
            _listBuilding.clear();
            _isLoadingBuilding = true;
            _currentBuildingPage = initPage;
            _isLoadingBuildingMore = false;
            _systemZoneBloc.add(LoadListSystemZoneBuildings(id: initSystemZone.id, page: _currentBuildingPage, pageSize: pageSize));
            _historyBloc.add(LoadListHistory());
            showToast(context, Config.updateNeedSurveyBuildingSuccessMessage, true);
          });
        }
      }
    }
  }

  _goToUpdateStoreScreen(int id) async {
    dynamic rs = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => UpdateStoreScreen(
          storeId: id,
        )
      )  
    );

    if (rs != null) {
      if (rs[1]) {
        if (rs[2]) {
          setState(() {
            _listStore.clear();
            _isLoadingStore = true;
            _currentStorePage = initPage;
            _isLoadingStoreMore = false;
            _systemZoneBloc.add(LoadListSystemZoneStores(id: initSystemZone.id, page: _currentStorePage, pageSize: pageSize));
            _historyBloc.add(LoadListHistory());
          });
          showToast(context, Config.deleteStoreSuccessMessage, true);
        } else {
          showToast(context, Config.deleteStoreFailMessage, false);
        }
      } else {
        if (rs[0]) {
          setState(() {
            _listStore.clear();
            _isLoadingStore = true;
            _currentStorePage = initPage;
            _isLoadingStoreMore = false;
            _systemZoneBloc.add(LoadListSystemZoneStores(id: initSystemZone.id, page: _currentStorePage, pageSize: pageSize));
            _historyBloc.add(LoadListHistory());
          });
          showToast(context, Config.updateNeedSurveyStoreSuccessMessage, true);
        }
      }
    }
  }

  void _goToCreateFromDraftBuildingPage() async {
    dynamic rs = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => DraftBuildingScreen(
          systemZoneCenter: _systemZoneCenter
        )
      ) 
    );

    if (rs != null) {
      if(rs){
        _listBuilding.clear();
        _isLoadingBuilding = true;
        _currentBuildingPage = initPage;
        _isLoadingBuildingMore = false;
        _systemZoneBloc.add(LoadListSystemZoneBuildings(id: initSystemZone.id, page: _currentBuildingPage, pageSize: pageSize));
        _historyBloc.add(LoadListHistory());
        showToast(context, Config.addBuildingSuccessMessage, true);
      } 
    }
  }

  void _goToCreateFromDraftStorePage() async {
    dynamic rs = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => DraftStoreScreen(
          systemZoneCenter: _systemZoneCenter,
        )
      )
    );

    if (rs != null) {
      if(rs){
        _listStore.clear();
        _isLoadingStore = true;
        _currentStorePage = initPage;
        _isLoadingBuildingMore = false;
        _systemZoneBloc.add(LoadListSystemZoneStores(id: initSystemZone.id, page: _currentStorePage, pageSize: pageSize));
        _historyBloc.add(LoadListHistory());
        showToast(context, Config.addStoreSuccessMessage, true);
      } 
    }
  }
}