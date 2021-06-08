import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geodesy/geodesy.dart';
import 'package:osm_map_surveyor/bloc/building_bloc.dart';
import 'package:osm_map_surveyor/bloc/store_bloc.dart';
import 'package:osm_map_surveyor/events/building_event.dart';
import 'package:osm_map_surveyor/events/store_event.dart';
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/provider/authentication_provider.dart';
import 'package:osm_map_surveyor/repositories/building_repository.dart';
import 'package:osm_map_surveyor/repositories/store_repository.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/createbuilding/create_building_screen.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/updatebuilding/update_building_screen.dart';
import 'package:osm_map_surveyor/screens/drawer/drawer_view.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/states/building_state.dart';
import 'package:osm_map_surveyor/states/store_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/geolocator_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class BuildingGeneralPage extends StatefulWidget {
  BuildingGeneralPage({Key key}) : super(key: key);

  @override
  _BuildingGeneralPageState createState() => _BuildingGeneralPageState();
}

class _BuildingGeneralPageState extends State<BuildingGeneralPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String subHeaderContext = Config.subHeaderNeedSurveyBuildingContext;
  List<Building> listDraftBuildings;
  List<Building> listAllNeedSurveyBuildings;
  List<Building> listNeedSurveyBuildings;
  Map<int, int> listNeedSurveyDraftBuildingsId = Map<int, int>();
  String dropdownSystemZoneValue;

  List<String> _listSystemZoneNames = List<String>();
  bool _isDraft = false;
  bool _isReload;
  BuildingBloc _buildingBloc;
  StoreBloc _storeBloc;

  @override
  void initState() {
    super.initState();
    _buildingBloc = BuildingBloc(buildingRepository: BuildingRepository());
    _storeBloc = StoreBloc(storeRepository: StoreRepository());
    initDraftBuildings();
    initNeedSurveyBuilding();
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

  @override
  void dispose() {
    _storeBloc.close();
    _buildingBloc.close();
    super.dispose();
  }

  void initDraftBuildings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        int i = 1;
        bool isNotFound = false;
        while (!isNotFound) {
          String buildingPrefs = prefs.getString(Config.draftBuilding + i.toString());
          if (buildingPrefs == null) {
            isNotFound = true;
          } else {
            if (listDraftBuildings == null) {
              listDraftBuildings = [];
            }
            Building tmp = Building.fromJson(jsonDecode(buildingPrefs));
            listDraftBuildings.add(tmp);
            i += 1;
          }
        }
      },
    );
  }

  void initNeedSurveyBuilding() async {
    listNeedSurveyDraftBuildingsId = await getNeedSurveyDraftBuildings(initListNeedSurveyBuildings.toList());
    setState(() {
      listAllNeedSurveyBuildings = initListNeedSurveyBuildings.toList();
      listNeedSurveyBuildings = listAllNeedSurveyBuildings.toList();
    });
  }

  Future<Map<int, int>> getNeedSurveyDraftBuildings(List<Building> listBuildings) async {
    final prefs = await SharedPreferences.getInstance();
    Map<int, int> listNeedSurveyDraftBuildingsIdTmp = Map<int, int>();
    for (var building in listBuildings) {
      String buildingPrefs = prefs.getString(Config.draftUpdateBuilding + building.id.toString());
      if (buildingPrefs != null) {
        listNeedSurveyDraftBuildingsIdTmp.addAll({building.id: building.id});
      }
    }
    return listNeedSurveyDraftBuildingsIdTmp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Config.secondColor,
      appBar: appBar(context),
      endDrawer: appEndDrawer(context),
      body: body(context),
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
                'Building',
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
        color: Colors.white,
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
            _isDraft ? listDraftBuildingWidget(context) : SizedBox(),
            !_isDraft ? listNeedSurveyBuildingsWidget(context) : SizedBox(),
            blocListenerWidget(),
          ],
        ),
        onRefresh: refreshNeedSurveyBuildings,
      ),
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
              subHeaderContext = Config.subHeaderNeedSurveyBuildingContext;
            } else {
              _isDraft = true;
              subHeaderContext = Config.subHeaderDraftBuildingContext;
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
              width: MediaQuery.of(context).size.width * 0.2,
              child: _isDraft
                ? listDraftBuildings != null
                  ? Text(
                      listDraftBuildings.length.toString() + 
                        (listDraftBuildings.length < 2 ? " building" : " buildings"),
                    )
                    : SizedBox()
                  : listNeedSurveyBuildings != null
                    ? Text(listNeedSurveyBuildings.length.toString() +
                            (listNeedSurveyBuildings.length == 1 ? " building" : " buildings"),
                      )
                : SizedBox(),
            ),
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.001,
              ),
              child: Icon(Icons.replay_circle_filled, color: Config.secondColor, size: Config.textSizeMedium,),
            ),
          ],
        ),
      ),
    );
  }

  Widget listDraftBuildingWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: <Widget>[
          if (listDraftBuildings == null)
            Icon(
              Icons.cancel,
              size: MediaQuery.of(context).size.width * 0.1,
            ),
          if (listDraftBuildings == null)
            Text(
              "No draft building here!",
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            ),
          if (listDraftBuildings != null)
            for (var i = 0; i < listDraftBuildings.length; i++)
              buildingWidget(context, listDraftBuildings[i], (i + 1).toString(), null),
        ],
      ),
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
          dropdownColor: Config.secondColor,
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

  Widget listNeedSurveyBuildingsWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: <Widget>[
          if (listNeedSurveyBuildings != null && _isReload == false)
            for (final building in listNeedSurveyBuildings)
              listNeedSurveyDraftBuildingsId.containsKey(building.id)
                ? buildingWidget(context, building, null, building.id.toString())
                : buildingWidget(context, building, null, null),
          if (_isReload == true) circularProgressCustom(),
        ],
      ),
    );
  }

  Widget blocListenerWidget() {
    return MultiBlocListener(
      listeners: [
        needSurveyBuildingsBlocListener(),
        storeBlocListener(),
      ], 
      child: SizedBox(),
    );
  }

  Widget needSurveyBuildingsBlocListener() {
    return BlocListener(
      bloc: _buildingBloc,
      listener: (BuildContext context, BuildingState state) async {
        if (state is LoadNeedSurveyBuildingsFinishState) {
          listNeedSurveyDraftBuildingsId = await getNeedSurveyDraftBuildings(state.listBuildings.results.toList());
          setState(() {
            initListNeedSurveyBuildings = state.listBuildings.results.toList();
            listAllNeedSurveyBuildings = initListNeedSurveyBuildings.toList();
            onSystemzoneChange(null);
            _isReload = false;
          });
        }
      },
      child: SizedBox(),
    );
  }

  Widget storeBlocListener() {
    return BlocListener(
      bloc: _storeBloc,
      listener: (BuildContext context,StoreState state) async {
        if (state is LoadListStoreBuildingsFinishState) {
          
        } 
      },
      child: SizedBox(),
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

  Widget buildingWidget(
    BuildContext context, 
    Building building,
    String shareDraftPreferenceId, 
    String shareNeedSurveyDraftPreferenceId) {
    return FlatButton(
      onPressed: () {
        if (shareDraftPreferenceId != null) {
          goToCreateBuildingPage(building, shareDraftPreferenceId);
        } else {
          goToUpdateBuildingPage(building, shareNeedSurveyDraftPreferenceId);
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
              child: building.imageUrl == null
                ? setIconBuilding(building.type)
                : Image.network(building.imageUrl),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.02,
                ),
                child: building.name == null
                  ? Text("No name")
                  : building.name.isEmpty
                    ? Text("No name")
                    : building.name.length > 43
                      ? Tooltip(
                          message: building.name,
                          child: Text(building.name.substring(0, 40) + "..."),
                        )
                      : Text(building.name),
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

  Widget floatingActionButton(BuildContext context) {
    return FloatingActionButton(
        onPressed: () {
          goToCreateBuildingPage(null, null);
        },
        child: Icon(Icons.add),
        foregroundColor: Colors.white,
        backgroundColor: Config.secondColor
        );
  }

  void onSystemzoneChange(String value) {
    setState(() {
      if (value != null) dropdownSystemZoneValue = value.toString();
      if (dropdownSystemZoneValue == _listSystemZoneNames[0]) {
        listNeedSurveyBuildings.clear();
        listNeedSurveyBuildings = listAllNeedSurveyBuildings.toList();
      } else {
        listNeedSurveyBuildings.clear();
        listAllNeedSurveyBuildings.forEach((building) {
          if (building.systemZoneId == int.parse(dropdownSystemZoneValue.split(' ')[0])) {
            listNeedSurveyBuildings.add(building);
          }
        });
      }      
    });
  }

  void goToCreateBuildingPage(Building building, String sharePreferenceId) async {
    final prefs = await SharedPreferences.getInstance();
    dynamic rs;
    if (building != null && sharePreferenceId != null) {
      rs = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateBuildingScreen(
            initBuilding: building,
            sharePreferenceId: sharePreferenceId,
          )
        )
      );
    } else {
      rs = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateBuildingScreen()));
    }

    if (rs != null) {
      setState(() {
        listDraftBuildings = null;
        int i = 1;
        bool isNotFound = false;
        while (!isNotFound) {
          String buildingPrefs = prefs.getString(Config.draftBuilding + i.toString());
          if (buildingPrefs == null) {
            isNotFound = true;
          } else {
            if (listDraftBuildings == null) {
              listDraftBuildings = [];
            }
            Building tmp = Building.fromJson(jsonDecode(buildingPrefs));
            listDraftBuildings.add(tmp);
            i += 1;
          }
        }
      });
      if (rs[1]) {
        showToast(Config.deleteDraftBuildingSuccessMessage, true);
      } else {
        if (rs[0]) {
          showToast(Config.addBuildingSuccessMessage, true);
        } else {
          showToast(Config.saveDraftBuildingSuccessMessage, true);
        }
      }
    }
  }

  SvgPicture setIconBuilding(String type) {
    if (type != null) {
      if (type.contains("school") || type.contains("university")) {
        return SvgPicture.asset(
          Config.schoolSvgIcon,
          color: Config.secondColor,
        );
      } else if (type.contains("apartment")) {
        return SvgPicture.asset(
          Config.apartmentSvgIcon,
          color: Config.secondColor,
        );
      } else if (type.contains("hospital")) {
        return SvgPicture.asset(
          Config.hospitalSvgIcon,
          color: Config.secondColor,
        );
      } else if (type.contains("pitch")) {
        return SvgPicture.asset(
          Config.pitchSvgIcon,
          color: Config.secondColor,
        );
      } else if (type.contains("retail") ||
          type.contains("supermarket") ||
          type.contains("market")) {
        return SvgPicture.asset(
          Config.supermarketSvgIcon,
          color: Config.secondColor,
        );
      }
    }
    return SvgPicture.asset(
      Config.buildingSvgIcon,
      color: Config.secondColor,
    );
  }

  void goToUpdateBuildingPage(
    Building building, String shareNeedSurveyDraftPreferenceId
  ) async {
    dynamic rs;
    rs = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateBuildingScreen(
          buildingId: building.id,
          systemZoneCenter: null,
        )
      )
    );
    if (rs != null) {
      if (rs[1]) {
        _isReload = true;
        _buildingBloc.add(LoadNeedSurveyBuildings());
        LatLng point;
        dynamic rs = await getCurrentLocation();
        point = new LatLng(rs.latitude, rs.longitude);
        _storeBloc.add(LoadListStoreBuildings(point: point));
        if (rs[2]) {
          showToast(Config.deleteBuildingSuccessMessage, true);
        } else {
          showToast(Config.deleteBuildingFailMessage, false);
        }
      } else {
        _isReload = true;
        _buildingBloc.add(LoadNeedSurveyBuildings());
        LatLng point;
        dynamic rs = await getCurrentLocation();
        point = new LatLng(rs.latitude, rs.longitude);
        _storeBloc.add(LoadListStoreBuildings(point: point));
        if (rs[0]) {
          showToast(Config.updateNeedSurveyBuildingSuccessMessage, true);
        } else {
          showToast(Config.saveNeedSurveyDraftBuildingSuccessMessage, true);
        }
      }
    }
  }

  void openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  Future<bool> getDraftNeedSurveyBuilding(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String buildingPrefs = prefs.getString(Config.draftBuilding + id.toString());
    if (buildingPrefs != null) {
      return true;
    }
    return false;
  }

  Future<Null> refreshNeedSurveyBuildings() async {
    setState(() {
      if (!_isReload) {
        _isReload = true;
        _buildingBloc.add(LoadNeedSurveyBuildings());
      }
    });
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
