import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:osm_map_surveyor/bloc/systemzone_bloc.dart';
import 'package:osm_map_surveyor/events/systemzone_event.dart';
import 'package:osm_map_surveyor/models/systemzone.dart';
import 'package:osm_map_surveyor/provider/authentication_provider.dart';
import 'package:osm_map_surveyor/repositories/systemzone_repository.dart';
import 'package:osm_map_surveyor/screens/drawer/drawer_view.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/screens/systemzonescreen/systemdetailsscreen/systemzone_details_screen.dart';
import 'package:osm_map_surveyor/states/systemzone_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/geojson_utils.dart';
import 'package:osm_map_surveyor/utilities/popup_utils.dart';

class SystemzoneScreen extends StatefulWidget {
  @override
  _SystemzoneScreenState createState() => _SystemzoneScreenState();
}

class _SystemzoneScreenState extends State<SystemzoneScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final ScrollController _scrollAllSystemZoneController = ScrollController();
  final ScrollController _scrollMySystemZoneController = ScrollController();
  static const double _endReachedThreshold = 100;
  final int pageSize = 20;
  final int initPage = 1;

  List<String> _listDistrictValue;
  List<String> _listMyDistrictValue;
  int _currentAllSystemZonePage;
  int _totalAllSystemZonePage;
  int _currentMySystemZonePage;
  int _totalMySystemZonePage;
  List<SystemZone> _listSystemZone;
  List<SystemZone> _listMySystemZone;
  List<SystemZone> _listSystemZoneShow;
  List<SystemZone> _listMySystemZoneShow;
  String _districtValue;
  String _myDistrictValue;
  bool _isAllSystemZoneLoadMore;
  bool _isMySystemZoneLoadMore;
  bool _isLoadDistrict;
  bool _isLoadMyDistrict;
  SystemZoneBloc _systemZoneBloc;

  @override
  void initState() { 
    super.initState();
    _systemZoneBloc = SystemZoneBloc(systemZoneRepository: SystemZoneRepository());
    _listDistrictValue = new List<String>();
    _listMyDistrictValue = new List<String>();
    _listSystemZone = new List<SystemZone>();
    _listMySystemZone = new List<SystemZone>();
    _listSystemZoneShow = new List<SystemZone>();
    _listMySystemZoneShow = new List<SystemZone>();
    _listDistrictValue.add('All');
    initListDistrict.forEach((district) {
      _listDistrictValue.add(district.id.toString() + ' ' + district.name.toString());
    });
    _districtValue = _listDistrictValue[0];
    _currentAllSystemZonePage = initPage;
    _currentMySystemZonePage = initPage;
    _isAllSystemZoneLoadMore = false;
    _isMySystemZoneLoadMore = false;
    _isLoadDistrict = false;
    _isLoadMyDistrict = false;
    _initFunction();
    _scrollAllSystemZoneController.addListener(_onAllSystemZoneScroll);
    _scrollMySystemZoneController.addListener(_onMySystemZoneScroll);
  }

  @override
  void dispose() { 
    _systemZoneBloc.close();
    _scrollAllSystemZoneController.dispose();
    _scrollMySystemZoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(context),
      endDrawer: appEndDrawer(context),
      body: body(context),
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
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.025,
                    ),
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: Image.asset(
                      Config.logoOfficialPng,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Surveyor',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Config.textSizeSmall * 1.1,
                      ),
                    ),
                  )
                ],
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

  Widget body(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            _systemZoneBlocListener(),
            RefreshIndicator(
              color: Config.secondColor,
              onRefresh: _refreshSystemZone,
              child: DefaultTabController(
                length: 2, 
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
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
                                    'My system zone',
                                    style: TextStyle(
                                      fontSize: Config.textSizeSmall,
                                      color: Config.secondColor,
                                      fontWeight: FontWeight.w200,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'All system zone',
                                    style: TextStyle(
                                      fontSize: Config.textSizeSmall,
                                      color: Config.secondColor,
                                      fontWeight: FontWeight.w200,
                                    ),
                                  ),
                                ),
                              ]
                            ),
                          ),
                        ],
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.8,
                              child: TabBarView(
                                children: [
                                  _mySystemZoneView(context),
                                  _allSystemZoneView(context),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _systemZoneBlocListener() {
    return BlocListener(
      bloc: _systemZoneBloc,
      listener: (BuildContext context,SystemZoneState state) async {
        if (state is LoadListSystemZoneFinishState) {
          if (state.listSystemZone != null) {
            if (_listSystemZone.length == 0) {
              setState(() {
                if (_isAllSystemZoneLoadMore) _isAllSystemZoneLoadMore = false;
                if (_isLoadDistrict) _isLoadDistrict = false;
                _listSystemZone = state.listSystemZone.results.toList();
                _listSystemZoneShow.clear();
                _listSystemZoneShow = _listSystemZone.toList();
                _totalAllSystemZonePage = state.listSystemZone.totalNumberOfPages;
                _currentAllSystemZonePage = state.listSystemZone.pageNumber;
              });
            } else {
              setState(() {
                if (_isAllSystemZoneLoadMore) _isAllSystemZoneLoadMore = false;
                if (_isLoadDistrict) _isLoadDistrict = false;
                _listSystemZone.addAll(state.listSystemZone.results.toList());
                _listSystemZoneShow.clear();
                _listSystemZoneShow = _listSystemZone.toList();
                _totalAllSystemZonePage = state.listSystemZone.totalNumberOfPages;
                _currentAllSystemZonePage = state.listSystemZone.pageNumber;
              });
            }
          } else {
            PopupUtils.utilShowLoginDialog(Config.loadingSystemZoneFail, Config.loadingSystemZoneFailBody, context);
          }
        } else if (state is LoadListSystemZoneIsMeFinishState) {
          if (state.listSystemZone != null) {
            setState(() {
              if (_listMySystemZone.length == 0) {
                if (!_listMyDistrictValue.contains('All')) {
                  _listMyDistrictValue.add('All');
                }
                List<int> listDistrictId = new List<int>();
                state.listSystemZone.results.toList().forEach((systemZone) {
                  initListDistrict.forEach((district) {
                    district.wards.forEach((ward) {
                      if (ward.id == systemZone.wardId) {
                        if (!listDistrictId.contains(district.id)) {
                          listDistrictId.add(district.id);
                        }
                      }
                    });
                  });
                });
                listDistrictId.forEach((id) {
                  initListDistrict.forEach((district) {
                    if (district.id == id) {
                      String tmp = district.id.toString() + ' ' + district.name.toString();
                      if (!_listMyDistrictValue.contains(tmp)) {
                        _listMyDistrictValue.add(tmp);
                      }
                    }
                  });
                });
                if (_myDistrictValue == null) {
                  _myDistrictValue = _listMyDistrictValue[0];
                }
                if (_isMySystemZoneLoadMore) _isMySystemZoneLoadMore = false;
                if (_isLoadMyDistrict) _isLoadMyDistrict = false;
                _listMySystemZone = state.listSystemZone.results.toList();
                _listMySystemZoneShow.clear();
                _listMySystemZoneShow = _listMySystemZone.toList();
                _totalMySystemZonePage = state.listSystemZone.totalNumberOfPages;
                _currentMySystemZonePage = state.listSystemZone.pageNumber;
              } else {
                setState(() {
                  if (!_listMyDistrictValue.contains('All')) {
                    _listMyDistrictValue.add('All');
                  }
                  List<int> listDistrictId = new List<int>();
                  state.listSystemZone.results.toList().forEach((systemZone) {
                    initListDistrict.forEach((district) {
                      district.wards.forEach((ward) {
                        if (ward.id == systemZone.wardId) {
                          if (!listDistrictId.contains(district.id)) {
                            listDistrictId.add(district.id);
                          }
                        }
                      });
                    });
                  });
                  listDistrictId.forEach((id) {
                    initListDistrict.forEach((district) {
                      if (district.id == id) {
                        String tmp = district.id.toString() + ' ' + district.name.toString();
                        if (!_listMyDistrictValue.contains(tmp)) {
                          _listMyDistrictValue.add(tmp);
                        }
                      }
                    });
                  });
                  if (_myDistrictValue == null) {
                    _myDistrictValue = _listMyDistrictValue[0];
                  }
                  if (_isMySystemZoneLoadMore) _isMySystemZoneLoadMore = false;
                  if (_isLoadMyDistrict) _isLoadMyDistrict = false;
                  _listMySystemZone.addAll(state.listSystemZone.results.toList());
                  _listMySystemZoneShow.clear();
                  _listMySystemZoneShow = _listMySystemZone.toList();
                  _totalMySystemZonePage = state.listSystemZone.totalNumberOfPages;
                  _currentMySystemZonePage = state.listSystemZone.pageNumber;
                });
              }
            });
          } else {
            PopupUtils.utilShowLoginDialog(Config.loadingSystemZoneFail, Config.loadingSystemZoneFailBody, context);
          }
        } else if (state is LoadNeedSurveySystemZoneMapFinishState) {
          if (state.rs != null) {
            await getInitNeedSurveySystemZonePolygons(state.rs.toString());
          }
        }
      },
      child: SizedBox(),
    );
  }

  Widget _allSystemZoneView(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          _dropDownDistrictWidget(context),
          _listSystemZoneWidget(context),
        ],
      ),
    );
  }

  Widget _mySystemZoneView(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          _dropDownMyDistrictWidget(context),
          _listMySystemZoneWidget(context),
        ],
      ),
    );
  }

  Widget _dropDownDistrictWidget(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.075,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Config.secondColor,
              border: Border.all(
                color: Config.secondColor,
              ),
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.02,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 3,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width * 0.945,
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.005,
              bottom: MediaQuery.of(context).size.height * 0.005,
              left: MediaQuery.of(context).size.width * 0.0275,
              right: MediaQuery.of(context).size.width * 0.0275,
            ),
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.02,
              right: MediaQuery.of(context).size.width * 0.02,
              top: MediaQuery.of(context).size.height * 0.005,
              bottom: MediaQuery.of(context).size.height * 0.005,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _districtValue,
                icon: Icon(Icons.arrow_drop_down, color: Colors.white,),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Config.textSizeSmall,
                ),
                dropdownColor: Config.secondColor,
                onChanged: (String value) {
                  setState(() {
                    if (_districtValue != value) {
                      _districtValue = value;
                      if (_districtValue == 'All') {
                        _onDistrictChange(null);
                      } else {
                        _onDistrictChange(int.parse(_districtValue.split(' ')[0]));
                      }
                    }
                  });
                },
                items: _listDistrictValue.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: value != 'All'
                      ? Text(value.substring(value.indexOf(' '), value.length)) 
                      : Text(value.toString()),
                  );
                }).toList(),
              ),
            )
          ),
        ],
      )
    );
  }

  Widget _dropDownMyDistrictWidget(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.075,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Config.secondColor,
              border: Border.all(
                color: Config.secondColor,
              ),
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.02,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 3,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width * 0.945,
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.005,
              bottom: MediaQuery.of(context).size.height * 0.005,
              left: MediaQuery.of(context).size.width * 0.0275,
              right: MediaQuery.of(context).size.width * 0.0275,
            ),
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.02,
              right: MediaQuery.of(context).size.width * 0.02,
              top: MediaQuery.of(context).size.height * 0.005,
              bottom: MediaQuery.of(context).size.height * 0.005,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _myDistrictValue,
                icon: Icon(Icons.arrow_drop_down, color: Colors.white,),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Config.textSizeSmall,
                ),
                dropdownColor: Config.secondColor,
                onChanged: (String value) {
                  setState(() {
                    if (_myDistrictValue != value) {
                      _myDistrictValue = value;
                      if (_myDistrictValue == 'All') {
                        _onMyDistrictChange(null);
                      } else {
                        _onMyDistrictChange(int.parse(_myDistrictValue.split(' ')[0]));
                      }
                    }
                  });
                },
                items: _listMyDistrictValue.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: value != 'All'
                      ? Text(value.substring(value.indexOf(' '), value.length)) 
                      : Text(value.toString()),
                  );
                }).toList(),
              ),
            )
          ),
        ],
      )
    );
  }

  Widget _listSystemZoneWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.725,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.725,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.055,
            ),
            child: CustomScrollView(
              controller: _scrollAllSystemZoneController,
              slivers: [
                if (_listSystemZone.length > 0) SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return _systemZoneWidget(context, index);
                    },
                    childCount: _listSystemZoneShow.length,
                  ),
                ),
                if (_listSystemZone.length == 0 && !_isLoadDistrict) SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        alignment: Alignment.center,
                        child: Text(
                          'No system zone available',
                        ),
                      );
                    },
                    childCount: 1,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _isAllSystemZoneLoadMore
                    ? Container(
                      padding: EdgeInsets.only(bottom: 16),
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )
                    : SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _listMySystemZoneWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.725,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.725,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.055,
            ),
            child: CustomScrollView(
              controller: _scrollMySystemZoneController,
              slivers: [
                if (_listMySystemZone.length > 0) SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return _mySystemZoneWidget(context, index);
                    },
                    childCount: _listMySystemZoneShow.length,
                  ),
                ),
                if (_listMySystemZone.length == 0 && !_isLoadMyDistrict) SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        alignment: Alignment.center,
                        child: Text(
                          'No system zone available',
                        ),
                      );
                    },
                    childCount: 1,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _isMySystemZoneLoadMore
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
          ),
        ],
      ),
    );
  }

  Widget _systemZoneWidget(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => SystemZoneDetailsScreen(initSystemZone: _listSystemZoneShow[index],)
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.0065,
          bottom: MediaQuery.of(context).size.height * 0.0065,
          left: MediaQuery.of(context).size.width * 0.025,
          right: MediaQuery.of(context).size.width * 0.025,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black26,
            width: MediaQuery.of(context).size.height * 0.001,
          ),
          borderRadius: BorderRadius.circular(
            MediaQuery.of(context).size.width * 0.02,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 0.5,
              offset: Offset(1, 2),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.02,
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.08,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text(
                _listSystemZoneShow[index].name,
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                ),
                child: Icon(
                  Icons.arrow_forward_ios, 
                  size: Config.textSizeSuperSmall,
                  color: Config.redColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } 

  Widget _mySystemZoneWidget(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => SystemZoneDetailsScreen(initSystemZone: _listMySystemZoneShow[index],)
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.0065,
          bottom: MediaQuery.of(context).size.height * 0.0065,
          left: MediaQuery.of(context).size.width * 0.025,
          right: MediaQuery.of(context).size.width * 0.025,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black26,
            width: MediaQuery.of(context).size.height * 0.001,
          ),
          borderRadius: BorderRadius.circular(
            MediaQuery.of(context).size.width * 0.02,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 0.5,
              offset: Offset(1, 2),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.02,
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.08,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text(
                _listMySystemZoneShow[index].name,
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                ),
                child: Icon(
                  Icons.arrow_forward_ios, 
                  size: Config.textSizeSuperSmall,
                  color: Config.redColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } 

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  void _initFunction() {
    _onMyDistrictChange(null);
    _onDistrictChange(null);
  }

  Future<Null> _refreshSystemZone() async {
    _systemZoneBloc.add(LoadNeedSurveySystemZoneMap());
    _onMyDistrictChange(null);
    _onDistrictChange(null);
  }

  void _onMyDistrictChange(int value) {
    setState(() {
      _isLoadMyDistrict = true;
      _currentMySystemZonePage = 1;
      _totalMySystemZonePage = null;
      _listMySystemZone.clear();
      _systemZoneBloc.add(LoadListSystemZone(districtId: value, page: _currentMySystemZonePage, pageSize: pageSize, isMe: true));
    });
  } 

  void _onDistrictChange(int value) {
    setState(() {
      _isLoadDistrict = true;
      _currentAllSystemZonePage = 1;
      _totalAllSystemZonePage = null;
      _listSystemZone.clear();
      _systemZoneBloc.add(LoadListSystemZone(districtId: value, page: _currentAllSystemZonePage, pageSize: pageSize, isMe: null));
    });
  }

  void _onLoadAllSystemZoneMore() {
    setState(() {
      _isAllSystemZoneLoadMore = true;
    });
    int value;
    if (_districtValue == 'All') {
      value = null;
    } else {
      value = int.parse(_districtValue.split(' ')[0]);
    }
    _currentAllSystemZonePage += 1;
    _systemZoneBloc.add(LoadListSystemZone(districtId: value, page: _currentAllSystemZonePage, pageSize: pageSize, isMe: null));
  }

  void _onLoadMySystemZoneMore() {
    setState(() {
      _isMySystemZoneLoadMore = true;
    });
    int value;
    if (_myDistrictValue == 'All') {
      value = null;
    } else {
      value = int.parse(_myDistrictValue.split(' ')[0]);
    }
    _currentMySystemZonePage += 1;
    _systemZoneBloc.add(LoadListSystemZone(districtId: value, page: _currentMySystemZonePage, pageSize: pageSize, isMe: true));
  }

  void _onAllSystemZoneScroll() {
    // Only run the under code if controller is mounted and no loading
    if (_totalAllSystemZonePage != null) {
      if (!_scrollAllSystemZoneController.hasClients || 
        _isLoadDistrict || 
        _isAllSystemZoneLoadMore || 
        _listSystemZone.length == 0 || 
        _currentAllSystemZonePage == _totalAllSystemZonePage) return;

      // check is reach the end 
      final thresholdReached = _scrollAllSystemZoneController.position.extentAfter < _endReachedThreshold; 
      
      if (thresholdReached) {
        _onLoadAllSystemZoneMore();
      }
    }
  }

  void _onMySystemZoneScroll() {
    // Only run the under code if controller is mounted and no loading
    if (_totalMySystemZonePage != null) {
      if (!_scrollMySystemZoneController.hasClients || 
        _isLoadMyDistrict || 
        _isMySystemZoneLoadMore || 
        _listMySystemZone.length == 0 || 
        _currentMySystemZonePage == _totalMySystemZonePage) return;

      // check is reach the end 
      final thresholdReached = _scrollMySystemZoneController.position.extentAfter < _endReachedThreshold; 
      
      if (thresholdReached) {
        _onLoadMySystemZoneMore();
      }
    }
  }
}