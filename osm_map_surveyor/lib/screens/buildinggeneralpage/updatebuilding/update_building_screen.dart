import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osm_map_surveyor/behaviorsubject/building_behavior.dart';
import 'package:osm_map_surveyor/bloc/liststreetsegment_bloc.dart';
import 'package:osm_map_surveyor/events/building_event.dart';
import 'package:osm_map_surveyor/events/liststreetsegment_event.dart';
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/models/buildingpost.dart';
import 'package:osm_map_surveyor/models/buildingtypes.dart';
import 'package:osm_map_surveyor/models/floor.dart';
import 'package:osm_map_surveyor/models/streetsegment.dart';
import 'package:osm_map_surveyor/repositories/building_repository.dart';
import 'package:osm_map_surveyor/repositories/liststreetsegment_repository.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/building/buiding_map.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/building/floor/create_floor_page.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/building/floor/update_floor_page.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/updatebuilding/buildingsegment/building_segment_screen.dart';
import 'package:osm_map_surveyor/states/building_state.dart';
import 'package:osm_map_surveyor/states/liststreetsegment_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'dart:io';
import 'package:geodesy/geodesy.dart';
import 'package:osm_map_surveyor/bloc/building_bloc.dart';
import 'package:osm_map_surveyor/models/campus.dart';
import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/utilities/geolocator_utils.dart';
import 'package:osm_map_surveyor/utilities/progress_bar.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';


enum PictureOption { OpenCamera, OpenGallery, RemovePicture }
enum FloorOption { AddFloor, AddBasement }

class UpdateBuildingScreen extends StatefulWidget {
  final int buildingId;
  final LatLng systemZoneCenter;
  UpdateBuildingScreen({Key key, @required this.buildingId, @required this.systemZoneCenter}) : super(key: key);

  @override
  _UpdateBuildingScreenState createState() => _UpdateBuildingScreenState(this.buildingId, this.systemZoneCenter);
}

class _UpdateBuildingScreenState extends State<UpdateBuildingScreen> {
  int buildingId;
  LatLng systemZoneCenter;
  _UpdateBuildingScreenState(this.buildingId, this.systemZoneCenter);

  final _imagePicker = ImagePicker();
  final _nameTextController = TextEditingController();
  final _addressTextController = TextEditingController();
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: Config.storageBucket);

  StorageUploadTask uploadTask;
  File imageFile;
  String imageUrl;
  String geomBuilding;
  String dropdownTypesValue;
  ListStreetSegments listStreetSegments;
  ListStreetSegments initListStreetSegments;
  List<BuildingType> listBuildingTypes;
  List<String> listBuildingTypeNames;
  List<Floor> floors;
  FocusNode nameNode;
  FocusNode addressNode;
  Building initBuilding;

  BuildingBehavior _buildingBehavior = BuildingBehavior();
  BuildingBloc _buildingBloc;
  ListStreetSegmentBloc _listStreetSegmentBloc;
  bool _isShowStreetSegments = false;
  bool _isBuildingGeom = false;
  bool _isShowFloors = false;
  bool _isInitLoadSuccess = false;
  bool _isLoadListStreetSegment = false;
  bool _isLoadListStreetSegmentByBuildingId = false;
  bool _isInitFloor = false;
  bool _isGetStreetSegment = false;
  bool _isSaveDraft = false;
  String _imageController;
  String _geomController;
  String _streetsegmentController;
  Campus _campus;
  List<LatLng> _buildingPolygonPoints = [];
  ProgressBar _progressBar;

  @override
  void initState() {
    super.initState();
    _progressBar = ProgressBar();
    nameNode = FocusNode();
    addressNode = FocusNode();
    _buildingBloc = BuildingBloc(buildingRepository: BuildingRepository());
    _listStreetSegmentBloc = ListStreetSegmentBloc(listStreetSegmentRepository: ListStreetSegmentRepository());
    _buildingBloc.add(LoadBuildingDetailsById(id: buildingId));
    _nameTextController.addListener(() {
      _buildingBehavior.nameBuildingSink.add(_nameTextController.text);
    });
    _buildingBehavior.nameBuildingSink.add(_nameTextController.text);
    _addressTextController.addListener(() {
      _buildingBehavior.addressBuildingSink.add(_addressTextController.text);
    });
    _buildingBehavior.imageBuildingSink.add(_imageController);
    _buildingBehavior.geomBuildingSink.add(_geomController);
    _buildingBehavior.streetSegmentSink.add(_streetsegmentController);
  }

  void initListBuildingType() {
    setState(() {
      listBuildingTypes = initListBuildingTypes.toList();
      listBuildingTypeNames= initListBuildingTypeNames.toList();
      dropdownTypesValue = listBuildingTypeNames[0].toString();
    });
  }

  void checkInitLoad() {
    if (_isLoadListStreetSegment && _isLoadListStreetSegmentByBuildingId) {
      setState(() {
        _isInitLoadSuccess = true;
      });
    }
  }

  void initBuildingFunction() {
    imageUrl = initBuilding.imageUrl;
    _imageController = imageUrl;
    _buildingBehavior.imageBuildingSink.add(_imageController);
    _nameTextController.text = initBuilding.name;
    _buildingBehavior.nameBuildingSink.add(_nameTextController.text);
    if (initBuilding.type != null) {
      dropdownTypesValue = initBuilding.type;
    }
    _addressTextController.text = initBuilding.address;
    _buildingBehavior.addressBuildingSink.add(_addressTextController.text);
    _campus = Campus();
    _campus.id = initBuilding.campusId;
    if (initBuilding.floors != null) {
      floors = initBuilding.floors.toList();
    }
    if (floors != null) {
      if (floors.length > 0) {
        _isInitFloor = true;
      } else {
        _isInitFloor = false;
      }
    } else {
      _isInitFloor = false;
    }
    if (initBuilding.coordinateString != null || initBuilding.coordinateString.isNotEmpty) {
      List<dynamic> listBuildingPointsPrefs =jsonDecode(initBuilding.coordinateString);
      _buildingPolygonPoints.clear();
      if (
        (listBuildingPointsPrefs.last[0] == listBuildingPointsPrefs.first[0]) 
          && (listBuildingPointsPrefs.last[1] == listBuildingPointsPrefs.first[1])
      ) {
        listBuildingPointsPrefs.removeLast();
      }
      for (var pointPrefs in listBuildingPointsPrefs) {
        var latitude = pointPrefs[1];
        var longtitude = pointPrefs[0];
        _buildingPolygonPoints.add(LatLng(latitude, longtitude));
      }
      updateBuildingGeom();
      _geomController = geomBuilding;
      _buildingBehavior.geomBuildingSink.add(_geomController);
      _isBuildingGeom = true;
      _listStreetSegmentBloc.add(LoadListStreetSegment(points: _buildingPolygonPoints));
    }
  }

  void initSharePreferenceId() async {
    final prefs = await SharedPreferences.getInstance();
    String buildingPrefs = prefs.getString(Config.draftUpdateBuilding + buildingId.toString());
    if (buildingPrefs != null) {
      Building tmp = Building.fromJson(jsonDecode(buildingPrefs));
      setState(() {
        imageUrl = tmp.imageUrl;
        _imageController = imageUrl;
        _buildingBehavior.imageBuildingSink.add(_imageController);
        _nameTextController.text = tmp.name;
        _buildingBehavior.nameBuildingSink.add(_nameTextController.text);
        _addressTextController.text = tmp.address;
        _buildingBehavior.addressBuildingSink.add(_addressTextController.text);
        if (tmp.floors != null) {
          floors = tmp.floors.toList();
        }
        String listStreetSegmentPrefsId = prefs.get(Config.draftUpdateBuildingStreetSegment + buildingId.toString());
        if (listStreetSegmentPrefsId != null) {
          listStreetSegments = ListStreetSegments.fromJson(jsonDecode(listStreetSegmentPrefsId));
          _streetsegmentController = "true";
          _buildingBehavior.streetSegmentSink.add(_streetsegmentController);
        }
        String listBuildingPolygonPointsPrefsId = prefs.get(Config.draftUpdateBuildingPolygonPoints + buildingId.toString());
        if (listBuildingPolygonPointsPrefsId != null) {
          List<dynamic> listBuildingPointsPrefs = jsonDecode(listBuildingPolygonPointsPrefsId);
          _buildingPolygonPoints.clear();
          if (
            (listBuildingPointsPrefs.last[0] == listBuildingPointsPrefs.first[0]) 
              && (listBuildingPointsPrefs.last[1] == listBuildingPointsPrefs.first[1])
          ) {
            listBuildingPointsPrefs.removeLast();
          }
          for (var pointPrefs in listBuildingPointsPrefs) {
            var latitude = pointPrefs[0];
            var longtitude = pointPrefs[1];
            _buildingPolygonPoints.add(LatLng(latitude, longtitude));
          }
          updateBuildingGeom();
          _geomController = geomBuilding;
          _buildingBehavior.geomBuildingSink.add(_geomController);
          _isBuildingGeom = true;
        }
        dropdownTypesValue = tmp.type;
        _listStreetSegmentBloc.add(LoadListStreetSegment(points: _buildingPolygonPoints));
      });
    }
  }

  void checkSaveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    String buildingPrefs = prefs.getString(Config.draftUpdateBuilding + buildingId.toString());
    if (buildingPrefs != null) {
      _isSaveDraft = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _buildingBehavior.dispose();
    _buildingBloc.close();
    _listStreetSegmentBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: body(context),
    );
  }

  Widget appBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios, 
          color: Colors.white,
          size: MediaQuery.of(context).size.height * 0.025,
        ),
        onPressed: () {
          if (_isInitLoadSuccess) {
            bool _isChange = false;
            if (_nameTextController.text != null) {
              if (_nameTextController.text.trim().isNotEmpty) {
                if (initBuilding.name != _nameTextController.text.trim().toString()) {
                  _isChange = true;
                }
              }
            }

            if (imageFile != null) {
              _isChange = true;
            }

            if (_buildingPolygonPoints.isNotEmpty) {
              if (initBuilding.coordinateString != null || initBuilding.coordinateString.isNotEmpty) {
                List<dynamic> listBuildingPointsPrefs =jsonDecode(initBuilding.coordinateString);
                if (
                  (listBuildingPointsPrefs.last[0] == listBuildingPointsPrefs.first[0]) 
                    && (listBuildingPointsPrefs.last[1] == listBuildingPointsPrefs.first[1])
                ) {
                  listBuildingPointsPrefs.removeLast();
                }
                List<LatLng> tmpBuildingPolygonPoints = new List<LatLng>();
                for (var pointPrefs in listBuildingPointsPrefs) {
                  var latitude = pointPrefs[1];
                  var longtitude = pointPrefs[0];
                  tmpBuildingPolygonPoints.add(LatLng(latitude, longtitude));
                }
                if (tmpBuildingPolygonPoints.isEmpty) {
                  _isChange = true;
                } else {
                  if (!ListEquality().equals(_buildingPolygonPoints, tmpBuildingPolygonPoints)) {
                    _isChange = true;
                  }
                }
              }
            }

            if (floors != null) {
              if (floors.length > 0) {
                if (initBuilding.floors != null) {
                  if (initBuilding.floors.isNotEmpty) {
                    if (!ListEquality().equals(floors, initBuilding.floors)) {
                      _isChange = true;
                    }
                  } else {
                    _isChange = true;
                  }
                } else {
                  _isChange = true;
                }
              }
            }

            if (_isChange && initBuilding.isEditable) {
              saveDraft();
            } else {
              Navigator.of(context).pop();
            }
          } 
        },
      ), 
      iconTheme: IconThemeData(
        color: Config.iconThemeColor,
      ),
      backgroundColor: Config.secondColor,
      title: Container(
        child: Container(
          child: Row(
            children: <Widget>[
              if (initBuilding != null) Expanded(
                child: Text(
                  initBuilding.isEditable ? 'Update building' : 'Building',
                  style: TextStyle(
                    fontSize: Config.textSizeMedium,
                    color: Colors.white,
                  ),
                ),
              ),
              if (initBuilding != null) if (initBuilding.isEditable) IconButton(
                icon: Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.09,
                ),
                onPressed: () {
                  if (_isInitLoadSuccess) showDeleteBuildingDialog(Config.deleteBuildingHeader, Config.deleteBuildingMessage, context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
    return ListView(
      children: <Widget>[
        if (!_isInitLoadSuccess) loadingWidget(context),
        if (_isInitLoadSuccess) buildingDetailsWidget(context),
        if (_isInitLoadSuccess && initBuilding.isEditable) footerWidget(context),
        blocListenerWidget(),
      ],
    );
  }

  Widget loadingWidget(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      child: Center(
        child: CircularProgressIndicator(
          backgroundColor: Config.thirdColor,
          valueColor: AlwaysStoppedAnimation<Color>(Config.secondColor),
        ),
      ),
    );
  }

  Widget blocListenerWidget() {
    return MultiBlocListener(
      listeners: [
        listStreetSegmentBlocListenerWidget(),
        buildingBlocListenerWidget(),
      ],
      child: SizedBox(),
    );
  }

  Widget listStreetSegmentBlocListenerWidget() {
    return BlocListener(
      bloc: _listStreetSegmentBloc,
      listener: (BuildContext context, ListStreetSegmentState state) async {
        if (state is LoadListStreetSegmentDataFinishState) {
          setState(() {
            initListStreetSegments = ListStreetSegments(listStreetSegment: state.listStreetSegments.listStreetSegment.toList());
            _isLoadListStreetSegment = true;
          });
          checkInitLoad();
        }
      },
      child: SizedBox(),
    );
  }

  Widget buildingBlocListenerWidget() {
    return BlocListener(
      bloc: _buildingBloc,
      listener: (BuildContext context, BuildingState state) async {
        if (state is LoadListStreetSegmentsByBuildingIdFinishState) {
          final prefs = await SharedPreferences.getInstance();
          String draftBuilding = prefs.get(Config.draftUpdateBuilding + buildingId.toString());
          setState(() {
            if (draftBuilding == null) {
              listStreetSegments = new ListStreetSegments(listStreetSegment: state.listStreetSegments.listStreetSegment.toList());
              _streetsegmentController = "true";
              _buildingBehavior.streetSegmentSink.add(_streetsegmentController);
            }
            _isLoadListStreetSegmentByBuildingId = true;
          });
          checkInitLoad();
        } else if (state is UpdateBuildingSucessState) {
          hideSendingProgressBar();
          removeDraftBuilding();
          Navigator.pop(context, [true, false]);
        } else if (state is DeleteBuildingSucessState) {
          hideSendingProgressBar();
          removeDraftBuilding();
          Navigator.pop(context, [false, true, state.isSuccess]);
        } else if (state is LoadBuildingDetailsByIdFinishState) {
          setState(() {
            initBuilding = state.building;
          });
          initListBuildingType();
          initBuildingFunction();
          checkSaveDraft();
          _buildingBloc.add(LoadListStreetSegmentsByBuildingId(id: buildingId));
        }
      },
      child: SizedBox(),
    );
  }

  Widget buildingDetailsWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: MediaQuery.of(context).size.height * 0.01,
            color: Colors.black.withOpacity(0.1),
            spreadRadius: MediaQuery.of(context).size.height * 0.01,
          )
        ],
      ),
      height: initBuilding.isEditable ? MediaQuery.of(context).size.height * 0.75 : MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.01,
      ),
      child: ListView( 
        children: <Widget>[
          if (_isSaveDraft) showNoticeSaveDraft(context),
          if (_isSaveDraft) SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          buildingNameInputTextField(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          imageZoneWidget(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          listTypeDropDownButton(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          inputMapRowWidget(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          buildingAddressInputTextField(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          streetSegmentPart(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          floorPart(context),
        ],
      ),
    );
  }

  Widget showNoticeSaveDraft(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.01,
        left: MediaQuery.of(context).size.width * 0.025,
        right: MediaQuery.of(context).size.width * 0.025,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.01,
        bottom: MediaQuery.of(context).size.height * 0.01,
      ),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black12,
          width: MediaQuery.of(context).size.height * 0.001,
        ),
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width * 0.02,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 3,
            offset: Offset(1, 2), // Shadow position
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Text('Do you want to update the lastest change ?'),
          ),
          Container(
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  color: Config.secondColor,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.02,
                    )
                  ),
                  onPressed: () {
                    setState(() {
                      _isSaveDraft = false;
                    });
                    removeDraftBuilding();
                  },
                  child: Text('Cancel'),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.03,),
                RaisedButton(
                  color: Config.secondColor,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.02,
                    )
                  ),
                  onPressed: () {
                    setState(() {
                      initSharePreferenceId();
                      _isSaveDraft = false;
                    });
                    removeDraftBuilding();
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget imageZoneWidget() {
    return StreamBuilder(
      stream: _buildingBehavior.imageBuildingStream,
      builder: (context, snapshot) {
        return Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.01,
            left: MediaQuery.of(context).size.width * 0.025,
            right: MediaQuery.of(context).size.width * 0.025,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.01,
          ),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.02),
                      child: Icon(
                        Icons.image,
                        color: Config.secondColor.withOpacity(0.54),
                        size: Config.textSizeSuperSmall * 1.2,
                      ),
                    ),
                    Text(
                      'Image',
                      style: TextStyle(
                        fontSize: Config.textSizeSuperSmall * 1.2,
                        color: Colors.black54
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                    Expanded(
                      child: Container(
                        color: Config.secondColor.withOpacity(0.54),
                        height: MediaQuery.of(context).size.height * 0.001,
                      ),
                    ),
                  ],
                ),
              ),
              if (initBuilding.isEditable) Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
                  RaisedButton(
                    color: Config.secondColor,
                    disabledColor: Config.secondColor.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.02,
                      ),
                    ),
                    onPressed: initBuilding.isEditable 
                      ? () {
                        showImageDialog();
                      } 
                      : null,
                    textColor: Colors.white,
                    disabledTextColor: Colors.white,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: MediaQuery.of(context).size.height * 0.05,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_rounded, 
                            color: Colors.white,
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                          Text(
                            'Select image',
                            style: TextStyle(
                              fontSize: Config.textSizeSmall,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: imageUrl == null 
                  ? snapshot.data != null 
                    ? MediaQuery.of(context).size.height * 0.03
                    : MediaQuery.of(context).size.height * 0.25
                  : MediaQuery.of(context).size.height * 0.25,
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.005,
                  bottom: MediaQuery.of(context).size.height * 0.005,
                ),
                child: Center(
                  child: imageUrl == null
                    ? snapshot.data != null
                      ? Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.05,
                        ),
                        child: Text(
                          'No image available',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: Config.textSizeSmall,
                          ),
                        ),
                      )
                      : imageFile != null
                        ? Image.file(
                          imageFile,
                          fit: BoxFit.fill,
                        )
                        : Container()
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.fill,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildingNameInputTextField(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.01,
        left: MediaQuery.of(context).size.width * 0.025,
        right: MediaQuery.of(context).size.width * 0.025,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.01,
      ),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.01,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Config.secondColor.withOpacity(0.54),
                  size: Config.textSizeSuperSmall * 1.2,
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                Text(
                  'Name',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: Config.textSizeSuperSmall * 1.2,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                Expanded(
                  child: Container(
                    color: Config.secondColor.withOpacity(0.54),
                    height: MediaQuery.of(context).size.height * 0.001,
                  ),
                ),
              ],
            ),
          ),
          initBuilding.isEditable
            ? Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              child: StreamBuilder(
                stream: _buildingBehavior.nameBuildingStream,
                builder: (context, snapshot) {
                  return TextField(
                    focusNode: nameNode,
                    autofocus: false,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: TextStyle(
                      fontSize: Config.textSizeSmall,
                    ),
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Config.secondColor,
                        ),
                      ),
                      alignLabelWithHint: false,
                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: Config.textSizeSuperSmall,
                      ),
                      labelStyle: TextStyle(
                        color: Config.secondColor,
                        fontSize: Config.textSizeSuperSmall
                      ),
                      hintText: "Input the building name",
                      errorText: snapshot.data,
                    ),
                    controller: _nameTextController,
                  );
                },
              ),
            ) 
            : Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                initBuilding.name != null ? initBuilding.name.toString() : "Not available",
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                ),
              )
            ),
        ],
      ),
    );
  }

  Widget footerWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Config.secondColor,
            width: MediaQuery.of(context).size.height * 0.005,
          ),
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.125,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (initBuilding.isEditable) segmentButton(context),
          updateButton(context),
        ],
      ),
    );
  }

  Widget segmentButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.49,
      height: MediaQuery.of(context).size.height * 0.065,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: RaisedButton(
        onPressed: () {
          _goToSegmentScreen();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02,),
        ),
        color: Config.secondColor,
        disabledColor: Config.secondColor.withOpacity(0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.1,
              child: Icon(
                Icons.segment,
                color: Colors.white,
                size: MediaQuery.of(context).size.width * 0.06,
              ),
            ),
            Text(
              "Segment",
              style: TextStyle(
                fontSize: Config.textSizeSmall,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget updateButton(BuildContext context) {
    return Container(
      width: initBuilding.isEditable? MediaQuery.of(context).size.width * 0.49 : MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.height * 0.065,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: StreamBuilder(
        stream: _buildingBehavior.submitBuildingStream,
        builder: (context, snapshot) {
          return RaisedButton(
            onPressed: snapshot.data == true && initBuilding.isEditable
              ? () {
                showUpdateBuildingDialog(
                  Config.updateBuildingHeader,
                  Config.updateBuildingMessage, 
                  context
                );
              }
              : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02,),
            ),
            color: Config.secondColor,
            disabledColor: Config.secondColor.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Icon(
                    Icons.mode_edit,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                ),
                Text(
                  initBuilding.isEditable ? "Update" : "Not allow to update",
                  style: TextStyle(
                    fontSize: Config.textSizeSmall,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget floorPart(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.01,
              left: MediaQuery.of(context).size.width * 0.025,
              right: MediaQuery.of(context).size.width * 0.025,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  Config.floorSvgIcon,
                  color: Config.secondColor,
                  height: Config.textSizeSuperSmall * 1.2,
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                Text(
                  'Floor',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: Config.textSizeSuperSmall * 1.2,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                Expanded(
                  child: Container(
                    color: Config.secondColor.withOpacity(0.54),
                    height: MediaQuery.of(context).size.height * 0.001,
                  ),
                ),
              ],
            ),
          ),
          listFloorsButton(context),
          listFloorsWidget(context),
        ],
      ),
    );
  }

  Widget listTypeDropDownButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.01,
        left: MediaQuery.of(context).size.width * 0.03,
        right: MediaQuery.of(context).size.width * 0.025,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.01,
      ),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              SvgPicture.asset(
                Config.menuSvgIcon,
                color: Config.secondColor.withOpacity(0.54),
                height: MediaQuery.of(context).size.width * 0.025,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
              Text(
                'Type',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: Config.textSizeSuperSmall * 1.2,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
              Expanded(
                child: Container(
                  color: Config.secondColor.withOpacity(0.54),
                  height: MediaQuery.of(context).size.height * 0.001,
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          if (listBuildingTypeNames != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
                initBuilding.isEditable 
                  ? Container(
                    decoration: BoxDecoration(
                      color: Config.secondColor,
                      border: Border.all(
                        color: Config.secondColor,
                      ),
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.02,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.525,
                    height: MediaQuery.of(context).size.height * 0.06,
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.02,
                      right: MediaQuery.of(context).size.width * 0.02,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: dropdownTypesValue,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white,),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Config.textSizeSmall,
                        ),
                        dropdownColor: Config.secondColor,
                        onChanged: (String newValue) {
                          setState(() {
                            dropdownTypesValue = newValue;
                          });
                        },
                        items: listBuildingTypeNames.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ) 
                  : Container(
                      width: MediaQuery.of(context).size.width * 0.525,
                      height: MediaQuery.of(context).size.height * 0.025,
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.005,
                        right: MediaQuery.of(context).size.width * 0.005,
                      ),
                      child: Text(
                        initBuilding.type != null ? initBuilding.type.toString() : 'Not available',
                        style: TextStyle(
                          fontSize: Config.textSizeSmall,
                        )
                      ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget inputMapRowWidget(BuildContext context) {
    return StreamBuilder(
      stream: _buildingBehavior.geomBuildingStream,
      builder: (context, snapshot) {
        return Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.01,
            left: MediaQuery.of(context).size.width * 0.025,
            right: MediaQuery.of(context).size.width * 0.025,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.01,
          ),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Icon(
                    Icons.pin_drop_sharp,
                    color: Config.secondColor.withOpacity(0.54),
                    size: Config.textSizeSuperSmall * 1.2,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                  Container(
                    child: Text(
                      'Building base',
                      style: TextStyle(
                        fontSize: Config.textSizeSuperSmall * 1.2,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                  Expanded(
                    child: Container(
                      color: Config.secondColor.withOpacity(0.54),
                      height: MediaQuery.of(context).size.height * 0.001,
                    ),
                  ),  
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  if (initBuilding.isEditable) RaisedButton(
                    onPressed: initBuilding.isEditable
                      ? () {
                        goToMapPage();
                      }
                      : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.02,
                      ),
                    ),
                    color: Config.secondColor,
                    disabledColor: Config.secondColor.withOpacity(0.5),
                    textColor: Colors.white,
                    disabledTextColor: Colors.white,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: MediaQuery.of(context).size.height * 0.05,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map,
                            color: Colors.white,
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                          Text(
                            'Go to map',
                            style: TextStyle(
                              fontSize: Config.textSizeSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                child: snapshot.data != null
                  ? Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05,
                      top: MediaQuery.of(context).size.height * 0.01,
                    ),
                    child: Text(
                      snapshot.data,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  )
                  : Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05,
                      top: MediaQuery.of(context).size.height * 0.01,
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: ListView(
                      children: [
                        for (int i=0; i < _buildingPolygonPoints.length; i++)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Point: ' + (i+1).toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: Config.textSizeSmall,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Latitude : ' + _buildingPolygonPoints[i].latitude.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: Config.textSizeSmall * 0.9,
                                ),
                              ),
                              Text(
                                'Longitude : ' + _buildingPolygonPoints[i].longitude.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: Config.textSizeSmall * 0.9,
                                ),
                              ),
                            ],
                          )  
                      ],
                    )
                  ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget checkBoxBuilding(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.18,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.035,
      ),
      child: CheckboxListTile(
        checkColor: Config.thirdColor,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Config.secondColor,
        value: _isBuildingGeom,
        onChanged: (value) {},
      ),
    );
  }

  Widget buildingAddressInputTextField(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.01,
        left: MediaQuery.of(context).size.width * 0.025,
        right: MediaQuery.of(context).size.width * 0.025,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.01,
      ),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.01,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Config.secondColor.withOpacity(0.54),
                  size: Config.textSizeSuperSmall * 1.2,
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                Text(
                  'Building address',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: Config.textSizeSuperSmall * 1.2,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                Expanded(
                  child: Container(
                    color: Config.secondColor.withOpacity(0.54),
                    height: MediaQuery.of(context).size.height * 0.001,
                  ),
                ),
              ],
            ),
          ),
          initBuilding.isEditable
            ? Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              child: StreamBuilder(
                stream: _buildingBehavior.addressBuildingStream,
                builder: (context, snapshot) {
                  return TextField(
                    autofocus: false,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: TextStyle(
                      fontSize: Config.textSizeSmall,
                    ),
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Config.secondColor,
                        ),
                      ),
                      alignLabelWithHint: false,
                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: Config.textSizeSuperSmall,
                      ),
                      hintText: "Input the store address",
                      errorText: snapshot.data,
                    ),
                    controller: _addressTextController,
                  );
                },
              ),
            )
            : Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                initBuilding.address != null ? initBuilding.address.toString() : 'Not available',
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget streetSegmentPart(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.01,
              left: MediaQuery.of(context).size.width * 0.025,
              right: MediaQuery.of(context).size.width * 0.025,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  Config.streetSegmentSvgIcon,
                  color: Config.secondColor,
                  height: Config.textSizeSuperSmall * 1.2,
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                Text(
                  'Street Segment',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: Config.textSizeSuperSmall * 1.2,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                Expanded(
                  child: Container(
                    color: Config.secondColor.withOpacity(0.54),
                    height: MediaQuery.of(context).size.height * 0.001,
                  ),
                ),
              ],
            ),
          ),
          listStreetSegmentsButton(context),
          listStreetSegmentsWidget(context),
        ],
      ),
    );
  }

  Widget listStreetSegmentsButton(BuildContext context) {
    return FlatButton(
      onPressed: () {
        setState(() {
          if (_isShowStreetSegments) {
            _isShowStreetSegments = false;
          } else {
            _isShowStreetSegments = true;
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.01,
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.01,
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.07,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Config.secondColor,
            width: MediaQuery.of(context).size.width * 0.002,
          ),
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02,),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 3,
              offset: Offset(2, 4), // Shadow position
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.125,
              height: MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Config.redColor,
                    width: MediaQuery.of(context).size.width * 0.004,
                  ),
                ),
              ),
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.02,
                right: MediaQuery.of(context).size.width * 0.02,
              ),
              padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.02,
              ),
              child: SvgPicture.asset(
                Config.streetSegmentSvgIcon,
                color: Config.secondColor,
              ),
            ),
            Expanded(
              child: Text(
                "Street Segments",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Config.textSizeSuperSmall,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              child: listStreetSegments != null
                ? Text(
                  listStreetSegments.listStreetSegment.length.toString() +
                  (listStreetSegments.listStreetSegment.length < 2
                    ? " street segment"
                    : " street segments")
                )
                : Text('0 street segment'),
            ),
            _isShowStreetSegments
              ? Icon(
                Icons.arrow_drop_down,
                size: MediaQuery.of(context).size.width * 0.1,
              )
              : Icon(
                Icons.arrow_right,
                size: MediaQuery.of(context).size.width * 0.1,
              ),
          ],
        ),
      ),
    );
  }

  Widget listStreetSegmentsWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(),
      child: _isShowStreetSegments
        ? Column(
          children: <Widget>[
            if (listStreetSegments != null)
              if (listStreetSegments.listStreetSegment.length > 0)
                for (var streetsegment in listStreetSegments.listStreetSegment)
                  if (streetsegment.name != null) streetSegmentWidget(context, streetsegment),
            if (listStreetSegments != null)
              if (listStreetSegments.listStreetSegment.length == 0 && !_isGetStreetSegment && initBuilding.isEditable) getListStreetSegmentButton(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
            if (listStreetSegments == null && _isGetStreetSegment) Container(child: Text("No segment available")),
          ],
        )
        : SizedBox(),
    );
  }

  Widget getListStreetSegmentButton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.height * 0.05,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: RaisedButton(
        onPressed: () {
          setState(() {
            listStreetSegments = ListStreetSegments(listStreetSegment: initListStreetSegments.listStreetSegment.toList());
            _streetsegmentController = "true";
            _isGetStreetSegment = true;
            _buildingBehavior.streetSegmentSink.add(_streetsegmentController);
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.01),
        ),
        color: Config.secondColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Get street segments",
              style: TextStyle(
                fontSize: Config.textSizeSuperSmall,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget streetSegmentWidget(BuildContext context, StreetSegment streetSegment) {
    return Tooltip(
      message: streetSegment.name,
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.01,
        ),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.06,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              width: MediaQuery.of(context).size.width * 0.002,
              color: Config.secondColor),
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02,),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 3,
              offset: Offset(2, 4), // Shadow position
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.05,
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
                Config.streetSegmentSvgIcon,
                color: Config.secondColor,
              ),
            ),
            Expanded(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.01,
                    ),
                    Text(streetSegment.id.toString()),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.02,
                    ),
                    streetSegment.name.length > 14
                      ? Text(streetSegment.name.substring(0, 14) + "...")
                      : Text(streetSegment.name),
                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width * 0.15,
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
                  removeStreetSegment(streetSegment);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget floorWidget(BuildContext context, Floor floor) {
    return FlatButton(
      onPressed: () {
        goToUpdateFloorPage(floor);
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.01,
        ),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.06,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              width: MediaQuery.of(context).size.width * 0.002,
              color: Config.secondColor),
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02,),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 3,
              offset: Offset(2, 4), // Shadow position
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.05,
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
                Config.floorSvgIcon,
                color: Config.secondColor,
              ),
            ),
            Expanded(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    if (floor.name != null) Text("Floor"),
                    floor.name != null? Text(floor.name.toString()) : Text("No information"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listFloorsWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(),
      child: _isShowFloors
        ? Column(
          children: <Widget>[
            if (floors != null)
              for (var i = 0; i < floors.length; i++) floorWidget(context, floors[i]),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            if (initBuilding.isEditable) addFloorButton(context),
          ],
        )
        : SizedBox(),
    );
  }

  Widget addFloorButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.05,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: RaisedButton(
        onPressed: () {
          showFloorDialog();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02,),
        ),
        color: Config.secondColor,
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.1,
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            Text(
              "Add floor",
              style: TextStyle(
                fontSize: Config.textSizeSuperSmall,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listFloorsButton(BuildContext context) {
    return FlatButton(
      onPressed: () {
        setState(() {
          if (_isShowFloors) {
            _isShowFloors = false;
          } else {
            _isShowFloors = true;
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.01,
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.01,
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.07,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Config.secondColor,
            width: MediaQuery.of(context).size.width * 0.002,
          ),
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02,),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 3,
              offset: Offset(2, 4), // Shadow position
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.125,
              height: MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Config.redColor,
                    width: MediaQuery.of(context).size.width * 0.004,
                  ),
                ),
              ),
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.02,
                right: MediaQuery.of(context).size.width * 0.02,
              ),
              padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.02,
              ),
              child: SvgPicture.asset(
                Config.floorSvgIcon,
                color: Config.secondColor,
              ),
            ),
            Expanded(
              child: Text(
                "Floors",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Config.textSizeSuperSmall,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              child: floors != null
                ? Text(floors.length.toString() + (floors.length < 2 ? " floor" : " floors"))
                : Text('0 floor'),
            ),
            _isShowFloors
              ? Icon(
                  Icons.arrow_drop_down,
                  size: MediaQuery.of(context).size.width * 0.1,
                )
              : Icon(
                  Icons.arrow_right,
                  size: MediaQuery.of(context).size.width * 0.1,
                ),
          ],
        ),
      ),
    );
  }

  void goToCreateFloorPage(bool isAddFloor) async {
    dynamic rs;
    rs = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateFloorPage(isAddFloor: isAddFloor))
    );

    if (rs != null) {
      addFloor(rs, isAddFloor);
      showToast(context, Config.addFloorSuccessMessage, true);
    }
  }

  void goToUpdateFloorPage(Floor floor) async {
    dynamic rs;
    rs = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateFloorPage(floor: floor, isEditable: initBuilding.isEditable,))
    );

    if (rs != null) {
      if (rs[0]) {
        updateFloor(rs[1]);
        showToast(context, Config.updateFloorSuccessMessage, true);
      } else {
        deleteFloor(rs[1]);
        showToast(context, Config.deleteFloorSuccessMessage, true);
      }
    }
  }

  void addFloor(Floor floor, bool isAddFloor) {
    setState(() {
      if (isAddFloor) {
        if (floors == null) {
          floors = new List<Floor>();
          floor.floorNumber = 0;
          floors.add(floor);
        } else {
          if (floors.length == 0) {
            floor.floorNumber = 0;
            floors.add(floor);
          } else {
            floor.floorNumber = floors.last.floorNumber + 1;
            floors.add(floor);
          }
        }
      } else {
        if (floors == null) {
          floors = new List<Floor>();
          floor.floorNumber = -1;
          floors.add(floor);
        } else {
          if (floors.length == 0) {
            floor.floorNumber = -1;
            floors.add(floor);
          } else {
            List<Floor> tmpList = new List<Floor>();
            if (floors[0].floorNumber >= 0) {
              floor.floorNumber = -1;
              tmpList.add(floor);
              floors.forEach((floorElement) {
                tmpList.add(floorElement);
              });
              floors.clear();
              floors = tmpList.toList();
            } else {
              floor.floorNumber = floors[0].floorNumber - 1;
              tmpList.add(floor);
              floors.forEach((floorElement) {
                tmpList.add(floorElement);
              });
              floors.clear();
              floors = tmpList.toList();
            }
          }
        }
      }
    });
  }

  void updateFloor(Floor floor) {
    setState(() {
      for(int i = 0; i < floors.length; i++) {
        if (floors[i].floorNumber == floor.floorNumber) {
          floors[i] = floor;
        }
      }
    });
  }

  void deleteFloor(Floor floor) {
    setState(() {
      for(int i = 0; i < floors.length; i++) {
        if (floors[i].floorNumber == floor.floorNumber && _isInitFloor == true) {
          floors.removeAt(i);
        } else if (floors[i].floorNumber == floor.floorNumber && _isInitFloor == false) {
          if (floors[i].floorNumber < 0) {
            if (floors[i].floorNumber == floors.first.floorNumber) {
              floors.removeAt(0);
            } else {
              for(int j = i-1; j >= 0; j--) {
                floors[j].floorNumber += 1;
              }
              floors.removeAt(i);
            }
          } else {
            if (floors[i].floorNumber == floors.last.floorNumber) {
              floors.removeLast();
            } else {
              for(int j = i + 1; j < floors.length; j++) {
                floors[j].floorNumber -= 1;
              }
              floors.removeAt(i);
            }
          }
        }
      }
    });
  }

  void resetGeomBuilding() {
    setState(() {
      geomBuilding = null;
      _geomController = null;
      _buildingBehavior.geomBuildingSink.add(_geomController);
      _isBuildingGeom = false;
      listStreetSegments = null;
    });
  }

  void goToMapPage() async {
    nameNode.canRequestFocus = false;
    addressNode.canRequestFocus = false;
    final rs = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuildingMap(
          buildingPolygonPoints: _buildingPolygonPoints,
          centerPoint: _buildingPolygonPoints != null
            ? _buildingPolygonPoints.isNotEmpty 
              ? getCenterPolygon(_buildingPolygonPoints)
              : systemZoneCenter
            : systemZoneCenter,
        )
      )
    );
    if (rs != null) {
      if (rs[0] != null) {
        updateGeomBuilding(rs[0]);
      }
      if (rs[1] != null) {
        updateListStreetSegment(rs[1]);
      }
      if (rs[2] != null) {
        _addressTextController.text = rs[2];
      }
      if (rs[3] != null) {
        _campus = rs[3];
      }
    }
  }

  void updateGeomBuilding(List<LatLng> listPoints) {
    setState(() {
      if (listPoints == null) {
        _buildingPolygonPoints = null;
        geomBuilding = "";
        _geomController = "";
        _buildingBehavior.geomBuildingSink.add(_geomController);
        _isBuildingGeom = false;
      } else {
        if (listPoints.length != 0) {
          _buildingPolygonPoints = listPoints;
          updateBuildingGeom();
          _geomController = geomBuilding;
          _buildingBehavior.geomBuildingSink.add(_geomController);
          _isBuildingGeom = true;
        } else {
          _buildingPolygonPoints = null;
          geomBuilding = "";
          _geomController = "";
          _buildingBehavior.geomBuildingSink.add(_geomController);
          _isBuildingGeom = false;
        }
      }
    });
  }

  void removeStreetSegment(StreetSegment streetSegment) {
    setState(() {
      listStreetSegments.listStreetSegment.remove(streetSegment);
      if (listStreetSegments.listStreetSegment.isEmpty) {
        _streetsegmentController = null;
        _buildingBehavior.streetSegmentSink.add(_streetsegmentController);
      }
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
    geomBuilding = polyCoordinate;
  }

  void updateListStreetSegment(ListStreetSegments listStreetSegmentsTmp) {
    setState(() {
      if (listStreetSegmentsTmp != null) {
        if (listStreetSegmentsTmp.listStreetSegment.length == 0) {
          listStreetSegments = ListStreetSegments(listStreetSegment: listStreetSegmentsTmp.listStreetSegment.toList());
          _streetsegmentController = "true";
          _buildingBehavior.streetSegmentSink.add(_streetsegmentController);
        }
        if (listStreetSegmentsTmp.listStreetSegment.length > 0) {
          listStreetSegments = ListStreetSegments(listStreetSegment: listStreetSegmentsTmp.listStreetSegment.toList());
          _streetsegmentController = "true";
          _buildingBehavior.streetSegmentSink.add(_streetsegmentController);
        }
      } else {
        listStreetSegments = null;
        _streetsegmentController = null;
        _buildingBehavior.streetSegmentSink.add(_streetsegmentController);
      }
    });
  }

  // the function open gallary to select picture
  void _openGallery() async {
    final pickerFile = await _imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickerFile != null) {
        imageFile = File(pickerFile.path);
        _imageController = pickerFile.path;
        _buildingBehavior.imageBuildingSink.add(_imageController);
      }
    });
  }

  // the function open camera to take a picture
  void _openCamera() async {
    final pickerFile = await _imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickerFile != null) {
        imageFile = File(pickerFile.path);
        _imageController = pickerFile.path;
        _buildingBehavior.imageBuildingSink.add(_imageController);
      }
    });
  }

  // the function remove Image
  void _removeImage() {
    setState(() {
      imageFile = null;
      _imageController = null;
      _buildingBehavior.imageBuildingSink.add(_imageController);
    });
  }

  dynamic uploadImageDraft(var imageFile) async {
    StorageReference ref = _storage.ref().child("images/${DateTime.now()}.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    return dowurl.toString();
  }

  void _goToSegmentScreen() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => BuildingSegmentsScreen(buildingId: initBuilding.id, buildingName: initBuilding.name,)),
    );
  }

  void saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    String saveDraftBuildingPrefsId = Config.draftUpdateBuilding + buildingId.toString();
    String saveDraftBuildingStreetSegmentsPrefsId = Config.draftUpdateBuildingStreetSegment + buildingId.toString();
    String saveDraftBuildingPolygonPointsPrefsId = Config.draftUpdateBuildingPolygonPoints + buildingId.toString();
    Building building = new Building();
    building.name = _nameTextController.text;
    building.address = _addressTextController.text;
    building.active = true;
    if (_campus != null && _campus.id != -1) {
      building.campusId = _campus.id;
    }

    if (floors != null) {
      if (floors.length == 0) {
        building.numberOfFloor = 1;
      } else {
        building.floors = floors;
        building.numberOfFloor = floors.length;
      }
    } else {
      building.numberOfFloor = 1;
    }

    if (_buildingPolygonPoints.length != 0) {
      List<List<double>> listBuildingPointsPrefs = [];
      for (var point in _buildingPolygonPoints) {
        listBuildingPointsPrefs.add([point.latitude, point.longitude]);
      }
      prefs.setString(saveDraftBuildingPolygonPointsPrefsId, jsonEncode(listBuildingPointsPrefs));
      building.coordinateString = geomBuilding;
    }
    building.type = dropdownTypesValue;
    if (listStreetSegments != null) {
      prefs.setString(saveDraftBuildingStreetSegmentsPrefsId, jsonEncode(listStreetSegments));
    }
    if (imageUrl == null) {
      if (imageFile != null) {
        building.imageUrl = await uploadImageDraft(imageFile);
      }
    } else {
      building.imageUrl = imageUrl;
    }
    prefs.setString(saveDraftBuildingPrefsId, jsonEncode(building));
    hideSendingProgressBar();
    Navigator.pop(context, [false, false]);
  }

  void showSendingProgressBar() {
    _progressBar.show(context);
  }

  void hideSendingProgressBar() {
    _progressBar.hide();
  }

  void updateBuilding() {
    BuildingPost building = new BuildingPost();
    building.id = initBuilding.id;
    building.name = _nameTextController.text.trim().toString();
    building.address = _addressTextController.text.trim().toString();
    building.active = true;
    if (_campus != null && _campus.id != -1) {
      building.campusId = _campus.id;
    }
    if (floors != null) {
      if (floors.length == 0) {
        building.numberOfFloor = 1;
      } else {
        building.floors = floors;
        building.numberOfFloor = floors.length;
      }
    } else {
      building.numberOfFloor = 1;
    }
    building.coordinateString = geomBuilding;
    if (listBuildingTypes != null) {
      listBuildingTypes.forEach((type) { 
        if (type.name == dropdownTypesValue) {
          building.type = type.id;
        }
      });
    }
    List<int> streetSegmentIds = [];
    for (var streetSegment in listStreetSegments.listStreetSegment) streetSegmentIds.add(streetSegment.id);
    building.streetSegmentIds = streetSegmentIds;
    if (imageUrl == null) {
      uploadImage(imageFile, building);
    } else {
      building.imageUrl = imageUrl;
      _buildingBloc.add(UpdateBuilding(building: building));
    }
  }

  void uploadImage(var imageFile, BuildingPost building) async {
    StorageReference ref = _storage.ref().child("images/${DateTime.now()}.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    building.imageUrl = dowurl.toString();
    _buildingBloc.add(UpdateBuilding(building: building));
  }

  void removeDraftBuilding() async {
    final prefs = await SharedPreferences.getInstance();
    if (buildingId != null) {
      prefs.remove(Config.draftUpdateBuilding + buildingId.toString());
      prefs.remove(Config.draftUpdateBuildingPolygonPoints + buildingId.toString());
      prefs.remove(Config.draftUpdateBuildingStreetSegment + buildingId.toString());
    }
  }

  showDeleteBuildingDialog(String header, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width * 0.01),),
        ),
        titlePadding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.02,
          left: MediaQuery.of(context).size.width * 0.05,
        ),
        title: Text(
          header,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        contentPadding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.02,
          left: MediaQuery.of(context).size.width * 0.05,
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            textColor: Config.secondColor,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            splashColor: Config.secondColor,
            child: Text(
              Config.cancelButtonPopup,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            textColor: Config.secondColor,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            splashColor: Config.secondColor,
            child: Text(
              Config.deleteButtonPopup,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context);
              showSendingProgressBar();
              _buildingBloc.add(DeleteBuilding(id: initBuilding.id));
            },
          ),
        ],
      ),
    );
  }

  void showImageDialog() async {
    switch (await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Container(
              child: Text(
                "Store image",
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                ),
              ),
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, PictureOption.OpenCamera);
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.photo_camera,
                      color: Config.secondColor,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02,
                      ),
                      child: Text("Take a photo"),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, PictureOption.OpenGallery);
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.photo_library,
                      color: Config.secondColor,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02,
                      ),
                      child: Text("Take from gallery"),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, PictureOption.RemovePicture);
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.delete,
                      color: Config.secondColor,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02,
                      ),
                      child: Text("Remove image"),
                    ),
                  ],
                ),
              ),
            ],
          );
        })) {
      case PictureOption.OpenCamera:
        _openCamera();
        break;
      case PictureOption.OpenGallery:
        _openGallery();
        break;
      case PictureOption.RemovePicture:
        _removeImage();
        break;
    }
  }

  void showUpdateBuildingDialog(String header, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width * 0.01),),
        ),
        titlePadding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.02,
          left: MediaQuery.of(context).size.width * 0.05,
        ),
        title: Text(
          header,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        contentPadding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.02,
          left: MediaQuery.of(context).size.width * 0.05,
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            textColor: Config.secondColor,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            splashColor: Config.secondColor,
            child: Text(
              Config.cancelButtonPopup,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          FlatButton(
            textColor: Config.secondColor,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            splashColor: Config.secondColor,
            child: Text(
              Config.updateButtonPopup,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context, true);
              showSendingProgressBar();
              updateBuilding();
            },
          ),
        ],
      ),
    );
  }

  void showFloorDialog() async {
    switch (await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Container(
              child: Text(
                "Select...",
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                ),
              ),
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, FloorOption.AddFloor);
                },
                child: Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.02,
                  ),
                  child: Text("Add floor"),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, FloorOption.AddBasement);
                },
                child: Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.02,
                  ),
                  child: Text("Add basement"),
                ),
              ),
            ],
          );
        })) {
      case FloorOption.AddFloor:
        goToCreateFloorPage(true);
        break;
      case FloorOption.AddBasement:
        goToCreateFloorPage(false);
        break;
    }
  }
}
