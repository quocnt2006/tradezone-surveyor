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

class UpdateStoreScreen extends StatefulWidget {
  final int storeId;
  UpdateStoreScreen({Key key, this.storeId}) : super(key: key);

  @override
  _UpdateStoreScreenState createState() => _UpdateStoreScreenState(this.storeId);
}

class _UpdateStoreScreenState extends State<UpdateStoreScreen> {
  int storeId;
  _UpdateStoreScreenState(this.storeId);

  static final String firstTimeSlot = '0h - 6h';
  static final String secondTimeSlot = '6h - 12h';
  static final String thirdTimeSlot = '12h - 18h';
  static final String fourthTimeSlot = '18h - 24h';

  final _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: Config.storageBucket);

  Store initStore;
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
  String _buildingName;
  String _floorName;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _abilityToServeController = TextEditingController();
  bool _isStoreGeom = false;
  bool _isInBuilding = false;
  bool _isShowStreetSegments = false;
  bool _isLoadListStreetSegmentsByStoreId = false;
  bool _isInitLoadSuccess = false;
  bool _isSaveDraft = false;
  bool _isLoadStore = false;
  LatLng _storePoint; 
  ProgressBar _progressBar;

  @override
  void initState() {
    super.initState();
    _progressBar = ProgressBar();
    _storeBloc = StoreBloc(storeRepository: StoreRepository());
    _storeBloc.add(LoadStoreById(id: storeId));
    _storeBehavior.imageStoreSink.add(_imageController);
    _nameController.addListener(() {
      _storeBehavior.nameStoreSink.add(_nameController.text);
    });
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
          if (buildingnames.length > 0) {
            listBuildingNames = buildingnames.toList();
          }
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

  void initStoreFunction() async {
    setState(() {
      imageUrl = initStore.imageUrl;
      _imageController = imageUrl;
      _storeBehavior.imageStoreSink.add(_imageController);
      _nameController.text = initStore.name;
      _storeBehavior.nameStoreSink.add(_nameController.text);
      if (initStore.timeSlot != null) {
        timeSlotShowText = "";
        _timeSlotFormat = "";
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
        if (int.parse(_timeSlotFormat) == 0) {
          timeSlotShowText = "";
          _storeBehavior.timeSlotSink.add(_timeSlotFormat);
        } else {
          _storeBehavior.timeSlotSink.add(_timeSlotFormat);
        }
      }
      if (initStore.abilityToServe != null) {
        _abilityToServeController.text = initStore.abilityToServe.toString();
      }
      _storeBehavior.abilityToServeSink.add(_abilityToServeController.text);
      _addressController.text = initStore.address;
      _storeBehavior.addressStoreSink.add(_addressController.text);
      if (initStore.coordinateString != null) {
        String coordinate = initStore.coordinateString.toString();
        coordinate = coordinate.replaceAll('"', '').toString();
        dynamic latLngPoint = jsonDecode(coordinate);
        double longitudeTmp = latLngPoint[0];
        double latitudeTmp = latLngPoint[1];
        _storePoint = new LatLng(latitudeTmp, longitudeTmp);
        _isStoreGeom = true;
        _geomController = _storePoint.toString();
        _storeBehavior.geomStoreSink.add(_geomController);
      }
      dropdownBrandValue = initStore.brandName;
    });
  }

  void checkSaveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    String storePrefs = prefs.getString(Config.draftUpdateStore + storeId.toString());
    if (storePrefs != null) {
      _isSaveDraft = true;
    }
  }

  void initDraftStore() async {
    final prefs = await SharedPreferences.getInstance();
    String storePrefs = prefs.getString(Config.draftUpdateStore + storeId.toString());
    setState(() {
      if (storeId.toString() != null && initStore != null) {
        Store tmp = Store.fromJson(jsonDecode(storePrefs));
        setState(() {
          imageUrl = tmp.imageUrl;
          _imageController = imageUrl;
          _storeBehavior.imageStoreSink.add(_imageController);
          _nameController.text = tmp.name;
          _storeBehavior.nameStoreSink.add(_nameController.text);
          if (tmp.timeSlot != null) {
            _timeSlotFormat = '';
            timeSlotShowText = '';
            if (int.parse(tmp.timeSlot) % 10000 >= 1000) {
              timeSlotShowText = firstTimeSlot;
              _timeSlotFormat += '1';
            } else {
              _timeSlotFormat += '0';
            } 
            if (int.parse(tmp.timeSlot) % 1000 >= 100) {
              if (timeSlotShowText.trim().isEmpty) {
                timeSlotShowText = secondTimeSlot;
              } else {
                timeSlotShowText += " " + secondTimeSlot;
              }
              _timeSlotFormat += '1';
            } else {
              _timeSlotFormat += '0';
            }   
            if (int.parse(tmp.timeSlot) % 100 >= 10) {
              if (timeSlotShowText.trim().isEmpty) {
                timeSlotShowText = thirdTimeSlot;
              } else {
                timeSlotShowText += " " + thirdTimeSlot;
              }
              _timeSlotFormat += '1';
            } else {
              _timeSlotFormat += '0';
            } 
            if (int.parse(tmp.timeSlot) % 10 >= 1) {
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
          }
          if (tmp.abilityToServe != null) {
            _abilityToServeController.text = tmp.abilityToServe.toString();
          }
          _storeBehavior.abilityToServeSink.add(_abilityToServeController.text);
          _addressController.text = tmp.address;
          _storeBehavior.addressStoreSink.add(_addressController.text);
          String listStreetSegmentPrefsId = prefs.get(Config.draftUpdateStoreStreetSegment + storeId.toString());
          if (listStreetSegmentPrefsId != null) {
            listStreetSegments = ListStreetSegments.fromJson(jsonDecode(listStreetSegmentPrefsId));
          } else {
            listStreetSegments = null;
          }
          String listStorePointPrefsId = prefs.get(Config.draftUpdateStorePolygonPoint + storeId.toString());
          if (listStorePointPrefsId != null) {
            dynamic latLngPoint = jsonDecode(listStorePointPrefsId);
            _storePoint = new LatLng(latLngPoint[0], latLngPoint[1]);
            _isStoreGeom = true;
            _geomController = _storePoint.toString();
            _storeBehavior.geomStoreSink.add(_geomController);
          }
          dropdownBrandValue = tmp.brandName;
          if (listBuildings != null) {
            if(listBuildings.length > 0) {
              if (tmp.floorAreaId != null) {
                onInitDraftFloorArea(tmp);
              } else {
                int id = int.parse(dropdownBuildingNameValue.split(' ')[0]);
                onChangeBuilding(id);
              }
            }
          }
        });
      } 
    });
  }

  void checkInitLoad() {
    if (_isLoadListStreetSegmentsByStoreId && _isLoadStore) {
      setState(() {
        getListBuildingNearly();
      });
    }
  }

  void getListBuildingNearly() async {
    LatLng point;
    dynamic rs = await getCurrentLocation();
    point = new LatLng(rs.latitude, rs.longitude);
    if (initStore.isEditable) {
      _storeBloc.add(LoadListStoreBuildings(point: point));
    } else {
      _storeBloc.add(LoadListStoreBuildings(point: _storePoint));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _storeBehavior.dispose();
    _nameController.dispose();
    _addressController.dispose();
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
      backgroundColor: Config.secondColor,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios, 
          color: Colors.white,
          size: MediaQuery.of(context).size.height * 0.025,
        ),
        onPressed: () {
          if (_isInitLoadSuccess) {
            bool _isChange = false;
            if (_nameController.text != null) {
              if (_nameController.text.trim().isNotEmpty) {
                if (initStore.name != _nameController.text.trim().toString()) {
                  _isChange = true;
                }
              }
            }
            if (imageFile != null) {
              _isChange = true;
            }
            if (_timeSlotFormat != null) {
              if (initStore.timeSlot == null) {
                if (_timeSlotFormat.trim().toString().isNotEmpty) {
                  _isChange = true;
                }
              } else {
                if (initStore.timeSlot.trim().toString() != _timeSlotFormat.trim().toString()) {
                  _isChange = true;
                }
              }
            }
            if (_abilityToServeController.text != null) {
              if (_abilityToServeController.text.isNotEmpty) {
                if (initStore.abilityToServe != int.parse(_abilityToServeController.text.trim().toString())) {
                  _isChange = true;
                }
              }
            }
            
            if (initStore.coordinateString != null) {
              String coordinate = initStore.coordinateString.toString();
              coordinate = coordinate.replaceAll('"', '').toString();
              dynamic latLngPoint = jsonDecode(coordinate);
              double longitudeTmp = latLngPoint[0];
              double latitudeTmp = latLngPoint[1];
              LatLng _tmpStorePoint = new LatLng(latitudeTmp, longitudeTmp);
              if (_tmpStorePoint != _storePoint) {
                _isChange = true;
              }
            }
            if (_isChange && initStore.isEditable) {
              saveDraft();
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pop();
            }
          }
        },
      ), 
      title: Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                initStore == null ? '' : initStore.isEditable? 'Update store' : 'Store',
                style: TextStyle(
                  fontSize: Config.textSizeMedium,
                  color: Colors.white,
                ),
              ),
            ),
            if (initStore != null) if (initStore.isEditable) IconButton(
              icon: Icon(
                Icons.delete_forever,
                color: Colors.white,
                size: MediaQuery.of(context).size.width * 0.09,
              ),
              onPressed: () {
                if (_isInitLoadSuccess) showDeleteStoreDialog(Config.deleteStoreHeader, Config.deleteStoreMessage, context);
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
        blocListenerWidget(),
        if (!_isInitLoadSuccess) loadingWidget(context),
        if (_isInitLoadSuccess) detailStoreWidget(context),
        if (_isInitLoadSuccess && initStore.isEditable) footerWidget(context),
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
      height: initStore.isEditable ? MediaQuery.of(context).size.height * 0.75 : MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.01,
      ),
      child: ListView(
        children: <Widget>[
          if (_isSaveDraft && initStore.isEditable) showNoticeSaveDraft(context),
          if (_isSaveDraft && initStore.isEditable) SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.005,)
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
                    removeDraftStore();
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
                      initDraftStore();
                      _isSaveDraft = false;
                    });
                    removeDraftStore();
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
              if (initStore.isEditable) Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  RaisedButton(
                    color: Config.secondColor,
                    disabledColor: Config.secondColor.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.02,
                      ),
                    ),
                    onPressed: initStore.isEditable
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
          if (listBrandNames != null && initStore.isEditable)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
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
            if (!initStore.isEditable) Container(
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.05,
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              initStore.brandName == null ? 'No brand' : initStore.brandName.toString(),
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            ),
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
                    int floorNumber = int.parse(dropdownFloorNameValue.split(' ')[2]);
                    onChangeFloor(floorNumber);
                  });
                },
                items: listBuildingFloorNames.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
              if (initStore.isEditable) Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
                  RaisedButton(
                    onPressed: initStore.isEditable
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
                  size: Config.textSizeSuperSmall * 1.2,
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
          if (initStore.isEditable) Container(
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
          if (!initStore.isEditable) Container(
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.05,
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              initStore.address == null ? 
              'Not available' : initStore.address.toString(),
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            ),
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
          if (initStore.isEditable) isInBuildingSwitchButton(context),
          if (!_isInBuilding) SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
          if (initStore.isEditable && !_isInBuilding) listStreetSegmentsButton(context),
          if (initStore.isEditable && !_isInBuilding) listStreetSegmentsWidget(context),
          if (_isInBuilding) SizedBox(height:  MediaQuery.of(context).size.height * 0.005,),
          if (initStore.isEditable && _isInBuilding) listBuildingNames != null 
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
          if (!initStore.isEditable && initStore.floorAreaId == null) listStreetSegmentsButton(context),
          if (!initStore.isEditable && initStore.floorAreaId == null) listStreetSegmentsWidget(context),
          if (!initStore.isEditable && initStore.floorAreaId != null) 
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
                Text(
                  'Building: ',
                  style: TextStyle(
                    fontSize: Config.textSizeSmall,
                  ),
                ),
                Text(
                  _buildingName,
                  style: TextStyle(
                    fontSize: Config.textSizeSmall,
                  ),
                ),
              ],
            ),
          if (!initStore.isEditable && initStore.floorAreaId != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
                Text(
                  'Floor: ',
                  style: TextStyle(
                    fontSize: Config.textSizeSmall,
                  ),
                ),
                Text(
                  _floorName,
                  style: TextStyle(
                    fontSize: Config.textSizeSmall,
                  ),
                ),
              ],
            ),
          if (!initStore.isEditable && initStore.floorAreaId != null) 
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
                Text(
                  'Floor Area: ',
                  style: TextStyle(
                    fontSize: Config.textSizeSmall,
                  ),
                ),
                Text(
                  initStore.floorAreaName,
                  style: TextStyle(
                    fontSize: Config.textSizeSmall,
                  ),
                ),
              ],
            ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
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
        height: MediaQuery.of(context).size.height * 0.055,
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
              child: SvgPicture.asset(Config.streetSegmentSvgIcon, color: Config.secondColor,),
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
        // boxShadow: [
        //   BoxShadow(
        //     blurRadius: MediaQuery.of(context).size.height * 0.01,
        //     color: Colors.black.withOpacity(0.1),
        //     spreadRadius: MediaQuery.of(context).size.height * 0.01,
        //   ),
        // ],
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
          updateButton(context),
        ],
      ),
    );
  }

  Widget updateButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.height * 0.065,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: StreamBuilder(
        stream: _storeBehavior.submitStoreStream,
        builder: (context, snapshot) {
          return RaisedButton(
            onPressed: snapshot.data == true && initStore.isEditable
              ? () {
                showUpdateStoreDialog(Config.updateStoreHeader, Config.updateStoreMessage, context);
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
                    initStore.isEditable? Icons.mode_edit : Icons.not_interested_sharp,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                ),
                Text(
                  initStore.isEditable? "Update store" : "Not allow to update",
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
          if (initStore.isEditable) Container(
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
          ),
          if (!initStore.isEditable) Container(
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              initStore.name == null ? 'No name available' : initStore.name.toString(),
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            ),
          ),
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
          if (initStore.isEditable) Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              RaisedButton(
                onPressed: initStore.isEditable
                  ? () => showTimeSlotDialog()
                  : null,
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
          if (initStore.isEditable) Container(
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
          if (!initStore.isEditable) Container(
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.05,
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              initStore.abilityToServe == null ? 'Not available' : initStore.abilityToServe.toString(),
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget blocListenerWidget() {
    return MultiBlocListener(
      listeners: [
        storeBlocListenerWidget(),
      ], 
      child: SizedBox()
    );
  }

  Widget storeBlocListenerWidget() {
    return BlocListener(
      bloc: _storeBloc,
      listener: (BuildContext context, StoreState state) async {
        if (state is LoadListStreetSegmentsByStoreIdFinishState) {
          final prefs = await SharedPreferences.getInstance();
          String saveDraftStorePrefsId = Config.draftUpdateStore + initStore.id.toString();
          String checkDraft = prefs.get(saveDraftStorePrefsId);
          setState(() {
            if (checkDraft == null) {
              listStreetSegments = new ListStreetSegments(listStreetSegment: state.listStreetSegments.listStreetSegment.toList());
            }
            _isLoadListStreetSegmentsByStoreId = true;
          });
          checkInitLoad();
        } else if (state is LoadStoreByIdFinishState) {
          setState(() {
            initStore = state.store;
            _isLoadStore = true;
          });
          initStoreFunction();
          checkInitLoad();
          _storeBloc.add(LoadListStreetSegmentsByStoreId(id: storeId));
        } else if (state is UpdateStoreSucessState) {
          hideSendingProgressBar();
          removeDraftStore();
          Navigator.pop(context, [true, false]);
        } else if (state is DeleteStoreSucessState) {
          hideSendingProgressBar();
          removeDraftStore();
          Navigator.pop(context, [false, true, state.isSuccess]);
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
          initBrands();
          checkSaveDraft();
          if (!initStore.isEditable && initStore.floorAreaId != null) setInBuilding();
          _isInitLoadSuccess = true;
        }
      },
      child: SizedBox(),
    );
  }

  void setInBuilding() {
    setState(() {
      bool tmp = false;
      for (int i = 0; i <= listBuildings.length && !tmp; i++) {
        listBuildings[i].floors.forEach((floor) {
          floor.floorAreas.forEach((floorArea) { 
            if (floorArea.id == initStore.floorAreaId) {
              tmp = true;
              _buildingName = listBuildings[i].name.toString();
              _floorName = floor.name.toString();
            }
          });
        });
      }
    });
  }

  void resetGeomBuilding() {
    setState(() {
      geomStore = null;
      _geomController = null;
      _storeBehavior.geomStoreSink.add(_geomController);
      _isStoreGeom = false;
      listStreetSegments = null;
    });
  }

  void goToMapPage() async {
    final rs = await Navigator.push(context, MaterialPageRoute(builder: (context) => StoreMap(initPoint: _storePoint,)));
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

  void removeStreetSegment(StreetSegment streetSegment) {
    setState(() {
      listStreetSegments.listStreetSegment.remove(streetSegment);
    });
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
    int flag = 0;
    for (int i = 0; i < listBuildings.length && flag == 0; i++) {
      List<Floor> listBuildingFloorsTmp = new List<Floor>();
      listBuildingFloorsTmp = listBuildings[i].floors.toList();
      if (listBuildingFloorsTmp.length > 0) {
        listBuildingFloorsTmp.forEach((floor) {
          floor.floorAreas.forEach((floorArea) {
            if (floorArea.id == initStore.floorAreaId) {
              flag = 1;
              onChangeInitBuilding(listBuildings[i].id);
            }
          });
        });
      }
    }
  }

  void onChangeInitBuilding(int id) {
    setState(() {
      listBuildings.forEach((building) {
        if (building.id == id) {
          dropdownBuildingNameValue = building.id.toString() + ' ' + building.name.toString();
          listBuildingFloors = new List<Floor>();
          listBuildingFloors = building.floors;
          if (listBuildingFloors.length > 0) {
            listBuildingFloorNames = new List<String>();
            listBuildingFloors.forEach((floor) {
              listBuildingFloorNames.add('Floor number ' + floor.floorNumber.toString());
            });
            dropdownFloorNameValue = listBuildingFloorNames[0].toString();
            listBuildingFloors.forEach((floor) {
              floor.floorAreas.forEach((floorArea) { 
                if (floorArea.id == initStore.floorAreaId) {
                  dropdownFloorAreaNameValue = 'Floor number ' + floor.floorNumber.toString();
                  listBuildingFloorAreas = new List<FloorArea>();
                  listBuildingFloorAreas = floor.floorAreas;
                  listFloorAreasNames = new List<String>();
                  listBuildingFloorAreas.forEach((floorArea) {
                    listFloorAreasNames.add(floorArea.id.toString() + ' ' + floorArea.name.toString());
                  });
                  dropdownFloorAreaNameValue = initStore.floorAreaId.toString() + ' ' + initStore.floorAreaName.toString();
                }
              });
            });
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

  void onInitDraftFloorArea(Store tmp) async {
    final prefs = await SharedPreferences.getInstance();
    String buildingIdStr = prefs.getString(Config.draftUpdateStoreBuildingId + storeId.toString());
    String floorNumberStr = prefs.getString(Config.draftUpdateStoreFloorNumber + storeId.toString());
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
              listBuildingFloorNames.add('Floor number ' + floor.floorNumber.toString());
              if (floor.floorNumber == floorNumberInt) {
                dropdownFloorNameValue = 'Floor number ' + floor.floorNumber.toString();
                listBuildingFloorAreas = new List<FloorArea>();
                listBuildingFloorAreas = floor.floorAreas;
                if (listBuildingFloorAreas.length > 0) {
                  listFloorAreasNames = new List<String>();
                  listBuildingFloorAreas.forEach((floorArea) {
                    listFloorAreasNames.add(floorArea.id.toString() + ' ' + floorArea.name.toString());
                    if (floorArea.id == tmp.floorAreaId) {
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
              listBuildingFloorNames.add('Floor number ' + floor.floorNumber.toString());
            });
            dropdownFloorNameValue = listBuildingFloorNames[0].toString();
            int floorNumber = int.parse(dropdownFloorNameValue.split(' ')[2]);
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

  showDeleteStoreDialog(String header, String message, BuildContext context) {
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
              _storeBloc.add(DeleteStore(id: initStore.id));
            },
          ),
        ],
      ),
    );
  }

  showUpdateStoreDialog(String header, String message, BuildContext context) {
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
              Config.updateButtonPopup,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context);
              showSendingProgressBar();
              updateStore();
            },
          ),
        ],
      ),
    );
  }

  void saveDraft() async {
    if (initStore.isEditable) {
      final prefs = await SharedPreferences.getInstance();
      String saveDraftStorePrefsId = Config.draftUpdateStore + initStore.id.toString();
      String saveDraftStoreStreetSegmentsPrefsId = Config.draftUpdateStoreStreetSegment + initStore.id.toString();
      String saveDraftStorePolygonPointPrefsId = Config.draftUpdateStorePolygonPoint + initStore.id.toString();
      String saveDraftStoreBuildingId = Config.draftUpdateStoreBuildingId + initStore.id.toString();
      String saveDraftStoreFloorNumber = Config.draftUpdateStoreFloorNumber + initStore.id.toString();
      Store store = new Store();
      store.name = _nameController.text;
      store.address = _addressController.text;
      if (_timeSlotFormat != null && _timeSlotFormat.isNotEmpty) {
        store.timeSlot = _timeSlotFormat.toString();
      }
      try {
        store.abilityToServe = int.parse(_abilityToServeController.text.toString());
      } catch(e) {
        store.abilityToServe = null;
      }
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
        prefs.setString(saveDraftStoreFloorNumber, dropdownFloorNameValue.split(' ')[2]);
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
    }
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
      }
    );
  }

  void updateStore() async {
    StorePost store = new StorePost();
    store.id = initStore.id;
    store.name = _nameController.text.toString();
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
      if (listStreetSegments != null) {
        listStreetSegments.listStreetSegment.toList().forEach((streetsegment) { 
          store.streetSegmentIds.add(streetsegment.id);
        });
      }
    }
    if (imageUrl == null) {
      uploadImage(imageFile, store);
    } else {
      store.imageUrl = imageUrl;
      _storeBloc.add(UpdateStore(store: store));
    }
  }

  void removeDraftStore() async {
    if (storeId.toString() != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove(Config.draftUpdateStore + storeId.toString());
      prefs.remove(Config.draftUpdateStoreStreetSegment + storeId.toString());
      prefs.remove(Config.draftUpdateStorePolygonPoint + storeId.toString());
      prefs.remove(Config.draftUpdateStoreBuildingId + storeId.toString());
      prefs.remove(Config.draftUpdateStoreFloorNumber + storeId.toString());
    }
  }

  dynamic uploadImageDraft(var imageFile) async {
    StorageReference ref = _storage.ref().child("images/${DateTime.now()}.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    return dowurl.toString();
  }

  void uploadImage(var imageFile, StorePost store) async {
    StorageReference ref = _storage.ref().child("images/${DateTime.now()}.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    store.imageUrl = dowurl.toString();
    _storeBloc.add(UpdateStore(store: store));
  }

  void showSendingProgressBar() {
    _progressBar.show(context);
  }

  void hideSendingProgressBar() {
    _progressBar.hide();
  }
}