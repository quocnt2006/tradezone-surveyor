import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geodesy/geodesy.dart';
import 'package:osm_map_surveyor/behaviorsubject/building_behavior.dart';
import 'package:osm_map_surveyor/bloc/building_bloc.dart';
import 'package:osm_map_surveyor/events/building_event.dart';
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/models/buildingpost.dart';
import 'package:osm_map_surveyor/models/buildingtypes.dart';
import 'package:osm_map_surveyor/models/campus.dart';
import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/models/streetsegment.dart';
import 'package:osm_map_surveyor/repositories/building_repository.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/building/buiding_map.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/states/building_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osm_map_surveyor/utilities/geolocator_utils.dart';
import 'package:osm_map_surveyor/utilities/progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PictureOption { OpenCamera, OpenGallery, RemovePicture }

class CreateBuildingScreen extends StatefulWidget {
  final String sharePreferenceId;
  final Building initBuilding;
  final LatLng systemZoneCenter;
  CreateBuildingScreen({Key key, this.sharePreferenceId, this.initBuilding, this.systemZoneCenter}) : super(key: key);

  @override
  _CreateBuildingScreenState createState() => _CreateBuildingScreenState(this.sharePreferenceId, this.initBuilding, this.systemZoneCenter);
}

class _CreateBuildingScreenState extends State<CreateBuildingScreen> {
  String sharePreferenceId;
  Building initBuilding;
  LatLng systemZoneCenter;
  _CreateBuildingScreenState(this.sharePreferenceId, this.initBuilding, this.systemZoneCenter);

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
  FocusNode nameNode;
  FocusNode addressNode;
  List<BuildingType> listBuildingTypes;
  List<String> listBuildingTypeNames;

  BuildingBehavior _buildingBehavior = BuildingBehavior();
  BuildingBloc _buildingBloc;
  bool _isShowStreetSegments = false;
  bool _isBuildingGeom = false;
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
    initListBuildingType();
    initBuildingFunction();
  }
  
  void initListBuildingType() {
    setState(() {
      listBuildingTypes = initListBuildingTypes.toList();
      listBuildingTypeNames= initListBuildingTypeNames.toList();
      dropdownTypesValue = listBuildingTypeNames[0].toString();
    });
  }

  void initBuildingFunction() async {
    if (sharePreferenceId != null && initBuilding != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        imageUrl = initBuilding.imageUrl;
        _imageController = imageUrl;
        _buildingBehavior.imageBuildingSink.add(_imageController);
        _nameTextController.text = initBuilding.name;
        _buildingBehavior.nameBuildingSink.add(_nameTextController.text);
        _addressTextController.text = initBuilding.address;
        _buildingBehavior.addressBuildingSink.add(_addressTextController.text);
        String listStreetSegmentPrefsId = prefs.get(Config.draftBuildingStreetSegment + sharePreferenceId);
        if (listStreetSegmentPrefsId != null) {
          listStreetSegments = ListStreetSegments.fromJson(jsonDecode(listStreetSegmentPrefsId));
          _streetsegmentController = "true";
          _buildingBehavior.streetSegmentSink.add(_streetsegmentController);
        }
        String listBuildingPolygonPointsPrefsId = prefs.get(Config.draftBuildingPolygonPoints + sharePreferenceId);
        if (listBuildingPolygonPointsPrefsId != null) {
          List<dynamic> listBuildingPointsPrefs = jsonDecode(listBuildingPolygonPointsPrefsId);
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
        dropdownTypesValue = initBuilding.type.toString();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameTextController.dispose();
    _buildingBehavior.dispose();
    _buildingBloc.close();
    nameNode.dispose();
    addressNode.dispose();
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
      iconTheme: IconThemeData(
        color: Config.iconThemeColor,
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: MediaQuery.of(context).size.height * 0.025,
        ), 
        onPressed: () {
          Navigator.pop(context);
        }
      ),
      backgroundColor: Config.secondColor,
      title: Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Create building',
                style: TextStyle(
                  fontSize: Config.textSizeMedium,
                  color: Colors.white,
                ),
              ),
            ),
            if (sharePreferenceId != null && initBuilding != null)
              IconButton(
                icon: Icon(
                  Icons.delete_forever,
                  size: MediaQuery.of(context).size.width * 0.075,
                ),
                onPressed: () {
                  showDeleteDraftBuildingDialog(
                    Config.deleteDraftBuildingHeader,
                    Config.deleteDraftBuildingMessage,
                    context
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
    return ListView(
      children: <Widget>[
        detailBuildingWidget(context),
        footerWidget(context),
        blocListenerWidget(),
      ],
    );
  }

  Widget blocListenerWidget() {
    return BlocListener(
      bloc: _buildingBloc,
      listener: (BuildContext context, BuildingState state) {
        if (state is AddBuildingSucessState) {
          removeDraftBuilding();
          hideSendingProgressBar();
          Navigator.pop(context, [true, false]);
        }
      },
      child: SizedBox(),
    );
  }

  Widget detailBuildingWidget(BuildContext context) {
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
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.01,
      ),
      child: ListView(
        children: <Widget>[
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
          listStreetSegmentsButton(context),
          listStreetSegmentsWidget(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
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
              Row(
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
                    onPressed: () {
                      showImageDialog();
                    },
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
          Container(
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
          ),
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
                Container(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  RaisedButton(
                    onPressed: () {
                      goToMapPage();
                    },
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
                width: MediaQuery.of(context).size.width,
                child: snapshot.data != null
                  ? Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05,
                      top: MediaQuery.of(context).size.height * 0.01,
                    ),
                    child: Text(
                      snapshot.data,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: Config.textSizeSmall,
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
                    fontSize: Config.textSizeSuperSmall * 1.2,
                    color: Colors.black54,
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
          Container(
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
          ),
        ],
      ),
    );
  }

  Widget listStreetSegmentsButton(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.01,
            ),
            width: MediaQuery.of(context).size.width,
            color: Config.secondColor.withOpacity(0.54),
            height: MediaQuery.of(context).size.height * 0.001,
          ),
          FlatButton(
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
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 1.25,
                    offset: Offset(1, 2),
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
                    child: listStreetSegments != null ? 
                      Text(
                        listStreetSegments.listStreetSegment.length.toString() + 
                          (listStreetSegments.listStreetSegment.length < 2 ? 
                            " street segment" : " street segments")
                      )
                      : Text('0 street segment'),
                  ),
                  _isShowStreetSegments ? 
                    Icon(
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
          )
        ],
      ),
    );
  }

  Widget listStreetSegmentsWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(),
      child: _isShowStreetSegments ?
        Column(
          children: <Widget>[
            if (listStreetSegments != null)
              for (var streetsegment in listStreetSegments.listStreetSegment)
                if (streetsegment.name != null) streetSegmentWidget(context, streetsegment),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                if (listStreetSegments == null) Container(child: Text("No segment available")),
          ],
        )
        : SizedBox(),
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
        height: MediaQuery.of(context).size.height * 0.05,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              width: MediaQuery.of(context).size.width * 0.002,
              color: Config.secondColor),
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 1.25,
              offset: Offset(1, 2),
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(streetSegment.id.toString()),
                    streetSegment.name.length > 17 ? 
                      Text(streetSegment.name.substring(0, 17) + "...")
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
          saveDraftButton(context),
          createButton(context),
        ],
      ),
    );
  }

  Widget saveDraftButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.49,
      height: MediaQuery.of(context).size.height * 0.065,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: StreamBuilder(
        stream: _buildingBehavior.nameBuildingStream,
        builder: (context, snapshot) {
        return RaisedButton(
          onPressed: snapshot.data == null
            ? () {
              showDraftBuildingDialog(Config.saveDraftBuildingHeader, Config.saveDraftBuildingMessage, context);
            }
            : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
          ),
          color: Config.secondColor,
          disabledColor: Config.secondColor.withOpacity(0.5),
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.1,
                child: SvgPicture.asset(
                  Config.draftSvgIcon,
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
              ),
              Text(
                "Save draft",
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },),
    );
  }

  Widget createButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.49,
      height: MediaQuery.of(context).size.height * 0.065,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: StreamBuilder(
        stream: _buildingBehavior.submitBuildingStream,
        builder: (context, snapshot) {
          return RaisedButton(
            onPressed: snapshot.data == true ? 
              () {
                showAddBuildingDialog(Config.addBuildingHeader, Config.addBuildingMessage, context);
              }
              : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
            ),
            color: Config.secondColor,
            disabledColor: Config.secondColor.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Icon(
                    Icons.add_circle,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                ),
                Text(
                  "Create",
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

  showAddBuildingDialog(String header, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(MediaQuery.of(context).size.width * 0.01),
          ),
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
              Config.createButtonPopup,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context);
              showSendingProgressBar();
              addBuilding();
            },
          ),
        ],
      ),
    );
  }

  showDeleteDraftBuildingDialog(
      String header, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(MediaQuery.of(context).size.width * 0.01),
          ),
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
              removeDraftBuilding();
              Navigator.pop(context, [false, true]);
            },
          ),
        ],
      ),
    );
  }

  showDraftBuildingDialog(String header, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(MediaQuery.of(context).size.width * 0.01),
          ),
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
              Config.saveButtonPopup,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context);
              showSendingProgressBar();
              saveDraft();
            },
          ),
        ],
      ),
    );
  }

  void saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    var i = 1;
    bool isFound = false;
    String buildingStr;
    if (sharePreferenceId != null) {
      String saveDraftBuildingPrefsId = Config.draftBuilding + sharePreferenceId;
      String saveDraftBuildingStreetSegmentsPrefsId = Config.draftBuildingStreetSegment + sharePreferenceId;
      String saveDraftBuildingPolygonPointsPrefsId = Config.draftBuildingPolygonPoints + sharePreferenceId;
      isFound = true;
      Building building = new Building();
      building.name = _nameTextController.text;
      building.address = _addressTextController.text;
      building.active = true;
      if (_campus != null && _campus.id != -1) {
        building.campusId = _campus.id;
      }

      building.numberOfFloor = 1;
      if (_buildingPolygonPoints.length != 0) {
        List<List<double>> listBuildingPointsPrefs = [];
        for (var point in _buildingPolygonPoints) {
          listBuildingPointsPrefs.add([point.latitude, point.longitude]);
        }
        prefs.setString(saveDraftBuildingPolygonPointsPrefsId, jsonEncode(listBuildingPointsPrefs));
        building.coordinateString = geomBuilding;
      }
      building.type = dropdownTypesValue.toString();
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
    } else {
      while (!isFound) {
        buildingStr = prefs.get(Config.draftBuilding + i.toString());
        if (buildingStr != null) {
          i += 1;
        } else {
          isFound = true;
          String saveDraftBuildingPrefsId = Config.draftBuilding + i.toString();
          String saveDraftBuildingStreetSegmentsPrefsId = Config.draftBuildingStreetSegment + i.toString();
          String saveDraftBuildingPolygonPointsPrefsId = Config.draftBuildingPolygonPoints + i.toString();
          Building building = new Building();
          building.name = _nameTextController.text;
          building.address = _addressTextController.text;
          building.active = true;
          building.campusId = null;
          building.numberOfFloor = 1;

          if (_buildingPolygonPoints.length != 0) {
            List<List<double>> listBuildingPointsPrefs = [];
            for (var point in _buildingPolygonPoints) {
              listBuildingPointsPrefs.add([point.latitude, point.longitude]);
            }
            prefs.setString(saveDraftBuildingPolygonPointsPrefsId, jsonEncode(listBuildingPointsPrefs));
            building.coordinateString = geomBuilding;
          }
          building.type = dropdownTypesValue.toString();
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
      }
    }
  }

  void addBuilding () {
    BuildingPost building = new BuildingPost();
    building.name = _nameTextController.text.trim().toString();
    building.address = _addressTextController.text.trim().toString();
    building.active = true;
    if (_campus != null && _campus.id != -1) {
      building.campusId = _campus.id;
    }
    building.numberOfFloor = 1;
    building.coordinateString = geomBuilding;
    if (listBuildingTypes != null) {
      listBuildingTypes.forEach((type) { 
        if (type.name == dropdownTypesValue) {
          building.type = type.id;
        }
      });
    }
    List<int> streetSegmentIds = [];
    for (var streetSegment in listStreetSegments.listStreetSegment)
      streetSegmentIds.add(streetSegment.id);
    building.streetSegmentIds = streetSegmentIds;
    if (imageUrl == null) {
      uploadImage(imageFile, building);
    } else {
      building.imageUrl = imageUrl;
      _buildingBloc.add(AddBuilding(building: building));
    }
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

  void resetGeomBuilding() {
    setState(() {
      geomBuilding = null;
      _geomController = null;
      _buildingBehavior.geomBuildingSink.add(_geomController);
      _isBuildingGeom = false;
      listStreetSegments = null;
    });
  }

  void uploadImage(var imageFile, BuildingPost building) async {
    StorageReference ref = _storage.ref().child("images/${DateTime.now()}.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    building.imageUrl = dowurl.toString();
    _buildingBloc.add(AddBuilding(building: building));
  }

  dynamic uploadImageDraft(var imageFile) async {
    StorageReference ref = _storage.ref().child("images/${DateTime.now()}.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    return dowurl.toString();
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
        _addressTextController.text = rs[2].toString();
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

  void removeStreetSegment(StreetSegment streetSegment) {
    setState(() {
      listStreetSegments.listStreetSegment.remove(streetSegment);
      if (listStreetSegments.listStreetSegment.isEmpty) {
        _streetsegmentController = null;
        _buildingBehavior.streetSegmentSink.add(_streetsegmentController);
      }
    });
  }

  void showSendingProgressBar() {
    _progressBar.show(context);
  }

  void hideSendingProgressBar() {
    _progressBar.hide();
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

  void removeDraftBuilding() async {
    if (sharePreferenceId != null) {
      final prefs = await SharedPreferences.getInstance();
      var i = int.parse(sharePreferenceId) + 1;
      var isNotFound = false;
      while (!isNotFound) {
        String buildingStr = prefs.get(Config.draftBuilding + i.toString());
        if (buildingStr == null) {
          if (i == int.parse(sharePreferenceId) + 1) {
            prefs.remove(Config.draftBuilding + sharePreferenceId);
            prefs.remove(Config.draftBuildingPolygonPoints + sharePreferenceId);
            prefs.remove(Config.draftBuildingStreetSegment + sharePreferenceId);
            isNotFound = true;
          } else {
            prefs.remove(Config.draftBuilding + (i - 1).toString());
            prefs.remove(Config.draftBuildingPolygonPoints + (i - 1).toString());
            prefs.remove(Config.draftBuildingStreetSegment + (i - 1).toString());
            isNotFound = true;
          }
        } else {
          prefs.setString(Config.draftBuilding + (i - 1).toString(), buildingStr);
          i += 1;
        }
      }
    }
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
      },
    )) {
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
}
