import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geodesy/geodesy.dart';
import 'package:osm_map_surveyor/bloc/liststreetsegment_bloc.dart';
import 'package:osm_map_surveyor/bloc/store_bloc.dart';
import 'package:osm_map_surveyor/events/liststreetsegment_event.dart';
import 'package:osm_map_surveyor/events/store_event.dart';
import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/repositories/liststreetsegment_repository.dart';
import 'package:osm_map_surveyor/repositories/store_repository.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/states/liststreetsegment_state.dart';
import 'package:osm_map_surveyor/states/store_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/geolocator_utils.dart';
import 'package:osm_map_surveyor/utilities/popup_utils.dart';
import 'package:osm_map_surveyor/utilities/progress_bar.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';
import 'package:user_location/user_location.dart';
import 'package:osm_map_surveyor/behaviorsubject/store_map_behavior.dart';

class StoreMap extends StatefulWidget {
  final LatLng initPoint;
  final LatLng centerPoint;
  StoreMap({Key key, this.initPoint, this.centerPoint}) : super(key: key);

  @override
  _StoreMapState createState() => _StoreMapState(this.initPoint, this.centerPoint);
}

class _StoreMapState extends State<StoreMap> {
  LatLng initPoint;
  LatLng centerPoint;
  _StoreMapState(this.initPoint, this.centerPoint);

  List<Marker> markers = [];
  MapController mapController = MapController();
  UserLocationOptions userLocationOptions;

  Marker _storeMarker;
  LatLng _storePoint;
  StoreMapBehavior _storeMapBehavior = StoreMapBehavior();
  TextEditingController _geomPointController = TextEditingController();
  TextEditingController _checkGeomPointController = TextEditingController();
  ProgressBar _progressBar;
  ListStreetSegmentBloc _listStreetSegmentBloc;
  StoreBloc _storeBloc;
  ListStreetSegments _listStreetSegments;
  bool _isCheckStore = false;

  @override
  void initState() {
    super.initState();
    _geomPointController.addListener(() {
      _storeMapBehavior.pointGeomSink.add(_geomPointController.text);
    });
    _checkGeomPointController.addListener(() {
      _storeMapBehavior.checkPointsGeomSink.add(_checkGeomPointController.text);
    });
    _listStreetSegmentBloc = ListStreetSegmentBloc(listStreetSegmentRepository: ListStreetSegmentRepository());
    _storeBloc = StoreBloc(storeRepository: StoreRepository());
    _progressBar = ProgressBar();
    initStorePoint();
  }

  void initStorePoint() {
    setState(() {
      if (initPoint != null) {
        _storePoint = new LatLng(initPoint.latitude, initPoint.longitude);
        _geomPointController.text = _storePoint.toString();
        _storeMapBehavior.pointGeomSink.add(_geomPointController.text);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _storeMapBehavior.dispose();
    _listStreetSegmentBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    userLocationOptions = UserLocationOptions(
      updateMapLocationOnPositionChange: false,
      context: context,
      mapController: mapController,
      markers: markers,
    );
    if (_storePoint != null) {
      setStoreMarker(_storePoint);
    }
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
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Container(
        child: Text(
          'Store point',
          style: TextStyle(
            fontSize: Config.textSizeMedium,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.425,
            child: FlutterMap(
              options: MapOptions(
                center: _storePoint != null
                  ? _storePoint.latitude == 0.0 && _storePoint.longitude == 0.0
                    ? centerPoint
                    : _storePoint
                  : centerPoint,
                maxZoom: Config.zoomMax,
                minZoom: Config.zoomMin,
                zoom: Config.zoomInit,
                plugins: [UserLocationPlugin(),],
                onTap: (point) {
                  setState(() {
                    _checkGeomPointController.text = "";
                    _storePoint = point;
                    setStoreMarker(point);
                    if (_storePoint != null) {
                      _geomPointController.text = point.toString();
                      _checkGeomPointController.text = "";
                    } else {
                      _geomPointController.text = null;
                      _checkGeomPointController.text = "";
                    }
                  });
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
                MarkerLayerOptions(markers: _storeMarker != null ? [_storeMarker] : []),
                userLocationOptions,
              ],
              mapController: mapController,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          Container(
              height: MediaQuery.of(context).size.height * 0.44,
              color: Colors.white,
              child: ListView(
                children: <Widget>[
                  multiBlocListenerWidget(),
                  clearPointButton(context),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                  initPoint != null ? resetPointButton(context) : SizedBox(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  checkButton(context),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  submitButton(context),
                ],
              )),
        ],
      ),
    );
  }

  Widget multiBlocListenerWidget() {
    return MultiBlocListener(
      listeners: [
        storeBlocLisnter(),
        listStreetSegmentBlocListenerWidget()
      ],
      child: SizedBox(),
    );
  }

  Widget listStreetSegmentBlocListenerWidget() {
    return BlocListener(
      bloc: _listStreetSegmentBloc,
      listener: (BuildContext context, ListStreetSegmentState state) async {
        if (state is LoadListStreetSegmentByPointDataFinishState) {
          _listStreetSegments = new ListStreetSegments(listStreetSegment: state.listStreetSegments.listStreetSegment.toList());
          dynamic address = await _getAddressCenter(_storePoint);
          hideSendingProgressBar();
          Navigator.pop(context, [_storePoint, _listStreetSegments, address]);
        }
      },
      child: SizedBox(),
    );
  }

  Widget storeBlocLisnter() {
    return BlocListener(
      bloc: _storeBloc,
      listener: (BuildContext context,StoreState state) {
        if (state is LoadCheckStoreLocationFinishState) {
          if (state.rs != null) {
            if(state.rs) {
              setState(() {
                _isCheckStore =  false;
                _checkGeomPointController.text = 'true';
              });
            } else {
              setState(() {
                _isCheckStore =  false;
              });
              PopupUtils.utilShowLoginDialog(Config.invalidStore, Config.invalidStoreBody, context);
              clear();
            }
          } else {
            setState(() {
              _isCheckStore =  false;
            });
            PopupUtils.utilShowLoginDialog(Config.checkStoreFail, Config.checkStoreFail, context);
          }       
        }
      },
      child: SizedBox(),
    );
  }

  Widget clearPointButton(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      margin: EdgeInsets.only(
        right: MediaQuery.of(context).size.width * 0.1,
        left: MediaQuery.of(context).size.width * 0.1,
      ),
      child: RaisedButton(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Config.secondColor,
          ),
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
        ),
        onPressed: () {
          clear();
        },
        child: Text(
          "Clear point",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget resetPointButton(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      margin: EdgeInsets.only(
        right: MediaQuery.of(context).size.width * 0.1,
        left: MediaQuery.of(context).size.width * 0.1,
      ),
      child: RaisedButton(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Config.secondColor,
          ),
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
        ),
        onPressed: () {
          reset();
        },
        child: Text(
          "Reset store point",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
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
        stream: _storeMapBehavior.pointGeomStream,
        builder: (context, snapshot) {
          return RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02,),
              ),
              onPressed: snapshot.hasData ? 
                snapshot.data == true ? 
                  () {
                    setState(() {
                      _isCheckStore = true;
                      _storeBloc.add(LoadCheckStoreLocation(point: _storePoint));
                    });
                  }
                  : null
                : null,
              child: _isCheckStore == false ? Text(
                "Check store location",
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                  fontWeight: FontWeight.bold,
                  color: Config.thirdColor,
                ),
              ) : loadingWidget(context),
              color: Config.secondColor,
              disabledColor: Config.secondColor.withOpacity(0.5),
          );
        },
      ),
    );
  }

  Widget submitButton(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      margin: EdgeInsets.only(
        right: MediaQuery.of(context).size.width * 0.1,
        left: MediaQuery.of(context).size.width * 0.1,
      ),
      child: StreamBuilder(
        stream: _storeMapBehavior.submitStream,
        builder: (context, snapshot) {
          return RaisedButton(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width * 0.02,
                ),
              ),
              onPressed: snapshot.hasData
                ? snapshot.data == true
                  ? () {
                    showSendingProgressBar();
                    _listStreetSegmentBloc.add(LoadListStreetSegmentByPoint(point: _storePoint));
                  }
                  : null
                : null,
              child: Text(
                "Submit store",
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                  fontWeight: FontWeight.bold,
                  color: Config.thirdColor,
                ),
              ),
              color: Config.secondColor,
              disabledColor: Config.secondColor.withOpacity(0.5),
          );
        },
      ),
    );
  }

  void reset() {
    setState(() {
      if (initPoint != null) {
        _geomPointController.text = "true";
        _checkGeomPointController.text = "";
        _storePoint = new LatLng(initPoint.latitude, initPoint.longitude);
        setStoreMarker(_storePoint);
      }
    });
  }

  void setStoreMarker(LatLng point) {
    _storeMarker = Marker(
      width: MediaQuery.of(context).size.width * 0.15,
      height: MediaQuery.of(context).size.height * 0.08,
      point: point,
      builder: (ctx) => Container(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.height * 0.1,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.04,
        ),
        child: Column(
          children: <Widget>[
            SvgPicture.asset(
              Config.locationSvgIcon,
              height: MediaQuery.of(context).size.height * 0.021,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  void clear() {
    setState(() {
      _storePoint = null;
      _storeMarker = null;
      _geomPointController.text = "";
      _checkGeomPointController.text = "";
    });
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
