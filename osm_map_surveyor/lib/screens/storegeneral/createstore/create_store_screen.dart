import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geodesy/geodesy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osm_map_surveyor/behaviorsubject/store_behavior.dart';
import 'package:osm_map_surveyor/bloc/store_bloc.dart';
import 'package:osm_map_surveyor/events/store_event.dart';
import 'package:osm_map_surveyor/models/brand.dart';
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/models/floor.dart';
import 'package:osm_map_surveyor/models/floorarea.dart';
import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/models/store.dart';
import 'package:osm_map_surveyor/models/storepost.dart';
import 'package:osm_map_surveyor/models/streetsegment.dart';
import 'package:osm_map_surveyor/repositories/store_repository.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/screens/storegeneral/store/store_map.dart';
import 'package:osm_map_surveyor/states/store_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/geolocator_utils.dart';
import 'package:osm_map_surveyor/utilities/progress_bar.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PictureOption { OpenCamera, OpenGallery, RemovePicture }

class CreateStoreScreen extends StatefulWidget {
  final String sharePreferenceId;
  final Store initStore;
  final LatLng systemZoneCenter;
  CreateStoreScreen({Key key, this.sharePreferenceId, this.initStore, this.systemZoneCenter}) : super(key: key);

  @override
  _CreateStoreScreenState createState() => _CreateStoreScreenState(this.sharePreferenceId, this.initStore, this.systemZoneCenter);
}
class _CreateStoreScreenState extends State<CreateStoreScreen> {
  String sharePreferenceId;
  Store initStore;
  LatLng systemZoneCenter;
  _CreateStoreScreenState(this.sharePreferenceId, this.initStore, this.systemZoneCenter);

  static final String firstTimeSlot = '0h - 6h';
  static final String secondTimeSlot = '6h - 12h';
  static final String thirdTimeSlot = '12h - 18h';
  static final String fourthTimeSlot = '18h - 24h';

  final _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: Config.storageBucket);

  File imageFile;
  String imageUrl;
  String openTimeText;
  String closeTimeText;
  String dropdownBrandValue;
  String dropdownBuildingNameValue;
  String dropdownFloorNameValue;
  String dropdownFloorAreaNameValue;
  String geomStore;
  String timeSlotShowText;
  List<String> listBrandNames;
  List<String> listBuildingNames;
  List<String> listBuildingFloorNames;
  List<String> listFloorAreasNames;
  List<Building> listBuildings;
  List<Brand> listBrands;
  List<Floor> listBuildingFloors;
  List<FloorArea> listBuildingFloorAreas;
  List<String> listTimeSlot;
  List<String> listSelectedTimeSlot;
  ListStreetSegments listStreetSegments;

  StoreBloc _storeBloc;
  StoreBehavior _storeBehavior = StoreBehavior();
  String _imageController;
  String _geomController;
  String _timeSlotFormat;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _abilityToServeController = TextEditingController();
  bool _isStoreGeom = false;
  bool _isInBuilding = false;
  bool _isShowStreetSegments = false;
  LatLng _storePoint; 
  ProgressBar _progressBar;

  @override
  void initState() {
    super.initState();
    _storeBloc = StoreBloc(storeRepository: StoreRepository());
    _storeBehavior.imageStoreSink.add(_imageController);
    _nameController.addListener(() {
      _storeBehavior.nameStoreSink.add(_nameController.text);
    });
    _storeBehavior.nameStoreSink.add(_nameController.text);
    _addressController.addListener(() {
      _storeBehavior.addressStoreSink.add(_addressController.text);
    });
    _storeBehavior.geomStoreSink.add(_geomController);
    _abilityToServeController.addListener(() {
      _storeBehavior.abilityToServeSink.add(_abilityToServeController.text);
    });
    listTimeSlot = <String>[
      firstTimeSlot,
      secondTimeSlot,
      thirdTimeSlot,
      fourthTimeSlot
    ];
    timeSlotShowText = "";
    listSelectedTimeSlot = new List<String>();
    getListBuildingNearly();
    setInitStore();
    initBrands();
    _progressBar = ProgressBar();
  }

  void initBrands() {
    setState(() {
      if (listBrands == null) {
        listBrands = new List<Brand>();
      }
      listBrands = initListBrands.toList();
      listBrandNames = new List<String>();
      listBrandNames = initListBrandNames.toList();
      if (dropdownBrandValue == null) {
        dropdownBrandValue = listBrands[0].name.toString();
      } else {
        if (dropdownBrandValue.isEmpty) {
          dropdownBrandValue = listBrands[0].name.toString();
        }
      }
    });
  }

  void initListBuilding(List<Building> buildings, List<String> buildingnames) {
    setState(() {
      if (listBuildings == null) {
        listBuildings = <Building>[];
      }
      if (buildings != null) {
        if (buildings.length > 0) {
          listBuildings = buildings.toList();
          if (listBuildingNames == null) {
            listBuildingNames = <String>[];
          }
          listBuildingNames = buildingnames.toList();
          if (dropdownBuildingNameValue == null) {
              dropdownBuildingNameValue = listBuildingNames[0].toString();
          } else {
            if (dropdownBuildingNameValue.isEmpty) {
              dropdownBuildingNameValue = listBuildingNames[0].toString();
            }
          }

          if (initStore != null) {
            if (initStore.floorAreaId != null) {
              onInitFloorArea();
            } else {
              int id = int.parse(dropdownBuildingNameValue.split(' ')[0]);
              onChangeBuilding(id);
            }
          } else {
            int id = int.parse(dropdownBuildingNameValue.split(' ')[0]);
            onChangeBuilding(id);
          }
        }
      }
    });
  }


  void setInitStore() async {
    if (sharePreferenceId != null && initStore != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        imageUrl = initStore.imageUrl;
        _imageController = imageUrl;
        _storeBehavior.imageStoreSink.add(_imageController);
        _nameController.text = initStore.name;
        _storeBehavior.nameStoreSink.add(_nameController.text);
        timeSlotShowText = "";
        _timeSlotFormat = "";
        if(initStore.timeSlot != null) {
          if (int.parse(initStore.timeSlot) % 10000 >= 1000) {
            timeSlotShowText = firstTimeSlot;
            _timeSlotFormat += '1';
          } else {
            _timeSlotFormat += '0';
          } 
          if (int.parse(initStore.timeSlot) % 1000 >= 100) {
            if (timeSlotShowText.trim().isEmpty) {
              timeSlotShowText = secondTimeSlot;
            } else {
              timeSlotShowText += " " + secondTimeSlot;
            }
            _timeSlotFormat += '1';
          } else {
            _timeSlotFormat += '0';
          } 
          if (int.parse(initStore.timeSlot) % 100 >= 10) {
            if (timeSlotShowText.trim().isEmpty) {
              timeSlotShowText = thirdTimeSlot;
            } else {
              timeSlotShowText += " " + thirdTimeSlot;
            }
            _timeSlotFormat += '1';
          } else {
            _timeSlotFormat += '0';
          } 
          if (int.parse(initStore.timeSlot) % 10 >= 1) {
            if (timeSlotShowText.trim().isEmpty) {
              timeSlotShowText = fourthTimeSlot;
            } else {
              timeSlotShowText += " " + fourthTimeSlot;
            }
            _timeSlotFormat += '1';
          } else {
            _timeSlotFormat += '0';
          } 
        } else {
          _timeSlotFormat = '0';
        }
        if (int.parse(_timeSlotFormat) == 0) {
          timeSlotShowText = "";
          _storeBehavior.timeSlotSink.add(_timeSlotFormat);
        } else {
          _storeBehavior.timeSlotSink.add(_timeSlotFormat);
        }
        if (initStore.abilityToServe != null) {
          _abilityToServeController.text = initStore.abilityToServe.toString();
        }
        _storeBehavior.abilityToServeSink.add(_abilityToServeController.text);
        _addressController.text = initStore.address;
        _storeBehavior.addressStoreSink.add(_addressController.text);
        String listStreetSegmentPrefsId = prefs.get(Config.draftStoreStreetSegment + sharePreferenceId);
        if (listStreetSegmentPrefsId != null) {
          listStreetSegments = ListStreetSegments.fromJson(jsonDecode(listStreetSegmentPrefsId));
        }
        String listStorePointPrefsId = prefs.get(Config.draftStorePolygonPoint + sharePreferenceId);
        if (listStorePointPrefsId != null) {
          dynamic latLngPoint = jsonDecode(listStorePointPrefsId);
          _storePoint = new LatLng(latLngPoint[0], latLngPoint[1]);
          _isStoreGeom = true;
          _geomController = _storePoint.toString();
          _storeBehavior.geomStoreSink.add(_geomController);
        }
        dropdownBrandValue = initStore.brandName;
      });
    }
  }

  void getListBuildingNearly() async {
    LatLng point;
    dynamic rs = await getCurrentLocation();
    point = new LatLng(rs.latitude, rs.longitude);
    _storeBloc.add(LoadListStoreBuildings(point: point));
  }

  @override
  void dispose() {
    _storeBehavior.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(context),
      body: body(context),
    );
  }

  Widget appBar(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: Config.iconThemeColor,
      ),
      backgroundColor: Config.secondColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ), 
      title: Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Create store',
                style: TextStyle(
                  fontSize: Config.textSizeMedium,
                  color: Colors.white,
                ),
              ),
            ),
            if (sharePreferenceId != null && initStore != null)
              IconButton(
                icon: Icon(
                  Icons.delete_forever,
                  size: MediaQuery.of(context).size.width * 0.075,
                ),
                onPressed: () {
                  showDeleteDraftStoreDialog(
                    Config.deleteDraftStoreHeader,
                    Config.deleteDraftStoreMessage,
                    context
                  );
                },
              )
          ],
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
    return ListView(
      children: <Widget>[
        detailStoreWidget(context),
        footerWidget(context),
        blocListenerWidget(),
      ],
    );
  }

  Widget blocListenerWidget() {
    return MultiBlocListener(
      listeners: [
        storeBlocListener(),
      ],
      child: SizedBox(),
    );
  }

  Widget storeBlocListener() {
    return BlocListener(
      bloc: _storeBloc,
      listener: (BuildContext context,StoreState state) {
        if (state is AddStoreSucessState) {
          removeDraftStore();
          hideSendingProgressBar();
          Navigator.pop(context, [true, false]);
        } else if (state is LoadListStoreBuildingsFinishState) {
          List<Building> buildings = new List<Building>();
          List<String> buildingnames = new List<String>();
          if (state.listBuildings != null) {
            buildings = state.listBuildings.toList();
            buildings.forEach((building) {
              buildingnames.add(building.id.toString() + ' ' + building.name.toString());
            });
          }
          initListBuilding(buildings, buildingnames);
        }
      },
    );
  }

  Widget detailStoreWidget(BuildContext context) {
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
          storeNameInputTextField(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
          imageZoneWidget(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
          timeSlotWidget(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
          abilityToServeWidget(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
          listBrandDropDownButton(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
          inputMapRowWidget(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
          storeAddressInputTextField(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
          inBuildingWidget(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
        ],
      ),
    );
  }

  Widget imageZoneWidget() {
    return StreamBuilder(
      stream: _storeBehavior.imageStoreStream,
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

  Widget storeNameInputTextField(BuildContext context) {
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
              stream: _storeBehavior.nameStoreStream,
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
                    labelStyle: TextStyle(
                      color: Config.secondColor,
                      fontSize: Config.textSizeSuperSmall
                    ),
                    hintText: "Input the store name",
                    errorText: snapshot.data,
                  ),
                  controller: _nameController,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget timeSlotWidget(BuildContext context) {
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
            children: [
              Icon(
                Icons.access_time,
                color: Config.secondColor.withOpacity(0.54),
                size: Config.textSizeSuperSmall * 1.2,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
              Text(
                'Time slot',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
              RaisedButton(
                onPressed: () => showTimeSlotDialog(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.height * 0.05,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Icon(
                        Icons.timelapse_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                      Text(
                        "Select time slot",
                        style: TextStyle(
                          fontSize: Config.textSizeSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                color: Config.secondColor,
                disabledColor: Config.secondColor.withOpacity(0.5),
                textColor: Colors.white,
                disabledTextColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width * 0.02,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          Container(
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.05,
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              timeSlotShowText.trim().toString().isEmpty 
                ? "No time slot is chose"
                : timeSlotShowText.trim().toString(),
              style: TextStyle(
                color: Colors.black,
                fontSize: Config.textSizeSmall,
              )
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
        ],
      ),
    );
  }

  Widget abilityToServeWidget(BuildContext context) {
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
                  Icons.analytics_rounded,
                  color: Config.secondColor.withOpacity(0.54),
                  size: Config.textSizeSuperSmall * 1.2,
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                Text(
                  'Ability to serve',
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
              stream: _storeBehavior.abilityToServeStream,
              builder: (context, snapshot) {
                return TextField(
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
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
                    hintText: "Input the ability to serve",
                    errorText: snapshot.data,
                  ),
                  controller: _abilityToServeController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget listBrandDropDownButton(BuildContext context) {
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
                'Brand',
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
          if (listBrandNames != null)
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
                      value: dropdownBrandValue,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white,),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Config.textSizeSmall * 0.8,
                      ),
                      dropdownColor: Config.secondColor,
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownBrandValue = newValue;
                        });
                      },
                      items: listBrandNames.map<DropdownMenuItem<String>>((String value) {
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

  Widget listBuildingNamesDropDownButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.06,
        right: MediaQuery.of(context).size.width * 0.05,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.07,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.04,
            ),
            child: SvgPicture.asset(
              Config.buildingSvgIcon,
              color: Config.secondColor,
              height: MediaQuery.of(context).size.width * 0.05,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.04,
            ),
            child: Text(
              'Building',
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            ),
          ),
          if (listBuildingNames != null && listBuildingNames.length > 0)
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.07,
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.0005,
                right: MediaQuery.of(context).size.width * 0.01,
                top: MediaQuery.of(context).size.height * 0.0075,
              ),
              child: DropdownButton<String>(
                underline: Container(
                  height: MediaQuery.of(context).size.height * 0.001,
                  color: Config.secondColor,
                ),
                isExpanded: true,
                value: dropdownBuildingNameValue,
                icon: Icon(Icons.arrow_drop_down),
                style: TextStyle(color: Colors.black),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownBuildingNameValue = newValue;
                    int id = int.parse(dropdownBuildingNameValue.split(' ')[0]);
                    onChangeBuilding(id);
                  });
                },
                items: listBuildingNames.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.substring(value.indexOf(' ') + 1, value.length)),
                  );
                }).toList(),
              ),
            ),
          if (listBuildingNames == null)
            CircularProgressIndicator(
              backgroundColor: Config.thirdColor,
              valueColor: AlwaysStoppedAnimation<Color>(Config.secondColor),
            ),
        ],
      ),
    );
  }

  Widget listFloorNamesDropDownButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.06,
        right: MediaQuery.of(context).size.width * 0.06,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.07,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.04,
            ),
            child: SvgPicture.asset(
              Config.floorSvgIcon,
              color: Config.secondColor,
              height: MediaQuery.of(context).size.width * 0.05,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.04,
            ),
            child: Text(
              'Floor',
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            ),
          ),
          if (listBuildingFloorNames != null && listBuildingFloorNames.length > 0)
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.07,
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.0005,
                right: MediaQuery.of(context).size.width * 0.01,
                top: MediaQuery.of(context).size.height * 0.0075,
              ),
              child: DropdownButton<String>(
                underline: Container(
                  height: MediaQuery.of(context).size.height * 0.001,
                  color: Config.secondColor,
                ),
                isExpanded: true,
                value: dropdownFloorNameValue,
                icon: Icon(Icons.arrow_drop_down),
                style: TextStyle(color: Colors.black),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownFloorNameValue = newValue;
                    int floorNumber = int.parse(dropdownFloorNameValue.split(' ')[1]);
                    onChangeFloor(floorNumber);
                  });
                },
                items: listBuildingFloorNames.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.split(' ')[0]),
                  );
                }).toList(),
              ),
            ),
          if (listBuildingFloorNames == null)
            CircularProgressIndicator(
              backgroundColor: Config.thirdColor,
              valueColor: AlwaysStoppedAnimation<Color>(Config.secondColor),
            ),
        ],
      ),
    );
  }

  Widget listFloorAreaNamesDropDownButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.06,
        right: MediaQuery.of(context).size.width * 0.05,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.07,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.04,
            ),
            child: SvgPicture.asset(
              Config.areaSvgIcon,
              color: Config.secondColor,
              height: MediaQuery.of(context).size.width * 0.05,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.04,
            ),
            child: Text(
              'Floor Area',
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            ),
          ),
          if (listFloorAreasNames != null && listFloorAreasNames.length > 0)
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.07,
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.0005,
                right: MediaQuery.of(context).size.width * 0.01,
                top: MediaQuery.of(context).size.height * 0.0075,
              ),
              child: DropdownButton<String>(
                underline: Container(
                  height: MediaQuery.of(context).size.height * 0.001,
                  color: Config.secondColor,
                ),
                isExpanded: true,
                value: dropdownFloorAreaNameValue,
                icon: Icon(Icons.arrow_drop_down),
                style: TextStyle(color: Colors.black),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownFloorAreaNameValue = newValue;
                  });
                },
                items: listFloorAreasNames.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.substring(value.indexOf(' ') + 1, value.length)),
                  );
                }).toList(),
              ),
            ),
          if (listBuildingFloorNames == null)
            CircularProgressIndicator(
              backgroundColor: Config.thirdColor,
              valueColor: AlwaysStoppedAnimation<Color>(Config.secondColor),
            ),
        ],
      ),
    );
  }

  Widget inBuildingWidget(BuildContext context) {
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
            width: MediaQuery.of(context).size.width,
            color: Config.secondColor.withOpacity(0.54),
            height: MediaQuery.of(context).size.height * 0.001,
          ),
          isInBuildingSwitchButton(context),
          if (!_isInBuilding) SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
          if (!_isInBuilding) listStreetSegmentsButton(context),
          if (!_isInBuilding) listStreetSegmentsWidget(context),
          if (_isInBuilding) SizedBox(height:  MediaQuery.of(context).size.height * 0.005,),
          if (_isInBuilding) listBuildingNames != null 
            ? listBuildingsWidget(context)
            : Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerLeft,
              child: Text(
                'No building nearly',
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget listBuildingsWidget(BuildContext context) {
    return Container(
      child: Column(
        children: [
          listBuildingNamesDropDownButton(context),
          if (listBuildingFloors != null) if (_isInBuilding && listBuildingFloors.length > 0) SizedBox(height:  MediaQuery.of(context).size.height * 0.005,),
          if (listBuildingFloors != null) if (_isInBuilding && listBuildingFloors.length > 0) listFloorNamesDropDownButton(context),
          if (listBuildingFloorAreas != null) if (_isInBuilding && listBuildingFloorAreas.length > 0) SizedBox(height:  MediaQuery.of(context).size.height * 0.005,),
          if (listBuildingFloorAreas != null) if (_isInBuilding && listBuildingFloorAreas.length > 0) listFloorAreaNamesDropDownButton(context),
        ],
      ),
    );
  }

  Widget inputMapRowWidget(BuildContext context) {
    return StreamBuilder(
      stream: _storeBehavior.geomStoreStream,
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
                      'Store location',
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
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
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
                        fontSize: Config.textSizeSmall,
                      ),
                    ),
                  )
                  : Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05,
                      top: MediaQuery.of(context).size.height * 0.01,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Latitude : ' + _storePoint.latitude.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: Config.textSizeSmall,
                          ),
                        ),
                        Text(
                          'Longitude : ' + _storePoint.longitude.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: Config.textSizeSmall,
                          ),
                        ),
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

  Widget storeAddressInputTextField(BuildContext context) {
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
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                Text(
                  'Store address',
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
              stream: _storeBehavior.addressStoreStream,
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
                  controller: _addressController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget isInBuildingSwitchButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.005,
        left: MediaQuery.of(context).size.width * 0.06,
        right: MediaQuery.of(context).size.width * 0.05,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "In building",
            style: TextStyle(
              fontSize: Config.textSizeSmall,
              color: Colors.black,
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
          CupertinoSwitch(
            activeColor: Config.secondColor,
            value: _isInBuilding,
            onChanged: (value) {
              setState(() {
                _isInBuilding = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget checkBoxStore(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.18,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.035,
      ),
      child: CheckboxListTile(
        checkColor: Config.thirdColor,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Config.secondColor,
        value: _isStoreGeom,
        onChanged: (value) {},
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
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
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
                      (listStreetSegments.listStreetSegment.length < 2 ? " street segment" : " street segments")
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
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.01),
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
              child: SvgPicture.asset(Config.streetSegmentSvgIcon,),
            ),
            Expanded(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(streetSegment.id.toString()),
                    streetSegment.name.length > 17
                      ? Text(streetSegment.name.substring(0, 17) + "...")
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
                    color: Config.firstColor,
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
                icon: SvgPicture.asset(
                  Config.cancelSvgIcon,
                ),
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
          addButton(context),
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
        stream: _storeBehavior.nameStoreStream,
        builder: (context, snapshot) {
          return RaisedButton(
            onPressed: snapshot.data == null 
              ? () {
                showDraftStoreDialog(Config.saveDraftStoreHeader, Config.saveDraftStoreMessage, context);
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
        },
      ),
    );
  }

  Widget addButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.49,
      height: MediaQuery.of(context).size.height * 0.065,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: StreamBuilder(
        stream: _storeBehavior.submitStoreStream,
        builder: (context, snapshot) {
          return RaisedButton(
            onPressed: snapshot.data == true
              ? () {
                  showAddStoreDialog(Config.addStoreHeader, Config.addStoreMessage, context);
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

  void removeStreetSegment(StreetSegment streetSegment) {
    setState(() {
      listStreetSegments.listStreetSegment.remove(streetSegment);
    });
  }

  void goToMapPage() async {
    final rs = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => StoreMap(
          initPoint: _storePoint,
          centerPoint: systemZoneCenter,
        )
      )
    );
    if (rs != null) {
      if (rs[0] != null) {
        updateStoreGeom(rs[0]);
      }

      if (rs[1] != null) {
        listStreetSegments = new ListStreetSegments(listStreetSegment: rs[1].listStreetSegment.toList());
      }

      if (rs[2] != null) {
        _addressController.text = rs[2].toString();
      }
    }
  }

  void updateStoreGeom(LatLng point) {
    setState(() {
      _storePoint = new LatLng(point.latitude, point.longitude);
      _isStoreGeom = true;
      _geomController = _storePoint.toString();
      _storeBehavior.geomStoreSink.add(_geomController);
    });
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

  void onInitFloorArea() async {
    final prefs = await SharedPreferences.getInstance();
    String buildingIdStr = prefs.getString(Config.draftStoreBuildingId + sharePreferenceId);
    String floorNumberStr = prefs.getString(Config.draftStoreFloorNumber + sharePreferenceId);
    if (buildingIdStr != null && floorNumberStr != null) {
      int buildingId = int.parse(buildingIdStr);
      int floorNumberInt = int.parse(floorNumberStr);
      listBuildings.forEach((building) {
        if (building.id == buildingId) {
          dropdownBuildingNameValue = building.id.toString() + ' ' + building.name.toString();
          listBuildingFloors = new List<Floor>();
          listBuildingFloors = building.floors;
          if (listBuildingFloors.length > 0) {
            listBuildingFloorNames = new List<String>();
            listBuildingFloors.forEach((floor) {
              listBuildingFloorNames.add(floor.name + " " + floor.floorNumber.toString());
              if (floor.floorNumber == floorNumberInt) {
                dropdownFloorNameValue = floor.name + " " + floor.floorNumber.toString();
                listBuildingFloorAreas = new List<FloorArea>();
                listBuildingFloorAreas = floor.floorAreas;
                if (listBuildingFloorAreas.length > 0) {
                  listFloorAreasNames = new List<String>();
                  listBuildingFloorAreas.forEach((floorArea) {
                    listFloorAreasNames.add(floorArea.id.toString() + ' ' + floorArea.name.toString());
                    if (floorArea.id == initStore.floorAreaId) {
                      dropdownFloorAreaNameValue = floorArea.id.toString() + ' ' + floorArea.name.toString();
                    }
                  });
                }
              }
            });
            
          }
        }
      });
    }
  }

  void onChangeBuilding(int id) {
    setState(() {
      listBuildings.forEach((building) {
        if (building.id == id) {
          listBuildingFloors = new List<Floor>();
          listBuildingFloors = building.floors;
          if (listBuildingFloors.length > 0) {
            listBuildingFloorNames = new List<String>();
            listBuildingFloors.forEach((floor) {
              if (floor.floorAreas.length > 0) {
                listBuildingFloorNames.add(floor.name + " " + floor.floorNumber.toString());
              }
            });
            dropdownFloorNameValue = listBuildingFloorNames[0].toString();
            int floorNumber = int.parse(dropdownFloorNameValue.split(' ')[1]);
            onChangeFloor(floorNumber);
          } else {
            dropdownFloorNameValue = null;
            if (dropdownFloorAreaNameValue == null) {
              dropdownFloorAreaNameValue = null;
            }
          }
        }
      });
    });
  }

  void onChangeFloor(int floorNumber) {
    setState(() {
      listBuildingFloors.forEach((floor) { 
        if (floor.floorNumber == floorNumber) {
          listBuildingFloorAreas = new List<FloorArea>();
          listBuildingFloorAreas = floor.floorAreas;
          if (listBuildingFloorAreas.length > 0) {
            listFloorAreasNames = new List<String>();
            listBuildingFloorAreas.forEach((floorArea) {
              listFloorAreasNames.add(floorArea.id.toString() + ' ' + floorArea.name.toString());
            });
            dropdownFloorAreaNameValue = listFloorAreasNames[0];
          } else {
            dropdownFloorAreaNameValue = null;
          }
        }
      });
    });
  }

  // the function open camera to take a picture
  void _openCamera() async {
    final pickerFile = await _imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickerFile != null) {
        imageFile = File(pickerFile.path);
        _imageController = pickerFile.path;
        _storeBehavior.imageStoreSink.add(_imageController);
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
        _storeBehavior.imageStoreSink.add(_imageController);
      }
    });
  }

  // the function remove Image
  void _removeImage() {
    setState(() {
      imageFile = null;
      _imageController = null;
      _storeBehavior.imageStoreSink.add(_imageController);
    });
  }

  void saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    var i = 1;
    bool isFound = false;
    String storeStr;
    if (sharePreferenceId != null) {
      String saveDraftStorePrefsId = Config.draftStore + sharePreferenceId;
      String saveDraftStoreStreetSegmentsPrefsId = Config.draftStoreStreetSegment + sharePreferenceId;
      String saveDraftStorePolygonPointPrefsId = Config.draftStorePolygonPoint + sharePreferenceId;
      String saveDraftStoreBuildingId = Config.draftStoreBuildingId + sharePreferenceId;
      String saveDraftStoreFloorNumber = Config.draftStoreFloorNumber + sharePreferenceId;
      isFound = true;
      Store store = new Store();
      store.name = _nameController.text;
      store.address = _addressController.text;
      if (_storePoint != null) {
        List<double> storePointLatLng = [];
        storePointLatLng.add(_storePoint.latitude);
        storePointLatLng.add(_storePoint.longitude);
        prefs.setString(saveDraftStorePolygonPointPrefsId, jsonEncode(storePointLatLng));
      }
      if (listStreetSegments != null) {
        prefs.setString(saveDraftStoreStreetSegmentsPrefsId, jsonEncode(listStreetSegments));
      }
      if (dropdownBuildingNameValue != null) {
        prefs.setString(saveDraftStoreBuildingId, dropdownBuildingNameValue.split(' ')[0]);
      }
      if (dropdownFloorNameValue != null) {
        prefs.setString(saveDraftStoreFloorNumber, dropdownFloorNameValue.split(' ')[1]);
      }
      if (dropdownFloorAreaNameValue != null) {
        store.floorAreaId = int.parse(dropdownFloorAreaNameValue.split(' ')[0]);
        store.floorAreaName = dropdownFloorAreaNameValue.substring(dropdownFloorAreaNameValue.indexOf(' ') + 1, dropdownFloorAreaNameValue.length);
      }
      int flag = 0;
      for (int i = 0; i < listBrands.length && flag == 0; i++) {
        if (listBrands[i].name == dropdownBrandValue) {
          store.brandId = listBrands[i].id;
          store.brandName = listBrands[i].name;
          flag = 1;
        }
      }

      if (imageUrl == null) {
        if (imageFile != null) {
          store.imageUrl = await uploadImageDraft(imageFile);
        }
      } else {
        store.imageUrl = imageUrl;
      }
      prefs.setString(saveDraftStorePrefsId, jsonEncode(store));
      hideSendingProgressBar();
      Navigator.pop(context, [false, false]);
    } else {
      while (!isFound) {
        storeStr = prefs.get(Config.draftStore + i.toString());
        if (storeStr != null) {
          i += 1;
        } else {
          isFound = true;
          String saveDraftStorePrefsId = Config.draftStore + i.toString();
          String saveDraftStoreStreetSegmentsPrefsId = Config.draftStoreStreetSegment + i.toString();
          String saveDraftStorePolygonPointPrefsId = Config.draftStorePolygonPoint + i.toString();
          String saveDraftStoreBuildingId = Config.draftStoreBuildingId + i.toString();
          String saveDraftStoreFloorNumber = Config.draftStoreFloorNumber + i.toString();
          Store store = new Store();
          store.name = _nameController.text;
          store.address = _addressController.text;
          if (_storePoint != null) {
            List<double> storePointLatLng = [];
            storePointLatLng.add(_storePoint.latitude);
            storePointLatLng.add(_storePoint.longitude);
            prefs.setString(saveDraftStorePolygonPointPrefsId, jsonEncode(storePointLatLng));
          }
          if (listStreetSegments != null) {
            prefs.setString(saveDraftStoreStreetSegmentsPrefsId, jsonEncode(listStreetSegments));
          }
          if (dropdownBuildingNameValue != null) {
            prefs.setString(saveDraftStoreBuildingId, dropdownBuildingNameValue.split(' ')[0]);
          }
          if (dropdownFloorNameValue != null) {
            prefs.setString(saveDraftStoreFloorNumber, dropdownFloorNameValue.split(' ')[1]);
          }
          if (dropdownFloorAreaNameValue != null) {
            store.floorAreaId = int.parse(dropdownFloorAreaNameValue.split(' ')[0]);
            store.floorAreaName = dropdownFloorAreaNameValue.substring(dropdownFloorAreaNameValue.indexOf(' ') + 1, dropdownFloorAreaNameValue.length);
          }
          int flag = 0;
          for (int i = 0; i < listBrands.length && flag == 0; i++) {
            if (listBrands[i].name == dropdownBrandValue) {
              store.brandId = listBrands[i].id;
              store.brandName = listBrands[i].name;
              flag = 1;
            }
          }
          if (imageUrl == null) {
            if (imageFile != null) {
              store.imageUrl = await uploadImageDraft(imageFile);
            }
          } else {
            store.imageUrl = imageUrl;
          }
          prefs.setString(saveDraftStorePrefsId, jsonEncode(store));
          hideSendingProgressBar();
          Navigator.pop(context, [false, false]);
        }
      }
    }
  }

  dynamic uploadImageDraft(var imageFile) async {
    StorageReference ref = _storage.ref().child("images/${DateTime.now()}.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    return dowurl.toString();
  }

  void addStore() async {
    StorePost store = new StorePost();
    store.name = _nameController.text.trim().toString();
    store.timeSlot = _timeSlotFormat.toString();
    store.abilityToServe = int.parse(_abilityToServeController.text.trim().toString());
    int flag = 0;
    for (int i = 0; i < listBrands.length && flag == 0; i++) {
      if (listBrands[i].name == dropdownBrandValue) {
        store.brandId = listBrands[i].id;
        flag = 1;
      }
    }
    store.address = _addressController.text.toString();
    store.coordinateString = '${_storePoint.longitude} ${_storePoint.latitude}';
    if (_isInBuilding) {
      if (listFloorAreasNames != null) {
        if (listFloorAreasNames.length != 0 ) {
          if (dropdownFloorAreaNameValue != null) {
            store.floorAreaId = int.parse(dropdownFloorAreaNameValue.split(' ')[0]);
          }
        } else {
          store.streetSegmentIds = new List<int>();
          listStreetSegments.listStreetSegment.toList().forEach((streetsegment) { 
            store.streetSegmentIds.add(streetsegment.id);
          });
        }
      } else {
        store.streetSegmentIds = new List<int>();
        listStreetSegments.listStreetSegment.toList().forEach((streetsegment) { 
          store.streetSegmentIds.add(streetsegment.id);
        });
      }
    } else {
      store.streetSegmentIds = new List<int>();
      listStreetSegments.listStreetSegment.toList().forEach((streetsegment) { 
        store.streetSegmentIds.add(streetsegment.id);
      });
    }
    if (imageUrl == null) {
      uploadImage(imageFile, store);
    } else {
      store.imageUrl = imageUrl;
      _storeBloc.add(AddStore(store: store));
    }
  }

  void uploadImage(var imageFile, StorePost store) async {
    StorageReference ref = _storage.ref().child("images/${DateTime.now()}.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    store.imageUrl = dowurl.toString();
    _storeBloc.add(AddStore(store: store));
  }

  void removeDraftStore() async {
    if (sharePreferenceId != null) { 
      final prefs = await SharedPreferences.getInstance();
      var i = int.parse(sharePreferenceId) + 1;
      var isNotFound = false;
      while (!isNotFound) {
        String storeStr = prefs.get(Config.draftStore + i.toString());
        if (storeStr == null) {
          if (i == int.parse(sharePreferenceId) + 1) {
            prefs.remove(Config.draftStore + sharePreferenceId);
            prefs.remove(Config.draftStoreBuildingId + sharePreferenceId);
            prefs.remove(Config.draftStoreFloorNumber + sharePreferenceId);
            prefs.remove(Config.draftStorePolygonPoint + sharePreferenceId);
            prefs.remove(Config.draftStoreStreetSegment + sharePreferenceId);
            isNotFound = true;
          } else {
            prefs.remove(Config.draftStore + (i - 1).toString());
            prefs.remove(Config.draftStoreBuildingId + (i - 1).toString());
            prefs.remove(Config.draftStoreFloorNumber + (i - 1).toString());
            prefs.remove(Config.draftStorePolygonPoint + (i - 1).toString());
            prefs.remove(Config.draftStoreStreetSegment + (i - 1).toString());
            isNotFound = true;
          }
        } else {
          prefs.setString(Config.draftStore + (i - 1).toString(), storeStr);
          i += 1;
        }
      }
    }
  }

  void showSendingProgressBar() {
    _progressBar.show(context);
  }

  void hideSendingProgressBar() {
    _progressBar.hide();
  }

  showTimeErrorDialog(String header, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width * 0.01),
          ),
        ),
        titlePadding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.02,
          left: MediaQuery.of(context).size.width * 0.02,
        ),
        title: Center(
          child: Text(
            header,
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        contentPadding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.02,
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.02,
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
              Config.okButtonPopup,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  showDraftStoreDialog(String header, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width * 0.01),
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

  showAddStoreDialog(String header, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width * 0.01),
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
              Config.addButtonPopup,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context);
              showSendingProgressBar();
              addStore();
            },
          ),
        ],
      ),
    );
  }

  void showTimeSlotDialog() {
    List<String> tmp = new List<String>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Time slot"),
          content: Container(
            constraints: BoxConstraints(
              maxHeight: 100.0,
            ),
            child: SingleChildScrollView(
                child: MultiSelectChip(
                  listTimeSlot,
                  onSelectionChanged: (selectedList) {
                    setState(() {
                      tmp = selectedList.toList();
                    });
                  },
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  setState(() {
                    listSelectedTimeSlot = tmp.toList();
                    timeSlotShowText = "";
                    _timeSlotFormat = "";
                    if (listSelectedTimeSlot.contains(firstTimeSlot)) {
                      timeSlotShowText = firstTimeSlot;
                      _timeSlotFormat += '1';
                    } else {
                      _timeSlotFormat += '0';
                    } 
                    if (listSelectedTimeSlot.contains(secondTimeSlot)) {
                      if (timeSlotShowText.trim().isEmpty) {
                        timeSlotShowText = secondTimeSlot;
                      } else {
                        timeSlotShowText += " " + secondTimeSlot;
                      }
                      _timeSlotFormat += '1';
                    } else {
                      _timeSlotFormat += '0';
                    }
                    if (listSelectedTimeSlot.contains(thirdTimeSlot)) {
                      if (timeSlotShowText.trim().isEmpty) {
                        timeSlotShowText = thirdTimeSlot;
                      } else {
                        timeSlotShowText += " " + thirdTimeSlot;
                      }
                      _timeSlotFormat += '1';
                    } else {
                      _timeSlotFormat += '0';
                    }
                    if (listSelectedTimeSlot.contains(fourthTimeSlot)) {
                      if (timeSlotShowText.trim().isEmpty) {
                        timeSlotShowText = fourthTimeSlot;
                      } else {
                        timeSlotShowText += " " + fourthTimeSlot;
                      }
                      _timeSlotFormat += '1';
                    } else {
                      _timeSlotFormat += '0';
                    }
                    if (int.parse(_timeSlotFormat) == 0) {
                      timeSlotShowText = "";
                      _storeBehavior.timeSlotSink.add(_timeSlotFormat);
                    } else {
                      _storeBehavior.timeSlotSink.add(_timeSlotFormat);
                    }
                  });
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void showDeleteDraftStoreDialog(
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
              removeDraftStore();
              Navigator.pop(context, [false, true]);
            },
          ),
        ],
      ),
    );
  }
}
