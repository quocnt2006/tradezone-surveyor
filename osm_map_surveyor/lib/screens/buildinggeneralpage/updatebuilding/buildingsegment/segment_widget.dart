import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_map_surveyor/behaviorsubject/analysis_behavior.dart';
import 'package:osm_map_surveyor/events/building_event.dart';
import 'package:osm_map_surveyor/models/buildinganalysis.dart';
import 'package:osm_map_surveyor/repositories/building_repository.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/updatebuilding/buildingsegment/building_segment_screen.dart';
import 'package:osm_map_surveyor/states/building_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';
import 'package:osm_map_surveyor/bloc/building_bloc.dart';


class SegmentWidget extends StatefulWidget {
  final int index;
  SegmentWidget({Key key, this.index}) : super(key: key);

  @override
  _SegmentWidgetState createState() => _SegmentWidgetState(this.index);
}

class _SegmentWidgetState extends State<SegmentWidget> {
  int index;
  _SegmentWidgetState(this.index);

  static final String firstTimeSlot = '0h - 6h';
  static final String secondTimeSlot = '6h - 12h';
  static final String thirdTimeSlot = '12h - 18h';
  static final String fourthTimeSlot = '18h - 24h';
  static final String firstGroupAge = 'Under 12';
  static final String secondGroupAge = '12-20';
  static final String thirdGroupAge = '21-40';
  static final String fourthGroupAge = 'Over 40';

  BuildingAnalysis buildingAnalysis = new BuildingAnalysis();

  AnalysisBehavior _analysisBehavior;
  BuildingBloc _buildingBloc;
  bool _isShow;
  bool _isUpdate;
  bool _isUpdating;
  TextEditingController _potentialCustomerController;
  List<String> _listTimeSlot;
  List<String> _listSelectedTimeSlot;
  String _timeSlotShowText;
  String _initTimeSlotShowText;
  String _timeSlotFormat;
  List<String> _listGroupAge;
  String _selectedPrimaryAge;
  String _primaryAgeShowText;
  String _primaryAgeFormat;
  
  @override
  void initState() { 
    super.initState();
    buildingAnalysis = listBuildingAnalysises[index];
    _analysisBehavior = AnalysisBehavior();
    _potentialCustomerController = new TextEditingController();
    _buildingBloc = BuildingBloc(buildingRepository: BuildingRepository());
    _potentialCustomerController.addListener(() {
      _analysisBehavior.potentialCustomerSink.add(_potentialCustomerController.text);
    });
    _timeSlotFormat = '';
    _timeSlotShowText = '';
    _listTimeSlot = [ 
      firstTimeSlot,
      secondTimeSlot,
      thirdTimeSlot,
      fourthTimeSlot,
    ];
    _listSelectedTimeSlot = new List<String>();
    if (buildingAnalysis.timeSlot != null) {
      if (int.parse(buildingAnalysis.timeSlot) % 10000 >= 1000) {
        _timeSlotShowText = firstTimeSlot;
        _timeSlotFormat += '1';
      } else {
        _timeSlotFormat += '0';
      } 
      if (int.parse(buildingAnalysis.timeSlot) % 1000 >= 100) {
        if (_timeSlotShowText.trim().isEmpty) {
          _timeSlotShowText = secondTimeSlot;
        } else {
          _timeSlotShowText += " " + secondTimeSlot;
        }
        _timeSlotFormat += '1';
      } else {
        _timeSlotFormat += '0';
      } 
      if (int.parse(buildingAnalysis.timeSlot) % 100 >= 10) {
        if (_timeSlotShowText.trim().isEmpty) {
          _timeSlotShowText = thirdTimeSlot;
        } else {
          _timeSlotShowText += " " + thirdTimeSlot;
        }
        _timeSlotFormat += '1';
      } else {
        _timeSlotFormat += '0';
      } 
      if (int.parse(buildingAnalysis.timeSlot) % 10 >= 1) {
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
        _initTimeSlotShowText = _timeSlotShowText;
        _analysisBehavior.timeSlotSink.add(_timeSlotFormat);
      }
    }
    _isShow = false;
    _isUpdate = false;
    _isUpdating = false;
    _primaryAgeShowText = '';
    _primaryAgeFormat = '';
    _listGroupAge = [
      firstGroupAge,
      secondGroupAge,
      thirdGroupAge,
      fourthGroupAge,
    ];
    if (buildingAnalysis.primaryAge != null) {
      _primaryAgeShowText = '';
      _primaryAgeFormat = '';
      if (buildingAnalysis.primaryAge == 1) {
        _primaryAgeShowText = 'Under 12';
        _primaryAgeFormat = '1';
      } else if (buildingAnalysis.primaryAge == 2) {
        _primaryAgeShowText = '12-20';
        _primaryAgeFormat = '2';
      } else if (buildingAnalysis.primaryAge == 3) {
        _primaryAgeShowText = '21-40';
        _primaryAgeFormat = '3';
      } else {
        _primaryAgeShowText = 'Over 40';
        _primaryAgeFormat = '4';
      }
      _analysisBehavior.primaryAgeSink.add(_primaryAgeFormat);
    } else {
      _primaryAgeFormat = "";
      _primaryAgeShowText = '';
      _analysisBehavior.primaryAgeSink.add(_primaryAgeFormat);
    }
  }

  @override
  void dispose() { 
    _potentialCustomerController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (buildingAnalysis != listBuildingAnalysises[index]) {
        buildingAnalysis = listBuildingAnalysises[index];
        if (buildingAnalysis.timeSlot != null) {
          _timeSlotShowText = '';
          _timeSlotFormat = '';
          if (int.parse(buildingAnalysis.timeSlot) % 10000 >= 1000) {
            _timeSlotShowText = firstTimeSlot;
            _timeSlotFormat += '1';
          } else {
            _timeSlotFormat += '0';
          } 
          if (int.parse(buildingAnalysis.timeSlot) % 1000 >= 100) {
            if (_timeSlotShowText.trim().isEmpty) {
              _timeSlotShowText = secondTimeSlot;
            } else {
              _timeSlotShowText += " " + secondTimeSlot;
            }
            _timeSlotFormat += '1';
          } else {
            _timeSlotFormat += '0';
          } 
          if (int.parse(buildingAnalysis.timeSlot) % 100 >= 10) {
            if (_timeSlotShowText.trim().isEmpty) {
              _timeSlotShowText = thirdTimeSlot;
            } else {
              _timeSlotShowText += " " + thirdTimeSlot;
            }
            _timeSlotFormat += '1';
          } else {
            _timeSlotFormat += '0';
          } 
          if (int.parse(buildingAnalysis.timeSlot) % 10 >= 1) {
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
            _initTimeSlotShowText = _timeSlotShowText;
            _analysisBehavior.timeSlotSink.add(_timeSlotFormat);
          }
        }
        if (buildingAnalysis.primaryAge != null) {
          _primaryAgeShowText = '';
          _primaryAgeFormat = '';
          if (buildingAnalysis.primaryAge == 1) {
            _primaryAgeShowText = 'Under 12';
            _primaryAgeFormat = '1';
          } else if (buildingAnalysis.primaryAge == 2) {
            _primaryAgeShowText = '12-20';
            _primaryAgeFormat = '2';
          } else if (buildingAnalysis.primaryAge == 3) {
            _primaryAgeShowText = '21-40';
            _primaryAgeFormat = '3';
          } else {
            _primaryAgeShowText = 'Over 40';
            _primaryAgeFormat = '4';
          }
          _analysisBehavior.primaryAgeSink.add(_primaryAgeFormat);
        } else {
          _primaryAgeFormat = "";
          _primaryAgeShowText = '';
          _analysisBehavior.primaryAgeSink.add(_primaryAgeFormat);
        }
      }
    });
    return Container(
      child: Stack(
        children: [
          buildingBlocListenerWidget(),
          if (_isShow) Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Config.secondColor,
              ),
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.02,
              ),
            ),
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.045,
              right: MediaQuery.of(context).size.width * 0.045,
              top: MediaQuery.of(context).size.height * 0.01,            
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.065,
              bottom: MediaQuery.of(context).size.height * 0.01,
              left: MediaQuery.of(context).size.width * 0.02,
              right: MediaQuery.of(context).size.width * 0.02,
            ),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!_isUpdate) Row(
                      children: [
                        Container(
                          child: Text(
                            'Primary Age '
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Config.secondColor.withOpacity(0.54),
                            height: MediaQuery.of(context).size.height * 0.001,
                          ),
                        ),
                      ],
                    ),
                    if (_isUpdate) Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              child: Text(
                                'Primary Age '
                              ),
                            ),
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
                      ],
                    ),
                    Container( 
                      child: Text(
                        _primaryAgeShowText.trim().toString().isEmpty 
                          ? "No primary age is chose"
                          : _primaryAgeShowText.trim().toString(),
                        style: TextStyle(
                          fontSize: Config.textSizeSmall,
                        ),
                      ),
                    ),
                  ],  
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          child: Text(
                            'Time slot '
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Config.secondColor.withOpacity(0.54),
                            height: MediaQuery.of(context).size.height * 0.001,
                          ),
                        ),
                      ],
                    ),
                    if (_isUpdate) Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(
                          onPressed: () => showPrimaryAgeDialog(),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height * 0.05,
                            alignment: Alignment.center,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
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
                    if (_isUpdate) Container(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.04,
                        right: MediaQuery.of(context).size.width * 0.04,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _timeSlotShowText.trim().toString().isEmpty 
                          ? "No time slot is chose"
                          : _timeSlotShowText.trim().toString(),
                        style: TextStyle(
                          fontSize: Config.textSizeSmall,
                        ),
                      ),
                    ),
                    if (!_isUpdate) Container(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.04,
                        right: MediaQuery.of(context).size.width * 0.04,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initTimeSlotShowText.trim().toString(),
                        style: TextStyle(
                          fontSize: Config.textSizeSmall,
                        ),
                      ),
                    ),
                  ],  
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (!_isUpdate) Container(
                      child: Row(
                        children: [
                          Text(
                            'Potential customer '
                          ),
                          Expanded(
                            child: Container(
                              color: Config.secondColor.withOpacity(0.54),
                              height: MediaQuery.of(context).size.height * 0.001,
                            ),
                          ),
                        ],
                      )
                    ),
                    if (!_isUpdate) Container(
                      child: Text(
                        buildingAnalysis.potentialCustomers.toString(),
                        style: TextStyle(
                          fontSize: Config.textSizeSmall,
                        ),
                      ),
                    ),
                    if (_isUpdate) Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Potential customer '
                            ),
                            Expanded(
                              child: Container(
                                color: Config.secondColor.withOpacity(0.54),
                                height: MediaQuery.of(context).size.height * 0.001,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: StreamBuilder(
                            stream: _analysisBehavior.potentialCustomerStream,
                            builder: (context, snapshot) {
                              return TextField(
                                autofocus: false,
                                style: TextStyle(
                                  fontSize: Config.textSizeSmall,
                                ),
                                decoration: InputDecoration(
                                  helperText: '0-9999',
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
                        )
                      ],
                    ),
                  ],  
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isUpdate)updateButton(context),
                    if (_isUpdate) saveButton(context),
                    if (_isUpdate) SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                    if (_isUpdate && !_isUpdating) cancelButton(context),
                    if (_isUpdate && _isUpdating) updatingWidget(context),
                  ],
                ),
              ],
            ),
          ),
          FlatButton(
            onPressed: () {
              setState(() {
                if (_isShow) {
                  _isShow = false;
                } else {
                  _isShow = true;
                }
              });
            }, 
            child: Container(
              height: MediaQuery.of(context).size.height * 0.065,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(
                  color: Config.secondColor,
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
              child: Text(
                buildingAnalysis.segmentName,
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildingBlocListenerWidget() {
    return BlocListener(
      bloc: _buildingBloc,
      listener: (BuildContext context,BuildingState state) {
        if (state is UpdateBuildingAnalysisFinishState) {
          setState(() {
            buildingAnalysis = state.buildingAnalysis;
            listBuildingAnalysises[index] = buildingAnalysis;
            _timeSlotFormat = '';
            _timeSlotShowText = '';
            _listTimeSlot = [ 
              firstTimeSlot,
              secondTimeSlot,
              thirdTimeSlot,
              fourthTimeSlot,
            ];
            _listSelectedTimeSlot = new List<String>();
            if (int.parse(buildingAnalysis.timeSlot) % 10000 >= 1000) {
              _timeSlotShowText = firstTimeSlot;
              _timeSlotFormat += '1';
            } else {
              _timeSlotFormat += '0';
            } 
            if (int.parse(buildingAnalysis.timeSlot) % 1000 >= 100) {
              if (_timeSlotShowText.trim().isEmpty) {
                _timeSlotShowText = secondTimeSlot;
              } else {
                _timeSlotShowText += " " + secondTimeSlot;
              }
              _timeSlotFormat += '1';
            } else {
              _timeSlotFormat += '0';
            } 
            if (int.parse(buildingAnalysis.timeSlot) % 100 >= 10) {
              if (_timeSlotShowText.trim().isEmpty) {
                _timeSlotShowText = thirdTimeSlot;
              } else {
                _timeSlotShowText += " " + thirdTimeSlot;
              }
              _timeSlotFormat += '1';
            } else {
              _timeSlotFormat += '0';
            } 
            if (int.parse(buildingAnalysis.timeSlot) % 10 >= 1) {
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
              _initTimeSlotShowText = _timeSlotShowText;
              _analysisBehavior.timeSlotSink.add(_timeSlotFormat);
            }
            _isUpdating = false;
            _isUpdate = false;
          });
        }
      },
      child: SizedBox(),
    );
  }

  Widget updateButton(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        setState(() {
          _potentialCustomerController.text = buildingAnalysis.potentialCustomers.toString();
          _analysisBehavior.potentialCustomerSink.add(_potentialCustomerController.text);
          _timeSlotFormat = '';
          _timeSlotShowText = '';
          _listTimeSlot = [ 
            firstTimeSlot,
            secondTimeSlot,
            thirdTimeSlot,
            fourthTimeSlot,
          ];
          _listSelectedTimeSlot = new List<String>();
          if (int.parse(buildingAnalysis.timeSlot) % 10000 >= 1000) {
            _timeSlotShowText = firstTimeSlot;
            _timeSlotFormat += '1';
          } else {
            _timeSlotFormat += '0';
          } 
          if (int.parse(buildingAnalysis.timeSlot) % 1000 >= 100) {
            if (_timeSlotShowText.trim().isEmpty) {
              _timeSlotShowText = secondTimeSlot;
            } else {
              _timeSlotShowText += " " + secondTimeSlot;
            }
            _timeSlotFormat += '1';
          } else {
            _timeSlotFormat += '0';
          } 
          if (int.parse(buildingAnalysis.timeSlot) % 100 >= 10) {
            if (_timeSlotShowText.trim().isEmpty) {
              _timeSlotShowText = thirdTimeSlot;
            } else {
              _timeSlotShowText += " " + thirdTimeSlot;
            }
            _timeSlotFormat += '1';
          } else {
            _timeSlotFormat += '0';
          } 
          if (int.parse(buildingAnalysis.timeSlot) % 10 >= 1) {
            if (_timeSlotShowText.trim().isEmpty) {
              _timeSlotShowText = thirdTimeSlot;
            } else {
              _timeSlotShowText += " " + secondTimeSlot;
            }
            _timeSlotFormat += '1';
          } else {
            _timeSlotFormat += '0';
          } 
          if (int.parse(_timeSlotFormat) == 0) {
            _timeSlotShowText = "";
            _analysisBehavior.timeSlotSink.add(_timeSlotFormat);
          } else {
            _initTimeSlotShowText = _timeSlotShowText;
            _analysisBehavior.timeSlotSink.add(_timeSlotFormat);
          }
          _isUpdate = true;
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width * 0.02,
        ),
      ),
      color: Config.secondColor,
      child: Container(
        child: Text(
          'Update',
          style: TextStyle(
            color: Colors.white,
            fontSize: Config.textSizeSmall,
          ),
        ),
      ),
    );
  }

  Widget saveButton(BuildContext context) {
    return StreamBuilder(
      stream: _analysisBehavior.submitAnalysisStream,
      builder: (BuildContext context, AsyncSnapshot snapshot){
        return RaisedButton(
          onPressed: snapshot.data == true 
          ? () {
            if (!_isUpdating) showUpdateSegmentWidget(Config.updateSegmentHeader, Config.updateSegmentMessage, context);
          }
          : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.width * 0.02,
            ),
          ),
          color: Config.secondColor,
          child: Container(
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: Config.textSizeSmall,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget cancelButton(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        setState(() {
          if (buildingAnalysis.primaryAge != null) {
            _primaryAgeShowText = '';
            _primaryAgeFormat = '';
            if (buildingAnalysis.primaryAge == 1) {
              _primaryAgeShowText = 'Under 12';
              _primaryAgeFormat = '1';
            } else if (buildingAnalysis.primaryAge == 2) {
              _primaryAgeShowText = '12-20';
              _primaryAgeFormat = '2';
            } else if (buildingAnalysis.primaryAge == 3) {
              _primaryAgeShowText = '21-40';
              _primaryAgeFormat = '3';
            } else {
              _primaryAgeShowText = 'Over 40';
              _primaryAgeFormat = '4';
            }
            _analysisBehavior.primaryAgeSink.add(_primaryAgeFormat);
          } else {
            _primaryAgeFormat = "";
            _primaryAgeShowText = '';
            _analysisBehavior.primaryAgeSink.add(_primaryAgeFormat);
          }
          _isUpdate = false;
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width * 0.02,
        ),
      ),
      color: Config.secondColor,
      child: Container(
        child: Text(
          'Cancel',
          style: TextStyle(
            color: Colors.white,
            fontSize: Config.textSizeSmall,
          ),
        ),
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
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Widget updatingWidget(BuildContext context) {
    return CircularProgressIndicator(
      backgroundColor: Config.thirdColor,
      valueColor: AlwaysStoppedAnimation<Color>(Config.secondColor),
    );
  }

  showUpdateSegmentWidget(String header, String message, BuildContext context) {
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
              _isUpdating = true;
              updateCategory();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void updateCategory() {
    BuildingAnalysis updateBuildingAnalysis = new BuildingAnalysis();
    updateBuildingAnalysis.buildingId = buildingAnalysis.buildingId;
    updateBuildingAnalysis.segmentId = buildingAnalysis.segmentId;
    updateBuildingAnalysis.timeSlot = _timeSlotFormat;
    updateBuildingAnalysis.potentialCustomers = int.parse(_potentialCustomerController.text);
    updateBuildingAnalysis.primaryAge = int.parse(_primaryAgeFormat);
    _buildingBloc.add(UpdateBuildingAnalysis(buildingAnalysis: updateBuildingAnalysis));
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
                      _primaryAgeShowText = "";
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
}