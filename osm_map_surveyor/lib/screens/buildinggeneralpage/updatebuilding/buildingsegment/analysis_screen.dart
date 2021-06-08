import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:osm_map_surveyor/behaviorsubject/analysis_behavior.dart';
import 'package:osm_map_surveyor/bloc/building_bloc.dart';
import 'package:osm_map_surveyor/events/building_event.dart';
import 'package:osm_map_surveyor/models/buildinganalysis.dart';
import 'package:osm_map_surveyor/models/segment.dart';
import 'package:osm_map_surveyor/provider/authentication_provider.dart';
import 'package:osm_map_surveyor/repositories/building_repository.dart';
import 'package:osm_map_surveyor/screens/drawer/drawer_view.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/states/building_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/progress_bar.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';

class AnalysisScreen extends StatefulWidget {
  final int buildingId;
  final String buildingName;
  AnalysisScreen({Key key, this.buildingId, this.buildingName}) : super(key: key);

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState(this.buildingId, this.buildingName);
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int buildingId;
  String buildingName;
  _AnalysisScreenState(this.buildingId,  this.buildingName);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static final String firstTimeSlot = '0h - 6h';
  static final String secondTimeSlot = '6h - 12h';
  static final String thirdTimeSlot = '12h - 18h';
  static final String fourthTimeSlot = '18h - 24h';
  static final String firstGroupAge = 'Under 12';
  static final String secondGroupAge = '12-20';
  static final String thirdGroupAge = '21-40';
  static final String fourthGroupAge = 'Over 40';

  String dropdownSegmentName;

  BuildingBloc _buildingBloc;
  AnalysisBehavior _analysisBehavior;
  bool _initLoadSuccess = false;
  List<Segment> _listSegments = new List<Segment>();
  List<String> _listSegmentNames = new List<String>();
  TextEditingController _potentialCustomerController;
  ProgressBar _progressBar;
  List<String> _listTimeSlot;
  List<String> _listSelectedTimeSlot;
  String _timeSlotShowText;
  String _timeSlotFormat;
  List<String> _listGroupAge;
  String _selectedPrimaryAge;
  String _primaryAgeShowText;
  String _primaryAgeFormat;

  @override
  void initState() {
    super.initState();
    _progressBar = ProgressBar();
    _buildingBloc = BuildingBloc(buildingRepository: BuildingRepository());
    _analysisBehavior = new AnalysisBehavior();
    _potentialCustomerController = new TextEditingController();
    _potentialCustomerController.addListener(() {
      _analysisBehavior.potentialCustomerSink.add(_potentialCustomerController.text);
    });
    _buildingBloc.add(LoadListBuildingAnalysis(id: buildingId));
    _timeSlotFormat = '';
    _timeSlotShowText = '';
    _listTimeSlot = [ 
      firstTimeSlot,
      secondTimeSlot,
      thirdTimeSlot,
      fourthTimeSlot,
    ];
    _selectedPrimaryAge = '';
    _primaryAgeShowText = '';
    _listGroupAge = [
      firstGroupAge,
      secondGroupAge,
      thirdGroupAge,
      fourthGroupAge,
    ];
  }

  @override
  void dispose() {
    super.dispose();
    _analysisBehavior.dispose();
    _buildingBloc.close();
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
          Navigator.of(context).pop();
        },
      ),
      title: Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Building Segment',
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
    return SingleChildScrollView(
      child: Column(
        children: [
          buildingBlocListener(),
          if (!_initLoadSuccess) loadingWidget(context),
          if (_initLoadSuccess) detailsWidget(context),
          if (_initLoadSuccess) saveButton(context)
        ],
      ),
    );
  }

  Widget buildingBlocListener() {
    return BlocListener(
      bloc: _buildingBloc,
      listener: (BuildContext context,BuildingState state) {
        if (state is SaveBuildingAnalysisFinishState) {
          hideSendingProgressBar();
          Navigator.pop(context, true);
        } else if (state is LoadListBuildingAnalysisFinishState) {
          setState(() {
            _listSegments = initListSegments.toList();
            bool isExist = false;
            _listSegments.forEach((segment) {
              state.listBuildingAnalysis.toList().forEach((buildingAnalysis) {
                if (buildingAnalysis.segmentId == segment.id) {
                  isExist = true;
                }
              });
              if (!isExist) _listSegmentNames.add(segment.name.toString());
              isExist = false;
            });
            if (dropdownSegmentName == null) {
              dropdownSegmentName = _listSegmentNames[0].toString();
            }
            _initLoadSuccess = true;
          });
        }
      },
      child: SizedBox(),
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

  Widget detailsWidget(BuildContext context) {
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
      margin: EdgeInsets.all(
        MediaQuery.of(context).size.width * 0.01,
      ),
      child: Column(
        children: [
          nameBuilding(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          segmentWidget(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          timeSlotWidget(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          primaryAgeWidget(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          potentialCustomerWidget(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
        ],
      ),
    );
  }

  Widget nameBuilding(BuildContext context) {
    return Container(
      child: Text(
        buildingName == null ? 'No name yet' : buildingName.toString(),
        style: TextStyle(
          fontSize: Config.textSizeMedium,
        )
      ),
    );
  }

  Widget segmentWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
        right: MediaQuery.of(context).size.width * 0.04,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.menu,
                color: Config.secondColor.withOpacity(0.54),
                size: Config.textSizeSuperSmall * 1.2,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
              Text(
                'Segment',
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          if (_listSegmentNames != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  ),
                  width: MediaQuery.of(context).size.width * 0.525,
                  height: MediaQuery.of(context).size.height * 0.06,
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.02,
                    right: MediaQuery.of(context).size.width * 0.02,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      underline: Container(
                        height: MediaQuery.of(context).size.height * 0.001,
                        color: Config.secondColor,
                      ),
                      isExpanded: true,
                      dropdownColor: Config.secondColor,
                      value: dropdownSegmentName,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                      style: TextStyle(color: Colors.white, fontSize: Config.textSizeSmall),
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownSegmentName = newValue;
                        });
                      },
                      items: _listSegmentNames.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }

  Widget timeSlotWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
        right: MediaQuery.of(context).size.width * 0.04,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.timelapse_sharp,
                color: Config.secondColor.withOpacity(0.54),
                size: Config.textSizeSuperSmall * 1.2,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
              Text(
                'Time slot',
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
          SizedBox(height: MediaQuery.of(context).size.width * 0.01,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RaisedButton(
                onPressed: () => showTimeSlotDialog(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.height * 0.05,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Icon(
                        Icons.timelapse_sharp,
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
          Text(
            _timeSlotShowText.trim().toString().isEmpty 
              ? "No time slot is chose"
              : _timeSlotShowText.trim().toString(),
            style: TextStyle(
              fontSize: Config.textSizeSmall,
            ),
          )
        ],
      ),
    );
  }

  Widget primaryAgeWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
        right: MediaQuery.of(context).size.width * 0.04,
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
                'Primary Age',
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
          SizedBox(height: MediaQuery.of(context).size.width * 0.01,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RaisedButton(
                onPressed: () => showPrimaryAgeDialog(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.05,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                      Text(
                        "Select primary age",
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
          Text(
            _primaryAgeShowText.trim().toString().isEmpty 
              ? "No primary age is chose"
              : _primaryAgeShowText.trim().toString(),
            style: TextStyle(
              fontSize: Config.textSizeSmall,
            ),
          )
        ],
      ),
    );
  }

  Widget potentialCustomerWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                color: Config.secondColor.withOpacity(0.54),
                size: Config.textSizeSuperSmall * 1.2,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
              Text(
                'Potential Customer',
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
          SizedBox(height: MediaQuery.of(context).size.width * 0.01,),
          Container(
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
            ),
            child: StreamBuilder(
              stream: _analysisBehavior.potentialCustomerStream,
              builder: (context, snapshot) {
                return TextField(
                  autofocus: false,
                  style: TextStyle(
                    fontSize: Config.textSizeSmall,
                  ),
                  decoration: InputDecoration(
                    fillColor: Colors.black54,
                    errorText: snapshot.data,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                  ],
                  controller: _potentialCustomerController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget saveButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.height * 0.065,
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.02,
      ),
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: StreamBuilder(
        stream: _analysisBehavior.submitAnalysisStream,
        builder: (context, snapshot) {
          return RaisedButton(
            onPressed: snapshot.data == true
              ? () {
                showSaveAnalysisDialog(Config.saveBuildingAnalysisHeader, Config.saveBuildingAnalysisMessage, context);
              }
              : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
            ),
            color: Config.secondColor,
            disabledColor: Config.secondColor.withOpacity(0.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  "Save analysis",
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

  showSaveAnalysisDialog(String header, String message, BuildContext context) {
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
              saveAnalysis();
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
                  _listTimeSlot,
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
                    _listSelectedTimeSlot = tmp.toList();
                    _timeSlotShowText = "";
                    _timeSlotFormat = "";
                    if (_listSelectedTimeSlot.contains(firstTimeSlot)) {
                      _timeSlotShowText = firstTimeSlot;
                      _timeSlotFormat += '1';
                    } else {
                      _timeSlotFormat += '0';
                    } 
                    if (_listSelectedTimeSlot.contains(secondTimeSlot)) {
                      if (_timeSlotShowText.trim().isEmpty) {
                        _timeSlotShowText = secondTimeSlot;
                      } else {
                        _timeSlotShowText += " " + secondTimeSlot;
                      }
                      _timeSlotFormat += '1';
                    } else {
                      _timeSlotFormat += '0';
                    }
                    if (_listSelectedTimeSlot.contains(thirdTimeSlot)) {
                      if (_timeSlotShowText.trim().isEmpty) {
                        _timeSlotShowText = thirdTimeSlot;
                      } else {
                        _timeSlotShowText += " " + thirdTimeSlot;
                      }
                      _timeSlotFormat += '1';
                    } else {
                      _timeSlotFormat += '0';
                    }
                    if (_listSelectedTimeSlot.contains(fourthTimeSlot)) {
                      if (_timeSlotShowText.trim().isEmpty) {
                        _timeSlotShowText = fourthTimeSlot;
                      } else {
                        _timeSlotShowText += " " + fourthTimeSlot;
                      }
                      _timeSlotFormat += '1';
                    } else {
                      _timeSlotFormat += '0';
                    }
                    if (int.parse(_timeSlotFormat) == 0) {
                      _timeSlotShowText = "";
                      _analysisBehavior.timeSlotSink.add(_timeSlotFormat);
                    } else {
                      _analysisBehavior.timeSlotSink.add(_timeSlotFormat);
                    }
                  });
                  Navigator.pop(context, true);
                },
              )
            ],
          );
        });
  }

  void showPrimaryAgeDialog() {
    String tmp = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Primary Age"),
          content: Container(
            constraints: BoxConstraints(
              maxHeight: 100.0,
            ),
            child: SingleChildScrollView(
                child: SingleSelectChip(
                  _listGroupAge,
                  onSelectionChanged: (selected) {
                    setState(() {
                      tmp = selected;
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
                    _selectedPrimaryAge = tmp;
                    _primaryAgeFormat = '';
                    _primaryAgeShowText = '';
                    if (_selectedPrimaryAge.isEmpty) {
                      _primaryAgeFormat = "";
                      _primaryAgeShowText = '';
                      _analysisBehavior.primaryAgeSink.add(_primaryAgeFormat);
                    } else {
                      if (_selectedPrimaryAge == firstGroupAge) {
                        _primaryAgeShowText = 'Under 12';
                        _primaryAgeFormat = '1';
                      } else if (_selectedPrimaryAge == secondGroupAge) {
                        _primaryAgeShowText = '12-20';
                        _primaryAgeFormat = '2';
                      } else if (_selectedPrimaryAge == thirdGroupAge) {
                        _primaryAgeShowText = '21-40';
                        _primaryAgeFormat = '3';
                      } else {
                        _primaryAgeShowText = 'Over 40';
                        _primaryAgeFormat = '4';
                      }
                      _analysisBehavior.primaryAgeSink.add(_primaryAgeFormat);
                    }
                  });
                  Navigator.pop(context, true);
                },
              )
            ],
          );
        });
  }

  void openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  void showSendingProgressBar() {
    _progressBar.show(context);
  }

  void hideSendingProgressBar() {
    _progressBar.hide();
  }

  void saveAnalysis() async {
    BuildingAnalysis buildingAnalysis = new BuildingAnalysis();
    buildingAnalysis.buildingId = buildingId;
    bool flag = true;
    for (int i = 0; i < _listSegments.length && flag; i++) {
      if (dropdownSegmentName == _listSegments[i].name) {
        buildingAnalysis.segmentId = _listSegments[i].id;
        flag = false;
      }
    }
    buildingAnalysis.timeSlot = _timeSlotFormat;
    buildingAnalysis.primaryAge = int.parse(_primaryAgeFormat);
    buildingAnalysis.potentialCustomers = int.parse(_potentialCustomerController.text);
    _buildingBloc.add(SaveBuildingAnalysis(buildingAnalysis: buildingAnalysis));
  }
}