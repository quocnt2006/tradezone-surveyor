import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geodesy/geodesy.dart';
import 'package:osm_map_surveyor/behaviorsubject/building_map_behavior.dart';
import 'package:osm_map_surveyor/bloc/building_bloc.dart';
import 'package:osm_map_surveyor/bloc/liststreetsegment_bloc.dart';
import 'package:osm_map_surveyor/events/building_event.dart';
import 'package:osm_map_surveyor/events/liststreetsegment_event.dart';
import 'package:osm_map_surveyor/models/campus.dart';
import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/repositories/building_repository.dart';
import 'package:osm_map_surveyor/repositories/liststreetsegment_repository.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/states/building_state.dart';
import 'package:osm_map_surveyor/states/liststreetsegment_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/geolocator_utils.dart';
import 'package:osm_map_surveyor/utilities/popup_utils.dart';
import 'package:osm_map_surveyor/utilities/progress_bar.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';
import 'package:user_location/user_location.dart';

class BuildingMap extends StatefulWidget {
  final List<LatLng> buildingPolygonPoints;
  final LatLng centerPoint;
  BuildingMap({Key key, this.buildingPolygonPoints, this.centerPoint}) : super(key: key);

  @override
  _BuildingMapState createState() => _BuildingMapState(this.buildingPolygonPoints, this.centerPoint);
}

class _BuildingMapState extends State<BuildingMap> {
  List<LatLng> buildingPolygonPoints;
  LatLng centerPoint;
  _BuildingMapState(this.buildingPolygonPoints, this.centerPoint);

  List<Marker> markers = [];
  MapController mapController = MapController();
  UserLocationOptions userLocationOptions;

  ListStreetSegmentBloc _listStreetSegmentBloc;
  TextEditingController _geomPointsController = TextEditingController();
  TextEditingController _checkPointsGeomController = TextEditingController();
  BuildingMapBehavior _buildingMapBehavior = BuildingMapBehavior();
  BuildingBloc _buildingBloc;
  String _buildingText = "Draw Building";
  String _geomBuilding = "";
  Polygon _buildingPolygon;
  bool _isDraw = false;
  bool _isCheckCampus = false;
  Campus _campus;
  ListStreetSegments _listStreetSegments;
  List<LatLng> _buildingPolygonPoints = <LatLng>[];
  List<Marker> _buildingPolygonMarkers = <Marker>[];
  ProgressBar _progressBar;

  @override
  void initState() {
    super.initState();
    _geomPointsController.addListener(() {
      _buildingMapBehavior.pointsGeomSink.add(_geomPointsController.text);
    });
    _checkPointsGeomController.addListener(() {
      _buildingMapBehavior.checkPointsGeomSink.add(_checkPointsGeomController.text);
    });
    _listStreetSegmentBloc = ListStreetSegmentBloc(listStreetSegmentRepository: ListStreetSegmentRepository());
    _buildingBloc = BuildingBloc(buildingRepository: BuildingRepository());
    _progressBar = ProgressBar();
    initBuildingPoints();
  }

  initBuildingPoints() {
    if (buildingPolygonPoints != null) {
      if (buildingPolygonPoints.length != 0) {
        _buildingPolygonPoints = buildingPolygonPoints.toList();
        drawPolygon();
        updateBuildingGeom();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _buildingMapBehavior.dispose();
    _listStreetSegmentBloc.close();
    _buildingBloc.close();
    _progressBar.hide();
  }

  @override
  Widget build(BuildContext context) {
    userLocationOptions = UserLocationOptions(
      updateMapLocationOnPositionChange: false,
      context: context,
      mapController: mapController,
      markers: markers,
    );
    return Scaffold(
      appBar: appBar(context),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: body(context),
      ),
    );
  }

  Widget appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Config.secondColor,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios, 
          color: Colors.white,
          size: MediaQuery.of(context).size.height * 0.025,
        ),
        onPressed: () => Navigator.pop(context, [_buildingPolygonPoints, _listStreetSegments, null, _campus]),
      ),
      title: Container(
        child: Text(
          'Building base',
          style: TextStyle(
            fontSize: Config.textSizeMedium,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
    initBuildingMarkers();
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.425,
            child: FlutterMap(
              options: MapOptions(
                center: centerPoint != null ? 
                  centerPoint.latitude == 0.0 && centerPoint.longitude == 0.0 ? 
                    LatLng(10.841576, 106.809069)
                    : centerPoint
                  : LatLng(10.841576, 106.809069),
                maxZoom: Config.zoomMax,
                minZoom: Config.zoomMin,
                zoom: Config.zoomInit,
                plugins: [UserLocationPlugin(),],
                onTap: (point) {
                  if (_isDraw) {
                    _buildingPolygonPoints.add(point);
                    if (_buildingPolygonPoints.length == 1) {
                      setState(() {
                        _geomPointsController.text = null;
                        _checkPointsGeomController.text = null;
                      });
                    }
                    addBuildingMarker(point, _buildingPolygonPoints.length - 1);
                    if (_buildingPolygonPoints.length == 2) {
                      setState(() {
                        _geomPointsController.text = null;
                        _checkPointsGeomController.text = null;
                      });
                    }
                    if (_buildingPolygonPoints.length > 2) {
                      updateBuildingGeom();
                    }
                    if (_buildingPolygonPoints != null) {
                      drawPolygon();
                    }
                  }
                },
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                PolygonLayerOptions(
                  polygons: initListCampusPolygons != null
                  ? initListCampusPolygons : [],
                ),
                PolygonLayerOptions(
                  polygons: initListNeedSurveySystemZoneForDrawPolygons != null
                  ? initListNeedSurveySystemZoneForDrawPolygons : [],
                ),
                MarkerLayerOptions(markers: markers),
                PolygonLayerOptions(polygons: _buildingPolygon != null ? [_buildingPolygon] : []),
                MarkerLayerOptions(markers: _buildingPolygonMarkers != null ? _buildingPolygonMarkers : []),
                userLocationOptions,
              ],
              mapController: mapController,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Container(
            height: MediaQuery.of(context).size.height * 0.44,
            child: ListView(
              children: <Widget>[
                Center(
                  child: _buildingPolygonPoints != null ? 
                    Text("Total points: " + _buildingPolygonPoints.length.toString())
                    : Text("Total points: 0"),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                if (_buildingPolygonPoints.length > 0)
                  for (var i = 0; i < _buildingPolygonPoints.length; i++)
                    pointWidget(context, _buildingPolygonPoints[i], i),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                pointInLocationWidget(context),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                editRow(context),
                buildingPolygonPoints != null ? 
                  buildingPolygonPoints.length > 0 ? 
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01)
                    : SizedBox()
                  : SizedBox(),
                buildingPolygonPoints != null ? 
                  buildingPolygonPoints.length > 0 ? 
                    resetPointsButton(context)
                    : SizedBox()
                  : SizedBox(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                checkButton(context),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                submitButton(context),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                blocListenerWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget editRow(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          drawingButton(context),
          clearButton(context),
        ],
      ),
    );
  }

  Widget checkButton(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      margin: EdgeInsets.only(
        right: MediaQuery.of(context).size.width * 0.1,
        left: MediaQuery.of(context).size.width * 0.1,
      ),
      child: StreamBuilder(
        stream: _buildingMapBehavior.pointsGeomStream,
        builder: (context, snapshot) {
          return RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02,),
              ),
              onPressed: snapshot.hasData ? 
                snapshot.data == true ? 
                  () {
                    setState(() {
                      _isCheckCampus = true;
                      _buildingBloc.add(LoadBuildingCampus(geomBuilding: _geomBuilding));
                    });
                  }
                  : null
                : null,
              child: _isCheckCampus == false ? Text(
                "Check building base",
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                  fontWeight: FontWeight.bold,
                  color: Config.thirdColor,
                ),
              ) : loadingWidget(context),
              color: Config.secondColor,
          );
        },
      ),
    );
  }

  Widget submitButton(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      margin:  EdgeInsets.only(
        right: MediaQuery.of(context).size.width * 0.1,
        left: MediaQuery.of(context).size.width * 0.1,
      ),
      child: StreamBuilder(
        stream: _buildingMapBehavior.submitStream,
        builder: (context, snapshot) {
          return RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02,),
              ),
              onPressed: snapshot.hasData ? 
                snapshot.data == true ? 
                  () {
                    showSendingProgressBar();
                    _buildingBloc.add(LoadBuildingCampus(geomBuilding: _geomBuilding));
                    _listStreetSegmentBloc.add(LoadListStreetSegment(points: _buildingPolygonPoints));
                  }
                  : null
                : null,
              child: Text(
                "Submit building base",
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                  fontWeight: FontWeight.bold,
                  color: Config.thirdColor,
                ),
              ),
              color: Config.secondColor,
          );
        },
      ),
    );
  }

  Widget resetPointsButton(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.02,
        right: MediaQuery.of(context).size.width * 0.14,
        left: MediaQuery.of(context).size.width * 0.14,
      ),
      child: RaisedButton(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Config.secondColor,),
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.01),
        ),
        onPressed: () {
          reset();
        },
        child: Text(
          "Reset points",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget clearButton(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.width * 0.3875,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.02,
        left: MediaQuery.of(context).size.width * 0.01,
      ),
      child: RaisedButton(
        color: Config.secondColor,
        disabledColor: Config.secondColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
        ),
        onPressed: _buildingPolygonPoints.length != 0 ? 
          () {
            clear();
          }
          : null,
        child: Text(
          "Clear all points",
          style: TextStyle(
            color: Colors.white,
            fontSize: Config.textSizeSmall * 0.85,
          ),
        ),
      ),
    );
  }

  Widget pointWidget(BuildContext context, LatLng point, int i) {
    return Tooltip(
      message: 'latitude:' + point.latitude.toString() + ' longtitude:' + point.longitude.toString(),
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.01,
          left: MediaQuery.of(context).size.width * 0.1,
          right: MediaQuery.of(context).size.width * 0.1,
        ),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.05,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              width: MediaQuery.of(context).size.width * 0.002,
              color: Config.secondColor),
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.035,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Config.redColor,
                    width: MediaQuery.of(context).size.width * 0.002,
                  ),
                ),
              ),
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.02,
              ),
              padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.02,
              ),
              child: SvgPicture.asset(
                Config.locationSvgIcon,
                height: MediaQuery.of(context).size.height * 0.0035,
              ),
            ),
            Expanded(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text('Point'),
                    Text((i + 1).toString()),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.035,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Config.redColor,
                    width: MediaQuery.of(context).size.width * 0.002,
                  ),
                ),
              ),
              margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.02,
              ),
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.02,
              ),
              child: IconButton(
                icon: SvgPicture.asset(Config.cancelSvgIcon,),
                onPressed: () {
                  removePoint(i);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget drawingButton(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.width * 0.3875,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.02,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: RaisedButton(
        color: _isDraw ? Colors.redAccent : Config.secondColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
        ),
        onPressed: () {
          if (!_isDraw) {
            setState(() {
              _buildingText = "Cancel drawing";
              _isDraw = true;
            });
          } else {
            setState(() {
              _isDraw = false;
              _buildingText = "Draw building";
            });
          }
        },
        child: Text(
          _buildingText,
          style: TextStyle(
            color: _isDraw ? Colors.white : Colors.white,
            fontSize: Config.textSizeSmall * 0.85,
          ),
        ),
      ),
    );
  }

  Widget pointInLocationWidget(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.02,
        right: MediaQuery.of(context).size.width * 0.1,
        left: MediaQuery.of(context).size.width * 0.1,
      ),
      child: RaisedButton(
        color: Config.secondColor,
        disabledColor: Config.secondColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
        ),
        onPressed: _isDraw ?
          () async {
            LatLng point = await getCurrentLocation();
            _buildingPolygonPoints.add(point);
            if (_buildingPolygonPoints.length == 1) {
              setState(() {
                _geomPointsController.text = null;
                _checkPointsGeomController.text = null;
              });
            }
            if (_buildingPolygonPoints.length == 2) {
              setState(() {
                _geomPointsController.text = null;
                _checkPointsGeomController.text = null;
              });
            }
            if (_buildingPolygonPoints.length > 2) {
              updateBuildingGeom();
            }
            if (_buildingPolygonPoints != null) {
              drawPolygon();
            }
          } : null,
        child: Text(
          "Get point by your current location",
          style: TextStyle(
            color: Colors.white,
            fontSize: Config.textSizeSmall * 0.85,
          ),
        ),
      ),
    );
  }

  Widget blocListenerWidget() {
    return MultiBlocListener(
      listeners: [
        BlocListener(
          bloc: _listStreetSegmentBloc,
          listener: (BuildContext context, ListStreetSegmentState state) async {
              if (state is LoadListStreetSegmentDataFinishState) {
              _listStreetSegments = state.listStreetSegments;
              dynamic address = await _getAddressCenter(getCenterPolygon(_buildingPolygon.points));
              hideSendingProgressBar();
              Navigator.pop(
                context, 
                [
                  _buildingPolygonPoints,
                  _listStreetSegments,
                  address,
                  _campus
                ]
              );
            }
          },
          child: SizedBox(),
        ),
        BlocListener(
          bloc: _buildingBloc,
          listener: (BuildContext context, BuildingState state) async {
            if (state is LoadBuildingCampusFinishState) {
              if (state.campus != null) {
                setState(() {
                  _isCheckCampus = false;
                });
                if (state.campus.id == -2) {
                  PopupUtils.utilShowLoginDialog(Config.invalidBuilding, Config.invalidBuildingBody, context);
                  clear();
                } else {
                  setState(() {
                    _campus = state.campus;
                    _checkPointsGeomController.text = 'true';
                  });
                }
              } else {
                setState(() {
                  _isCheckCampus = false;
                });
                PopupUtils.utilShowLoginDialog(Config.checkCampusFail, Config.checkCampusFailBody, context);
              }
            }
          },
          child: SizedBox(),
        ),
      ], 
      child: SizedBox(),
    );
  }

  void drawPolygon() {
    setState(() {
      _buildingPolygon = Polygon(
        points: _buildingPolygonPoints,
        color: Colors.blue.withOpacity(0.2),
        borderColor: Colors.blue,
        borderStrokeWidth: 1,
      );
    });
  }

  void removePoint(int i) {
    setState(() {
      _buildingPolygonPoints.removeAt(i);
      if (_buildingPolygonPoints.length <= 2) {
        _geomBuilding = "";
        _geomPointsController.text = "";
        _checkPointsGeomController.text = "";
      } else {
        updateBuildingGeom();
      }
      if (_buildingPolygonPoints.length == 0) {
        clear();
      }
    });
  }

  void initBuildingMarkers() {
    _buildingPolygonMarkers.clear();
    for (var i = 0; i < _buildingPolygonPoints.length; i++) {
      addBuildingMarker(_buildingPolygonPoints[i], i);
    }
  }

  void addBuildingMarker(LatLng point, int i) {
    _buildingPolygonMarkers.add(
      Marker(
        width: MediaQuery.of(context).size.width * 0.15,
        height: MediaQuery.of(context).size.height * 0.085,
        point: point,
        builder: (ctx) => FlatButton(
          onPressed: () {},
          child: Container(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height * 0.1,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.03,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  (i + 1).toString(),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                SvgPicture.asset(
                  Config.locationSvgIcon,
                  height: MediaQuery.of(context).size.height * 0.021,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void clear() {
    setState(() {
      _isDraw = false;
      _buildingText = "Draw building";
      _buildingPolygonMarkers.clear();
      _buildingPolygonPoints.clear();
      _buildingPolygon = null;
      _geomBuilding = "";
      _geomPointsController.text = "";
      _checkPointsGeomController.text = "";
    });
  }

  void reset() {
    setState(() {
      _buildingPolygonPoints = buildingPolygonPoints.toList();
      updateBuildingGeom();
      drawPolygon();
    });
  }

  void updateBuildingGeom() {
    String polyCoordinate = '';

    for (final point in _buildingPolygonPoints) {
      if (point == _buildingPolygonPoints.last) {
        polyCoordinate = polyCoordinate +
            point.longitude.toString() +
            " " +
            point.latitude.toString() +
            "," +
            _buildingPolygonPoints.first.longitude.toString() +
            " " +
            _buildingPolygonPoints.first.latitude.toString();
      } else {
        polyCoordinate = polyCoordinate +
            point.longitude.toString() +
            " " +
            point.latitude.toString() +
            ",";
      }
    }
    _geomBuilding = polyCoordinate;
    _geomPointsController.text = _geomBuilding;
  }

  void showSendingProgressBar() {
    _progressBar.show(context);
  }

  void hideSendingProgressBar() {
    _progressBar.hide();
  }

  _getAddressCenter(LatLng point) async {
    return await getAddressFromLatLng(point);
  }
}
