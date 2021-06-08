// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:geodesy/geodesy.dart';
// import 'package:latlong/latlong.dart';
// import 'package:map_controller/map_controller.dart';
// import 'package:osm_map_surveyor/bloc/building_bloc.dart';
// import 'package:osm_map_surveyor/bloc/store_bloc.dart';
// import 'package:osm_map_surveyor/events/building_event.dart';
// import 'package:osm_map_surveyor/events/store_event.dart';
// import 'package:osm_map_surveyor/repositories/building_repository.dart';
// import 'package:osm_map_surveyor/repositories/store_repository.dart';
// import 'package:osm_map_surveyor/utilities/config_base.dart';
// import 'package:osm_map_surveyor/utilities/get_points.dart';
// import 'dart:convert';
// import 'package:osm_map_surveyor/utilities/get_polygons.dart';

// class MapHomePage extends StatefulWidget {
//   MapHomePage({Key key}) : super(key: key);

//   @override
//   _MapHomePageState createState() => _MapHomePageState();
// }

// class _MapHomePageState extends State<MapHomePage> {
//   MapController mapController;
//   StatefulMapController statefulMapController;
//   StreamSubscription<StatefulMapControllerStateChange> sub;
//   bool _isAdd = false;
//   bool _isMoveMap = false;
//   bool _isSetBuildings = false;
//   bool _isSetStores = false;
//   bool _isAddStoreMarkers = false;
//   Polygon _addPolygon;
//   Polyline _addPolyline;
//   List<LatLng> _addPolygonPoints = [];
//   List<Marker> _addPolygonMarkers = [];
//   List<LatLng> _addPolylinePoints = [];
//   List<Marker> _addPolylineMarkers = [];
//   String _addBuildingStr = "Add Building";
//   String _addCampusStr = "Add Campus";
//   String _addStreetSegmentStr = "Add Street Segment";
//   String _addGroupStr = "Add Group";
//   String _addValue = "";
//   BuildingBloc _buildingBloc;
//   StoreBloc _storeBloc;
//   List<Polygon> _buildingPolygons = <Polygon>[];
//   LatLngBounds _bounds;
//   List<LatLng> _storePoints = <LatLng>[];
//   List<Marker> _storeMarkers = <Marker>[];
//   Timer timerGetWidget;
//   int timerCount = 0;
//   int isSetCount = 0;
//   int isSetStoreCount = 0;
//   Map<String, dynamic> _jsonPoint;
//   bool _isCafeFilter = false;
//   bool _isRestaurantFilter = false;
//   Geodesy geodesy = Geodesy();

//   static List<LatLng> polygonDrawPoints = <LatLng>[
//     LatLng(10.843728, 106.808660),
//     LatLng(10.842294, 106.810603),
//     LatLng(10.840039, 106.808842),
//     LatLng(10.841220, 106.807715),
//   ];
//   var polygonDraw = Polygon(
//       points: polygonDrawPoints,
//       color: Colors.blue.withOpacity(0.2),
//       borderColor: Colors.blue,
//       borderStrokeWidth: 1);
//   LatLng centerOfPolygon;

//   void getCenterPolygon() {
//     double minLat = 0;
//     double minLng = 0;
//     double maxLat = 0;
//     double maxLng = 0;
//     for (final point in polygonDraw.points) {
//       if (minLat == 0) {
//         minLat = point.latitude;
//       }
//       if (minLng == 0) {
//         minLng = point.longitude;
//       }
//       if (maxLat == 0) {
//         maxLat = point.latitude;
//       }
//       if (maxLng == 0) {
//         maxLng = point.longitude;
//       }

//       if (minLat > point.latitude) {
//         minLat = point.latitude;
//       }
//       if (minLng > point.longitude) {
//         minLng = point.longitude;
//       }
//       if (maxLat < point.latitude) {
//         maxLat = point.latitude;
//       }
//       if (maxLng < point.longitude) {
//         maxLng = point.longitude;
//       }
//     }
//     double centerLat = minLat + ((maxLat - minLat) / 2);
//     double centerLng = minLng + ((maxLng - minLng) / 2);
//     centerOfPolygon = LatLng(centerLat, centerLng);
//   }

//   @override
//   void initState() {
//     // intialize the controllers

//     _buildingBloc = BuildingBloc(buildingRepository: BuildingRepository());
//     _storeBloc = StoreBloc(storeRepository: StoreRepository());
//     mapController = MapController();
//     setUpTimeFetch();
//     statefulMapController = StatefulMapController(mapController: mapController);
//     statefulMapController.addStatefulMarker(
//         name: "some marker",
//         statefulMarker: StatefulMarker(
//             height: 80.0,
//             width: 120.0,
//             state: <String, dynamic>{"showText": false},
//             point: LatLng(10.841525, 106.810857),
//             builder: (BuildContext context, Map<String, dynamic> state) {
//               Widget w;
//               final markerIcon = IconButton(
//                   icon: const Icon(Icons.location_on),
//                   onPressed: () => statefulMapController.mutateMarker(
//                       name: "some marker",
//                       property: "showText",
//                       value: !(state["showText"] as bool)));
//               if (state["showText"] == true) {
//                 w = Column(children: <Widget>[
//                   markerIcon,
//                   Container(
//                       color: Colors.white,
//                       child: Padding(
//                           padding: const EdgeInsets.all(5.0),
//                           child: Text("asijdasdiajsdi", textScaleFactor: 1.3))),
//                 ]);
//               } else {
//                 w = markerIcon;
//               }
//               return w;
//             }));
//     _buildingBloc.add(LoadBuildingByFourBounds(
//         northWest: Config.initNorthWest,
//         northEast: Config.initNorthEast,
//         southEast: Config.initSouthEast,
//         southWest: Config.initSouthWest));
//     _storeBloc.add(LoadStoresByFourBounds(
//         northWest: Config.initNorthWest,
//         northEast: Config.initNorthEast,
//         southEast: Config.initSouthEast,
//         southWest: Config.initSouthWest));
//     sub = statefulMapController.changeFeed.listen((change) => setState(() {}));
//     getCenterPolygon();
//     print(centerOfPolygon);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return getMap(context);
//   }

//   @override
//   void dispose() {
//     sub.cancel();
//     timerGetWidget.cancel();
//     super.dispose();
//   }

//   // WIDGET
//   // the widget show the map
//   Widget getMap(BuildContext context) {
//     return Scaffold(
//       body: Stack(children: <Widget>[
//         Listener(
//           onPointerUp: (event) {
//             if (_isMoveMap) {
//               _isAddStoreMarkers = false;
//               timerCount = 0;
//               setUpTimeFetch();
//               _isSetStores = false;
//               _isSetBuildings = false;
//               isSetCount = 0;
//               isSetStoreCount = 0;
//               LatLngBounds boundsTmp =
//                   statefulMapController.mapController.bounds;
//               _bounds = boundsTmp;
//               _buildingPolygons.clear();
//               _buildingBloc.add(LoadBuildingByFourBounds(
//                   northWest: _bounds.northWest,
//                   northEast: _bounds.northEast,
//                   southEast: _bounds.southEast,
//                   southWest: _bounds.southWest));
//               _storePoints.clear();
//               _storeMarkers.clear();
//               _storeBloc.add(LoadStoresByFourBounds(
//                   northWest: _bounds.northWest,
//                   northEast: _bounds.northEast,
//                   southEast: _bounds.southEast,
//                   southWest: _bounds.southWest));
//               _isMoveMap = false;
//             }
//           },
//           child: FlutterMap(
//             mapController: mapController,
//             options: MapOptions(
//                 minZoom: Config.zoomMin,
//                 maxZoom: Config.zoomMax,
//                 onPositionChanged: (position, hasGesture) {
//                   _isMoveMap = true;
//                 },
//                 onTap: (point) {
//                   if (_isAdd) {
//                     if (_addValue == 'Street Segment') {
//                       addMarkerPolyline(context, point);
//                       if (_addPolyline == null) {
//                         drawPolyline();
//                       }
//                     } else {
//                       addMarkerPolygon(context, point);
//                       if (_addPolygon == null) {
//                         drawPolygon();
//                       }
//                     }
//                   }

//                   print(geodesy.isGeoPointInPolygon(point, polygonDraw.points));
//                 },
//                 center: LatLng(10.841576, 106.809069),
//                 zoom: Config.zoomInit),
//             layers: [
//               TileLayerOptions(
//                   urlTemplate:
//                       "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                   subdomains: ['a', 'b', 'c']),
//               MarkerLayerOptions(markers: _addPolylineMarkers),
//               MarkerLayerOptions(markers: _addPolygonMarkers),
//               MarkerLayerOptions(markers: statefulMapController.markers),
//               MarkerLayerOptions(markers: _storeMarkers),
//               PolylineLayerOptions(polylines: statefulMapController.lines),
//               PolygonLayerOptions(polygons: statefulMapController.polygons),
//               PolygonLayerOptions(polygons: [polygonDraw]),
//               PolygonLayerOptions(
//                   polygons: _addPolygon != null ? [_addPolygon] : []),
//               PolygonLayerOptions(polygons: _buildingPolygons),
//               PolylineLayerOptions(
//                   polylines: _addPolyline != null ? [_addPolyline] : []),
//             ],
//           ),
//         ),
//         checkBoxCafe(context),
//         checkBoxRestaurant(context),
//         if (_isAdd) addButton(context),
//         if (_isAdd) cancelButton(context),
//         StreamBuilder(
//           stream: _buildingBloc.buildingFourboundsStream,
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               if (!(_buildingPolygons.length > 0)) {
//                 _isSetBuildings = false;
//               }
//               if (!_isSetBuildings && isSetCount == 0) {
//                 _buildingPolygons = getPolygons(snapshot.data);
//                 isSetCount += 1;
//                 if (_buildingPolygons.length > 0) {
//                   _isSetBuildings = true;
//                 }
//               }
//             } else if (snapshot.hasError) {
//               print(snapshot.error.toString());
//             }
//             return SizedBox();
//           },
//         ),
//         StreamBuilder(
//           stream: _storeBloc.storeFourboundsStream,
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               if (!(_storeMarkers.length > 0)) {
//                 _isSetStores = false;
//               }
//               if (!_isSetStores && isSetStoreCount == 0) {
//                 _storePoints =
//                     getPoints(snapshot.data, context, statefulMapController);
//                 _jsonPoint = jsonDecode(snapshot.data);
//                 isSetStoreCount += 1;
//                 if (_storeMarkers.length > 0) {
//                   _isSetStores = true;
//                 }
//               }
//             } else if (snapshot.hasError) {
//               print(snapshot.error.toString());
//             }
//             return SizedBox();
//           },
//         ),
//         timerContainer(),
//       ]),
//     );
//   }

//   // the widget is show checkbox filter cafe
//   Widget checkBoxCafe(BuildContext context) {
//     return Positioned(
//       top: MediaQuery.of(context).size.height * 0.1,
//       left: MediaQuery.of(context).size.width * 0.01,
//       child: FlatButton(
//         onPressed: () {},
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.3,
//           height: MediaQuery.of(context).size.height * 0.05,
//           child: CheckboxListTile(
//             controlAffinity: ListTileControlAffinity.leading,
//             title: new Text(
//               'Cafe',
//               style: TextStyle(fontFamily: Config.textFamily),
//             ),
//             value: _isCafeFilter,
//             onChanged: (value) {
//               onCafeFilterChange(value);
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   // the widget is show checkbox filter cafe
//   Widget checkBoxRestaurant(BuildContext context) {
//     return Positioned(
//       top: MediaQuery.of(context).size.height * 0.15,
//       left: MediaQuery.of(context).size.width * 0.01,
//       child: FlatButton(
//         onPressed: () {},
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.5,
//           height: MediaQuery.of(context).size.height * 0.05,
//           child: CheckboxListTile(
//             controlAffinity: ListTileControlAffinity.leading,
//             title: new Text(
//               'Restaurant',
//               style: TextStyle(fontFamily: Config.textFamily),
//             ),
//             value: _isRestaurantFilter,
//             onChanged: (value) {
//               onRestaurantFilterChange(value);
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   // the widget is timer
//   Widget timerContainer() {
//     if (timerCount > 0) {
//       return Container();
//     } else {
//       return Container();
//     }
//   }

//   // the widget show add button.
//   Widget addButton(BuildContext context) {
//     return Positioned(
//       bottom: MediaQuery.of(context).size.height * 0.015,
//       left: MediaQuery.of(context).size.height * 0.02,
//       child: FlatButton(
//         onPressed: () {},
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.25,
//           height: MediaQuery.of(context).size.height * 0.05,
//           decoration: BoxDecoration(
//             color: Config.primaryColor,
//             borderRadius: BorderRadius.circular(
//                 MediaQuery.of(context).size.height * 0.01),
//             boxShadow: [
//               BoxShadow(
//                 blurRadius: MediaQuery.of(context).size.height * 0.008,
//                 color: Colors.black.withOpacity(0.1),
//                 spreadRadius: MediaQuery.of(context).size.height * 0.003,
//               )
//             ],
//           ),
//           child: Center(
//             child: Text(
//               "Add",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // the widget show cancel button
//   Widget cancelButton(BuildContext context) {
//     return Positioned(
//       bottom: MediaQuery.of(context).size.height * 0.015,
//       left: MediaQuery.of(context).size.height * 0.15,
//       child: FlatButton(
//         onPressed: () {
//           cancel();
//         },
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.25,
//           height: MediaQuery.of(context).size.height * 0.05,
//           decoration: BoxDecoration(
//             color: Config.primaryColor,
//             borderRadius: BorderRadius.circular(
//                 MediaQuery.of(context).size.height * 0.01),
//             boxShadow: [
//               BoxShadow(
//                 blurRadius: MediaQuery.of(context).size.height * 0.008,
//                 color: Colors.black.withOpacity(0.1),
//                 spreadRadius: MediaQuery.of(context).size.height * 0.003,
//               )
//             ],
//           ),
//           child: Center(
//             child: Text(
//               "Cancel",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // this widget show the multiple  select fap
//   Widget menuFAP(BuildContext context) {
//     return Positioned(
//         bottom: MediaQuery.of(context).size.height * 0.01,
//         right: MediaQuery.of(context).size.height * 0.01,
//         child: Container(
//           height: MediaQuery.of(context).size.height * 0.4,
//           width: MediaQuery.of(context).size.width * 0.5,
//           child: SpeedDial(
//             curve: Curves.bounceIn,
//             overlayColor: Config.primaryColor,
//             overlayOpacity: 0.05,
//             animatedIcon: AnimatedIcons.menu_close,
//             children: [
//               SpeedDialChild(
//                 child: Icon(Icons.add),
//                 label: _addGroupStr,
//                 labelBackgroundColor: Config.primaryColor,
//                 labelStyle: TextStyle(
//                     fontSize: MediaQuery.of(context).size.height * 0.02,
//                     color: Colors.white,
//                     fontFamily: Config.textFamily),
//                 onTap: () {
//                   if (!_isAdd) {
//                     _addValue = 'Group';
//                     activeAdd(_addValue);
//                   }
//                 },
//               ),
//               SpeedDialChild(
//                 child: Icon(Icons.add),
//                 label: _addBuildingStr,
//                 labelBackgroundColor: Config.primaryColor,
//                 labelStyle: TextStyle(
//                     fontSize: MediaQuery.of(context).size.height * 0.02,
//                     color: Colors.white,
//                     fontFamily: Config.textFamily),
//                 onTap: () {
//                   if (!_isAdd) {
//                     _addValue = 'Building';
//                     activeAdd(_addValue);
//                   }
//                 },
//               ),
//               SpeedDialChild(
//                 child: Icon(Icons.add),
//                 label: _addCampusStr,
//                 labelBackgroundColor: Config.primaryColor,
//                 labelStyle: TextStyle(
//                     fontSize: MediaQuery.of(context).size.height * 0.02,
//                     color: Colors.white,
//                     fontFamily: Config.textFamily),
//                 onTap: () {
//                   if (!_isAdd) {
//                     _addValue = 'Campus';
//                     activeAdd(_addValue);
//                   }
//                 },
//               ),
//               SpeedDialChild(
//                 child: Icon(Icons.add),
//                 label: _addStreetSegmentStr,
//                 labelBackgroundColor: Config.primaryColor,
//                 labelStyle: TextStyle(
//                     fontSize: MediaQuery.of(context).size.height * 0.02,
//                     color: Colors.white,
//                     fontFamily: Config.textFamily),
//                 onTap: () {
//                   if (!_isAdd) {
//                     _addValue = 'Street Segment';
//                     activeAdd(_addValue);
//                   }
//                 },
//               ),
//             ],
//           ),
//         ));
//   }

//   //FUNCTION
//   //this function is setting add new object
//   activeAdd(String addValue) {
//     setState(() {
//       _isAdd = true;
//       if (addValue == 'Group') {
//         _addGroupStr = "Adding Group...";
//       } else if (addValue == 'Building') {
//         _addBuildingStr = "Adding Building...";
//       } else if (addValue == 'Campus') {
//         _addCampusStr = "Adding Campus...";
//       } else if (addValue == 'Street Segment') {
//         _addStreetSegmentStr = "Adding Street Segment...";
//       }
//     });
//   }

//   //this function is draw Polygon
//   drawPolygon() {
//     setState(() {
//       _addPolygon = Polygon(
//         points: _addPolygonPoints,
//         color: Colors.blue.withOpacity(0.2),
//         borderColor: Colors.blue,
//         borderStrokeWidth: 1,
//       );
//     });
//   }

//   // this function to show all market which in one of a point polygons
//   addMarkerPolygon(BuildContext context, LatLng tappedPoint) {
//     setState(() {
//       _addPolygonPoints.add(tappedPoint);
//       _addPolygonMarkers.add(Marker(
//           width: MediaQuery.of(context).size.width * 0.1,
//           height: MediaQuery.of(context).size.height * 0.1,
//           point: tappedPoint,
//           builder: (context) => Container(
//                 child: Icon(Icons.location_on),
//               )));
//     });
//   }

//   //this function is draw Polygon
//   drawPolyline() {
//     setState(() {
//       _addPolyline = Polyline(
//         points: _addPolylinePoints,
//         color: Colors.red,
//         borderColor: Colors.red,
//         borderStrokeWidth: 1,
//       );
//     });
//   }

//   // this function to show all market which in one of a point polygons
//   addMarkerPolyline(BuildContext context, LatLng tappedPoint) {
//     setState(() {
//       _addPolylinePoints.add(tappedPoint);
//       _addPolylineMarkers.add(Marker(
//           width: MediaQuery.of(context).size.width * 0.1,
//           height: MediaQuery.of(context).size.height * 0.1,
//           point: tappedPoint,
//           builder: (context) => Container(
//                 child: Icon(Icons.location_on),
//               )));
//     });
//   }

//   // this function add market in point u tap on map
//   addMarker(BuildContext context, LatLng tappedPoint) {
//     setState(() {
//       statefulMapController.addStatefulMarker(
//           name: "some marker",
//           statefulMarker: StatefulMarker(
//               height: MediaQuery.of(context).size.height * 0.1,
//               width: MediaQuery.of(context).size.width * 0.1,
//               state: <String, dynamic>{"showText": false},
//               point: tappedPoint,
//               builder: (BuildContext context, Map<String, dynamic> state) {
//                 Widget w;
//                 final markerIcon = IconButton(
//                     icon: const Icon(Icons.location_on),
//                     onPressed: () => statefulMapController.mutateMarker(
//                         name: "some marker",
//                         property: "showText",
//                         value: !(state["showText"] as bool)));
//                 if (state["showText"] == true) {
//                   w = Column(children: <Widget>[
//                     markerIcon,
//                     Container(
//                         color: Colors.white,
//                         child: Padding(
//                             padding: const EdgeInsets.all(5.0),
//                             child: Text("M", textScaleFactor: 1.3))),
//                   ]);
//                 } else {
//                   w = markerIcon;
//                 }
//                 return w;
//               }));
//     });
//   }

//   //this function is confirm add new polygon
//   addPolygon() {}

//   //this function is cancel
//   cancel() {
//     setState(() {
//       if (_addValue == 'Street Segment') {
//         _addPolylineMarkers.clear();
//         _addPolylinePoints.clear();
//         _addPolyline = null;
//         _isAdd = false;
//         _addStreetSegmentStr = "Add Street Segment";
//       } else {
//         _addPolygonMarkers.clear();
//         _addPolygonPoints.clear();
//         _addPolygon = null;
//         _isAdd = false;
//         if (_addValue == 'Group') {
//           _addGroupStr = "Add Group";
//         } else if (_addValue == 'Building') {
//           _addBuildingStr = "Add Building";
//         } else if (_addValue == 'Campus') {
//           _addCampusStr = "Add Campus";
//         }
//       }
//       _addValue = "";
//     });
//   }

//   // the timer function
//   setUpTimeFetch() {
//     timerGetWidget =
//         Timer.periodic(Duration(milliseconds: 500), (timerGetWidget) {
//       if (_storePoints.length > 0 && !_isAddStoreMarkers) {
//         getStoreMarker();
//         _isAddStoreMarkers = true;
//       }
//       setState(() {
//         if (timerCount > 41) {
//           timerCount = 0;
//         }
//       });
//       if (timerCount > 40) timerGetWidget.cancel();
//       timerCount += 1;
//     });
//   }

//   // this function change iscafefilter value
//   onCafeFilterChange(bool value) {
//     setState(() {
//       _isCafeFilter = value;
//     });
//   }

//   onRestaurantFilterChange(bool value) {
//     setState(() {
//       _isRestaurantFilter = value;
//     });
//   }

//   // this function is get store marker
//   getStoreMarker() {
//     if (_isCafeFilter || _isRestaurantFilter) {
//       var i = 0;
//       for (var point in _storePoints) {
//         var typeName = _jsonPoint['features'][i]['properties']['f1'] == null
//             ? "No name"
//             : _jsonPoint['features'][i]['properties']['f1'];
//         var name = _jsonPoint['features'][i]['properties']['f2'] == null
//             ? "No name"
//             : _jsonPoint['features'][i]['properties']['f2'];
//         i++;
//         if (typeName.toString().contains('cafe') && _isCafeFilter) {
//           _storeMarkers.add(Marker(
//             point: point,
//             builder: (context) => Icon(
//               Icons.local_cafe,
//               color: Colors.brown,
//             ),
//           ));
//         } else if (name.toString().contains('cafe') && _isCafeFilter) {
//           _storeMarkers.add(Marker(
//             point: point,
//             builder: (context) => Icon(
//               Icons.local_cafe,
//               color: Colors.brown,
//             ),
//           ));
//         } else if (typeName.toString().contains('restaurant') &&
//             _isRestaurantFilter) {
//           _storeMarkers.add(Marker(
//             point: point,
//             builder: (context) => Icon(
//               Icons.local_dining,
//               color: Colors.red,
//             ),
//           ));
//         } else if (typeName.toString().contains('restaurant') &&
//             _isRestaurantFilter) {
//           _storeMarkers.add(Marker(
//             point: point,
//             builder: (context) => Icon(
//               Icons.local_dining,
//               color: Colors.red,
//             ),
//           ));
//         }
//       }
//     } else {
//       var i = 0;
//       for (var point in _storePoints) {
//         var typeName = _jsonPoint['features'][i]['properties']['f1'] == null
//             ? "No name"
//             : _jsonPoint['features'][i]['properties']['f1'];
//         if (typeName.toString().contains('cafe')) {
//           _storeMarkers.add(Marker(
//             point: point,
//             builder: (context) => Icon(
//               Icons.local_cafe,
//               color: Colors.brown,
//             ),
//           ));
//         } else if (typeName.toString().contains('police')) {
//           _storeMarkers.add(Marker(
//             point: point,
//             builder: (context) => Icon(Icons.local_activity),
//           ));
//         } else if (typeName.toString().contains('convenience')) {
//           _storeMarkers.add(Marker(
//               point: point,
//               builder: (context) => Icon(
//                     Icons.local_convenience_store,
//                     color: Colors.blue,
//                   )));
//         } else if (typeName.toString().contains('zoo')) {
//           _storeMarkers.add(Marker(
//               point: point,
//               builder: (context) => Icon(
//                     Icons.local_activity,
//                   )));
//         } else if (typeName.toString().contains('bar')) {
//           _storeMarkers.add(Marker(
//               point: point,
//               builder: (context) => Icon(Icons.local_bar, color: Colors.red)));
//         } else if (typeName.toString().contains('hotel')) {
//           _storeMarkers.add(Marker(
//               point: point,
//               builder: (context) =>
//                   Icon(Icons.local_hotel, color: Colors.red)));
//         } else if (typeName.toString().contains('college')) {
//           _storeMarkers.add(Marker(
//               point: point,
//               builder: (context) => Icon(Icons.school, color: Colors.blue)));
//         }
//       }
//     }
//   }
// }
