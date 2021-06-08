import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geojson/geojson.dart';
import 'package:osm_map_surveyor/bloc/building_bloc.dart';
import 'package:osm_map_surveyor/bloc/store_bloc.dart';
import 'package:osm_map_surveyor/events/building_event.dart';
import 'package:osm_map_surveyor/events/store_event.dart';
import 'package:osm_map_surveyor/models/buiildingpolygon.dart';
import 'package:osm_map_surveyor/models/storepoint.dart';
import 'package:osm_map_surveyor/provider/authentication_provider.dart';
import 'package:osm_map_surveyor/repositories/building_repository.dart';
import 'package:osm_map_surveyor/repositories/store_repository.dart';
import 'package:osm_map_surveyor/screens/drawer/drawer_view.dart';
import 'package:osm_map_surveyor/screens/historyscreen/history_screen.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/screens/map/map_popup/building_popup/building_details_popup.dart';
import 'package:osm_map_surveyor/screens/map/map_popup/building_popup/building_needsurvey_popup.dart';
import 'package:osm_map_surveyor/screens/map/map_popup/store_popup/store_details_popup.dart';
import 'package:osm_map_surveyor/screens/map/map_popup/store_popup/store_needsurvey_popup.dart';
import 'package:osm_map_surveyor/states/building_state.dart';
import 'package:osm_map_surveyor/states/store_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/geojson_utils.dart';
import 'package:toast/toast.dart';
import 'package:user_location/user_location.dart';
import 'package:geopoint/geopoint.dart';
import 'package:pedantic/pedantic.dart';
import 'package:map_controller/map_controller.dart';

int buildingPopupId;
int storePopupId;
int surveyRequestPopupId;

class MapGeneralPage extends StatefulWidget {
  MapGeneralPage({Key key}) : super(key: key);

  @override
  _MapGeneralPageState createState() => _MapGeneralPageState();
}

class _MapGeneralPageState extends State<MapGeneralPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final int _systemZoneChoice = 1;
  final int _buildingChoice = 2;
  final int _storeChoice = 3;

  MapController mapController;
  StatefulMapController statefulMapController;
  UserLocationOptions userLocationOptions;
  List<Marker> markers = [];
  Geodesy geodesy = Geodesy();

  BuildingBloc _buildingBloc;
  StoreBloc _storeBloc;
  List<BuildingPolygon> _buildingPolygonOnMap = List<BuildingPolygon>();
  List<StorePoint> _listStorePointOnMap = List<StorePoint>();
  List<Polygon> _buildingOnMapPolygons = List<Polygon>();
  List<Marker> _buildingOnMapPoints = List<Marker>();
  List<Polygon> _needSurveyBuildingOnMapPolygons = List<Polygon>();
  List<Marker> _needSurveyStoreOnMapPoints = List<Marker>();
  List<Marker> _needSurveyBuildingCenterPoints = List<Marker>();
  List<Marker> _storeOnMapPoints = List<Marker>();
  List<Marker> _surveyRequestPoints = List<Marker>();
  LatLng centerPoint;
  bool _isMove = false;
  bool _isLoadingBuildingPolygons = false;
  bool _isLoadingStorePoint = false;
  bool _isShowNeedSurveyBuildingPoints = false;
  bool _isShowBuildingOnMapPoints = false;
  bool _isShowSystemZone = false;
  bool _isShowBuilding = false;
  bool _isShowZoomBuilding = false;
  bool _isShowStore = false;
  bool _isShowZoomStore = false;
  bool _initNeedSurveyPolygonsAnhPoints = false;
  bool _initNeedSurveyStorePoints = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    _buildingBloc = BuildingBloc(buildingRepository: BuildingRepository());
    _storeBloc = StoreBloc(storeRepository: StoreRepository());
    _isShowSystemZone = true;
    _isShowBuilding = true;
    _isShowStore = true;
    _isShowNeedSurveyBuildingPoints = true;
    _isShowBuildingOnMapPoints = true;
    _isShowZoomBuilding = true;
    if (historyLocation != null) {
      centerPoint = historyLocation;
      historyLocation = null;
    } 
  }

  @override
  void dispose() {
    super.dispose();
    _buildingBloc.close();
    _storeBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: appEndDrawer(context),
      appBar: appBar(context),
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
                ),
            ),
          )
        )
      ],
    );
  }

  Widget body(BuildContext context) {
    return Stack(
      children: <Widget>[
        map(context),
        filterWidget(context),
        blocListenerWidget(),
      ],
    );
  }

  Widget blocListenerWidget() {
    return MultiBlocListener(
      listeners: [
        buildingBlocListener(),
        storeBlocListener(),
      ], 
      child: SizedBox(),
    );
  }

  Widget buildingBlocListener() {
    return BlocListener(
      bloc: _buildingBloc,
      listener: (BuildContext context,BuildingState state) async {
        if (state is LoadBuildingByFourBoundsFinishDataState) {
          setState(() {
            loadBuildingOnMapPolygons(state.rs.toString());
            _isLoadingBuildingPolygons = false;
          });
        } else if (state is LoadNeedSurveyBuildingsFinishState) {
          setState(() {
            initListNeedSurveyBuildings = state.listBuildings.results.toList();
          });
        } else if (state is LoadListNeedSurveyBuildingsMapFinishState) {
          await getInitNeedSurveyBuildingPolygons(state.rs.toString());
          setState(() {
            _initNeedSurveyPolygonsAnhPoints = false;
            setNeedSurveyBuildingPolygon();
          });
          _buildingBloc.add(LoadNeedSurveyBuildings());
        }
      },
      child: SizedBox(),
    );
  }

  Widget storeBlocListener() {
    return BlocListener(
      bloc: _storeBloc,
      listener: (BuildContext context,StoreState state) async {
        if (state is LoadStoreByFourBoundsDataFinishState) {
          setState(() {
            loadStoreOnMapPoints(state.rs.toString());
            _isLoadingStorePoint = false;
          });
        } else if (state is LoadNeedSurveyStoresFinishState) {
          setState(() {
            initListNeedSurveyStores = state.listStores.results.toList();
          });
        } else if (state is LoadListNeedSurveyStoresMapFinishState) {
          await getInitStoreOnMapPoints(state.rs.toString());
          setState(() {
            _initNeedSurveyStorePoints = false;
            setNeedSurveyStoreOnMapPoints();
          });
          _storeBloc.add(LoadNeedSurveyStores());
        }
      },
      child: SizedBox(),
    );
  }

  Widget map(BuildContext context) {
     userLocationOptions = UserLocationOptions(
      fabRight: MediaQuery.of(context).size.width * 0.05,
      showMoveToCurrentLocationFloatingActionButton: true,
      updateMapLocationOnPositionChange: false,
      context: context,
      mapController: mapController,
      markers: markers,
    );
    setNeedSurveyBuildingPolygon();
    setNeedSurveyStoreOnMapPoints();
    return Listener(
      onPointerUp: (event) {
        if (mapController.zoom <= 18) {
          setState(() {
            _isShowBuildingOnMapPoints = true;
            _isShowZoomBuilding = true;
          });
        } else {
          setState(() {
            _isShowBuildingOnMapPoints = false;
            _isShowZoomBuilding = false;
          });
        }
        if (mapController.zoom <= 16.8) {
          _isShowZoomStore = false;
        } else {
          _isShowZoomStore = true;
        }
        if(_isMove && !_isLoadingBuildingPolygons && !_isLoadingStorePoint) {
          setState(() {
            _listStorePointOnMap.clear();
            _storeOnMapPoints.clear();
            _buildingOnMapPolygons.clear();
            _buildingOnMapPoints.clear();
          });
          if(_isShowBuilding && _isShowZoomBuilding) {
            _isLoadingBuildingPolygons = true;
            _buildingBloc.add(
              LoadBuildingByFourBounds(
                northWest: mapController.bounds.northWest,
                northEast: mapController.bounds.northEast,
                southEast: mapController.bounds.southEast,
                southWest: mapController.bounds.southWest
              )
            );
          }
          if(_isShowStore && _isShowZoomStore) {
            _isLoadingStorePoint = true;
            _storeBloc.add(
              LoadStoresByFourBounds(
                northWest: mapController.bounds.northWest,
                northEast: mapController.bounds.northEast,
                southEast: mapController.bounds.southEast,
                southWest: mapController.bounds.southWest
              )
            );
          }
          _isMove = false;
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.925,
        child: FlutterMap(
          options: MapOptions(
            center: centerPoint == null ? LatLng(10.841576, 106.809069) : centerPoint,
            minZoom: Config.zoomMin,
            maxZoom: Config.zoomMax,
            zoom: Config.zoomInit,
            plugins: [UserLocationPlugin(),],
            onTap: (point) {
              if (_isShowSystemZone || _isShowBuilding) {
                checkBuilding(point, null, false);
              }
            },
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
                _isMove = true;
              }
            },
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: Config.urlTemplateOSM,
              subdomains: ['a', 'b', 'c'],
            ),
            if (_isShowBuilding && _isShowZoomBuilding) PolygonLayerOptions(
              polygons: _buildingOnMapPolygons != null
                ? _buildingOnMapPolygons : [],
            ),
            if (_isShowBuilding && _isShowZoomBuilding && _isShowBuildingOnMapPoints) MarkerLayerOptions(
              markers: _buildingOnMapPoints != null
                ? _buildingOnMapPoints
                : [],
            ),
            if (_isShowStore && _isShowZoomStore) MarkerLayerOptions(
              markers: _storeOnMapPoints != null 
                ? _storeOnMapPoints : [],
            ),
            if (_isShowSystemZone) PolygonLayerOptions(
              polygons: initListNeedSurveySystemZonePolygons != null
              ? initListNeedSurveySystemZonePolygons : [],
            ),
            if (_isShowSystemZone) PolygonLayerOptions(
              polygons: _needSurveyBuildingOnMapPolygons != null
                ? _needSurveyBuildingOnMapPolygons : [],
            ),
            if (_isShowSystemZone && _isShowNeedSurveyBuildingPoints) MarkerLayerOptions(
              markers: _needSurveyBuildingCenterPoints != null
                ? _needSurveyBuildingCenterPoints
                : [],
            ),
            if (_isShowSystemZone) MarkerLayerOptions(
              markers: _needSurveyStoreOnMapPoints != null 
                ? _needSurveyStoreOnMapPoints 
                : [] 
            ),
            if (_isShowSystemZone) MarkerLayerOptions(
              markers: _surveyRequestPoints != null 
                ? _surveyRequestPoints 
                : [] 
            ),
            MarkerLayerOptions(markers: markers),
            userLocationOptions,
          ],
          mapController: mapController,
        ),
      ),
    );
  }

  Widget filterWidget(BuildContext context) {
    return Positioned(
      right: MediaQuery.of(context).size.width * 0.02,
      top: MediaQuery.of(context).size.height * 0.02,
      child: filterMenuPopup(),
    );
  }

  Widget filterMenuPopup() => PopupMenuButton(
    itemBuilder: (context) {
      var list = List<PopupMenuEntry<Object>>();
      list.add(
        PopupMenuItem(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.height * 0.25,
            child: Row(
              children: [
                _isShowSystemZone
                  ? Icon(Icons.check, color: Config.secondColor,) 
                  : SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                Text(
                  "System zone",
                  style: TextStyle(
                    color: Colors.black
                  ),
                )
              ],
            ),
          ),
          value: _systemZoneChoice,
        ),
      );
      list.add(
        PopupMenuDivider(
          height: 10,
        ),
      );
      list.add(
        PopupMenuItem(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.height * 0.25,
            child: Row(
              children: [
                _isShowBuilding
                  ? Icon(Icons.check, color: Config.secondColor,) 
                  : SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                Text(
                  "Building",
                  style: TextStyle(
                    color: Colors.black
                  ),
                )
              ],
            ),
          ),
          value: _buildingChoice,
        ),
      );
      list.add(
        PopupMenuDivider(
          height: 10,
        ),
      );
      list.add(
        PopupMenuItem(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.height * 0.25,
            child: Row(
              children: [
                _isShowStore
                  ? Icon(Icons.check, color: Config.secondColor,) 
                  : SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                Text(
                  "Store",
                  style: TextStyle(
                    color: Colors.black
                  ),
                )
              ],
            ),
          ),
          value: _storeChoice,
        ),
      );
      return list;
    },
    onSelected: (value) {
      if (value == _systemZoneChoice) {
        setState(() {
          if (_isShowSystemZone) {
            _isShowSystemZone = false;
          } else {
            _isShowSystemZone = true;
          }
        });
      } else if (value == _buildingChoice) {
        setState(() {
          if (_isShowBuilding) {
            _isShowBuilding = false;
            _isShowBuildingOnMapPoints = false;
            _buildingOnMapPolygons.clear();
            _buildingOnMapPoints.clear();
          } else {
            _isShowBuilding = true;
            _isShowBuildingOnMapPoints = true;
            _isLoadingBuildingPolygons = true;
            if (_isShowBuilding && _isShowZoomBuilding) {
              _buildingBloc.add(
                LoadBuildingByFourBounds(
                  northWest: mapController.bounds.northWest,
                  northEast: mapController.bounds.northEast,
                  southEast: mapController.bounds.southEast,
                  southWest: mapController.bounds.southWest
                ) 
              );
            }
          }
        });
      } else if (value == _storeChoice) {
        setState(() {
          if (_isShowStore) {
            _isShowStore = false;
            _storeOnMapPoints.clear();
          } else {
            _isShowStore = true;
            _isLoadingStorePoint = true;
            if (_isShowStore && _isShowZoomStore) {
              _storeBloc.add(
                LoadStoresByFourBounds(
                  northWest: mapController.bounds.northWest,
                  northEast: mapController.bounds.northEast,
                  southEast: mapController.bounds.southEast,
                  southWest: mapController.bounds.southWest
                )
              );
            }
          }
        });
      }
    },
    color: Colors.white60,
    child: Container(
      height: MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.width * 0.3,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width * 0.025,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: MediaQuery.of(context).size.height * 0.008,
            color: Colors.black.withOpacity(0.1),
            spreadRadius: MediaQuery.of(context).size.height * 0.003,
          )
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
          Icon(Icons.filter_alt_outlined, color: Config.secondColor,),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
          Text(
            "Filter",
            style: TextStyle(
              fontSize: Config.textSizeSmall,
            ),
          ),
        ],
      ),
    ),
  );

  Widget iconForNeedSurveyPolygon(int status) {
    if (status == 1) {
      return Container(
        child: Image.asset(
          Config.buildingSurveyedPngIcon,
        ),
      );
    } else if (status == 2) {
      return Container(
        child: Image.asset(
          Config.buildingNeedSurveyPngIcon,
        ),
      );
    } else {
      return Container(
        child: Image.asset(
          Config.buildingNeedApprovePngIcon,
        ),
      );
    }
  }

  void openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  void checkBuilding(LatLng tapPoint, int id, bool isSurveyBuilding) async {
    if (id == null) {
      bool _isNeedSurveyFound = false;
      bool _isOnMapFound = false;
      bool flagNeedSurveyBuilding = false;
      bool flagBuildingOnMap = false;
      if (!_isNeedSurveyFound && initListNeedSurveyBuildingPolygons.length > 0 && _isShowSystemZone) {
        for (int i = 0; i < initListNeedSurveyBuildingPolygons.length && !flagNeedSurveyBuilding; i++) {
          if (geodesy.isGeoPointInPolygon(tapPoint, initListNeedSurveyBuildingPolygons[i].polygon.points)) {
            _isNeedSurveyFound = true;
            flagNeedSurveyBuilding = true;
            buildingPopupId = initListNeedSurveyBuildingPolygons[i].id;
          }
        }
      }

      if(!_isNeedSurveyFound && _buildingPolygonOnMap.length > 0 && _isShowBuilding) {
        for (int i = 0; i < _buildingPolygonOnMap.length && ! flagBuildingOnMap; i++) {
          if (geodesy.isGeoPointInPolygon(tapPoint, _buildingPolygonOnMap[i].polygon.points)) {
            _isOnMapFound = true;
            flagBuildingOnMap = true;
            buildingPopupId = _buildingPolygonOnMap[i].id;
          }
        }
      }

      if(_isNeedSurveyFound) {
        final rs = await showDialog(
          context: context,
          builder: (context) => BuildingNeedSurveyPopup(),      
        );
        if (rs != null) {
          if (rs) {
            _buildingBloc.add(LoadListNeedSurveyBuildingsMap());
            showToast(Config.updateNeedSurveyBuildingSuccessMessage, true);
          }
        }
      }

      if(_isOnMapFound) {
        await showDialog(
          context: context,
          builder: (context) => BuildingDetailsPopup(),      
        );
      }
      buildingPopupId = null;
    } else {
      if (isSurveyBuilding) {
        buildingPopupId = id;
        final rs = await showDialog(
          context: context,
          builder: (context) => BuildingNeedSurveyPopup(),      
        );
        if (rs != null) {
          if (rs[0]) {
            if (rs[1]) {
              _buildingBloc.add(LoadListNeedSurveyBuildingsMap());
              showToast(Config.updateNeedSurveyBuildingSuccessMessage, true);
            }
          } else {
            if (rs[1]) {
              _buildingBloc.add(LoadListNeedSurveyBuildingsMap());
              showToast(Config.deleteBuildingSuccessMessage, true);
            } else {
              showToast(Config.deleteBuildingFailMessage, false);
            } 
          }
        }
      } else {
        buildingPopupId = id;
        await showDialog(
          context: context,
          builder: (context) => BuildingDetailsPopup(),      
        );
      }
      buildingPopupId = null;
    }
  }

  void openStoreDetails(int id ,bool isNeedSurvey) async {
    storePopupId = id;
    if (isNeedSurvey) {
      final rs =await showDialog(
        context: context,
        builder: (context) => StoreNeedSurveyPopup(),      
      );
      if (rs != null) {
        if (rs[0]) {
          if (rs[1]) {
            _storeBloc.add(LoadListNeedSurveyStoresMap());
            showToast(Config.updateNeedSurveyStoreSuccessMessage, true);
          }
        } else {
          if (rs[1]) {
            _storeBloc.add(LoadListNeedSurveyStoresMap());
            showToast(Config.deleteStoreSuccessMessage, true);
          } else {
            showToast(Config.deleteStoreFailMessage, false);
          }
        }
      }
    } else {
      await showDialog(
        context: context,
        builder: (context) => StoreDetailsPopup(),      
      );
    }
    storePopupId = null;
  }

  // set the polygon from building polygon init on loading page
  void setNeedSurveyBuildingPolygon() {
    if(!_initNeedSurveyPolygonsAnhPoints) {
      setState(() {
        _needSurveyBuildingOnMapPolygons.clear();
        _needSurveyBuildingCenterPoints.clear();
        initListNeedSurveyBuildingPolygons.forEach((buildingPolygon) {
          _needSurveyBuildingOnMapPolygons.add(buildingPolygon.polygon);
          _needSurveyBuildingCenterPoints.add(
            Marker(
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.1,
              point: buildingPolygon.centerPoint,
              builder: (ctx) => Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.075,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.04,
                ),
                child: FlatButton(
                  onPressed: () {
                    checkBuilding(null, buildingPolygon.id, true);
                  },
                child: iconForNeedSurveyPolygon(buildingPolygon.status),
                ),
              ),
            )
          );
        });
        _initNeedSurveyPolygonsAnhPoints = true;
      });
    }
  }

  Future<void> loadBuildingOnMapPolygons(String dataInput) async {
    _buildingPolygonOnMap.clear();
    _buildingOnMapPolygons.clear();
    _buildingOnMapPoints.clear();
    int countNeedSurveyBuilding = 0;
    final geojson = GeoJson();
    geojson.processedFeatures.listen((GeoJsonFeature feature) {
      BuildingPolygon buildingPolygon = new BuildingPolygon();
      buildingPolygon.id = feature.properties['f4'] != null ? int.parse(feature.properties['f4'].toString()) : null;
      buildingPolygon.name = feature.properties['f2'] != null ? feature.properties['f2'].toString() : null;
      GeoJsonMultiPolygon multiPolygon = feature.geometry;
      GeoJsonPolygon geoPolygon = multiPolygon.polygons[0];
      String centerPointString = feature.properties['f5'] != null ? feature.properties['f5'].toString() : null;
      double centerPointLongitude = 0;
      double centerPointLatitude = 0;
      if (centerPointString != null) {
        centerPointString =  centerPointString.substring(centerPointString.indexOf(' '), centerPointString.length).toString();
        centerPointString = centerPointString.replaceAll('(', '').toString();
        centerPointString = centerPointString.replaceAll(')', '').toString();
        centerPointLongitude = double.parse(centerPointString.split(' ')[1]);
        centerPointLatitude = double.parse(centerPointString.split(' ')[2]);
      }
      final geoSerie = GeoSerie(
        type: GeoSerieType.polygon,
        name: geoPolygon.geoSeries[0].name,
        geoPoints: <GeoPoint>[]
      );
      for (final serie in geoPolygon.geoSeries) {
        geoSerie.geoPoints.addAll(serie.geoPoints);
      }
      final poly = Polygon(
        points: geoSerie.toLatLng(ignoreErrors: true),
        color: Colors.grey.withOpacity(0.2),
        borderColor: Colors.grey,
        borderStrokeWidth: 1,
      );
      buildingPolygon.polygon = poly;
      if (centerPointString != null) buildingPolygon.centerPoint = new LatLng(centerPointLatitude, centerPointLongitude);
      setState(() {
        bool flag = false;
        int i = countNeedSurveyBuilding;
        while(i < initListNeedSurveyBuildingPolygons.length && !flag) {
          if (initListNeedSurveyBuildingPolygons[i].id == buildingPolygon.id) {
            countNeedSurveyBuilding = i;
            flag = true;
          } else {
            i += 1;
          }
        }
        if (!flag) {
          _buildingPolygonOnMap.add(buildingPolygon);
          _buildingOnMapPolygons.add(poly);
          _buildingOnMapPoints.add(
            Marker(
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.1,
              point: buildingPolygon.centerPoint,
              builder: (ctx) => Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.075,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.04,
                ),
                child: FlatButton(
                  onPressed: () {
                    checkBuilding(null, buildingPolygon.id, false);
                  },
                  child: Container(
                    child: Image.asset(
                      Config.buildingDefaultPngIcon,
                    ),
                  ),
                ),
              ),
            )
          );
        } 
      });
    });
    geojson.endSignal.listen((bool _) => geojson.dispose());
    unawaited(geojson.parse(dataInput, verbose: true));
  }
  
  Future<void> loadStoreOnMapPoints(String dataInput) async {
    final geojson = GeoJson();
    int countNeedSurveyStore = 0;
    geojson.processedFeatures.listen((GeoJsonFeature feature) {
      int id = feature.properties['f4'] != null ? int.parse(feature.properties['f4'].toString()) : null;
      String name = feature.properties['f2'] != null ? feature.properties['f2'] : null;
      String type = feature.properties['f1'] != null ? feature.properties['f1'] : null;
      int status = feature.properties['f3'] != null ? int.parse(feature.properties['f3'].toString()) : null;
      GeoJsonPoint geoJsonPoint = feature.geometry;
      LatLng point = LatLng(geoJsonPoint.geoPoint.latitude, geoJsonPoint.geoPoint.longitude);
      setState(() {
        bool flag = false;
        int i = countNeedSurveyStore;
        while(i < initListStorePointsOnMap.length && !flag) {
          if (initListStorePointsOnMap[i].id == id) {
            countNeedSurveyStore = i;
            flag = true;
          } else {
            i += 1;
          }
        }
        if (!flag) {
          _listStorePointOnMap.add(
            new StorePoint(id: id, name: name, type: type, status: status, point: point)
          );
          _storeOnMapPoints.add(
            Marker(
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.1,
              point: point,
              builder: (ctx) => Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.075,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.04,
                ),
                child: FlatButton(
                  onPressed: () {
                    openStoreDetails(id, false);
                  },
                  child: Image.asset(
                    Config.storeDefaultPngIcon,
                  ),
                ),
              ),
            )
          );
        }
      });
    });
    geojson.endSignal.listen((bool _) => geojson.dispose());
    unawaited(geojson.parse(dataInput, verbose: true));
  }
  
  Future<void> setNeedSurveyStoreOnMapPoints() async {
    if (!_initNeedSurveyStorePoints) {
      setState(() {
        _needSurveyStoreOnMapPoints.clear();
        initListStorePointsOnMap.forEach((storePoint) {
          _needSurveyStoreOnMapPoints.add(
            Marker(
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.1,
              point: storePoint.point,
              builder: (ctx) => Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.075,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.04,
                ),
                child: FlatButton(
                  onPressed: () {
                    openStoreDetails(storePoint.id, true);
                  },
                  child: iconForStorePoint(storePoint.status),
                ),
              ),
            )
          );
        });
        _initNeedSurveyStorePoints = true;
      });
    }
  }

  Widget iconForStorePoint(int status) {
    if (status == 1) {
      return Container(
        child: Image.asset(
          Config.storeDefaultPngIcon,
        ),
      );
    } else if (status == 2) {
      return Container(
        child: Image.asset(
          Config.storeNeedSurveydPngIcon,
        ),
      );
    } else {
      return Container(
        child: Image.asset(
          Config.storeNeedApprovePngIcon
        ),
      );
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