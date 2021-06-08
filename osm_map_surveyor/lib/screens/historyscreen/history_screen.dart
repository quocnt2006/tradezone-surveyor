import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geodesy/geodesy.dart';
import 'package:osm_map_surveyor/models/history.dart';
import 'package:osm_map_surveyor/provider/authentication_provider.dart';
import 'package:osm_map_surveyor/screens/drawer/drawer_view.dart';
import 'package:osm_map_surveyor/screens/general_page.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/geolocator_utils.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';

LatLng historyLocation;

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final String allObject = 'All';
  final String buildingObject = 'Building';
  final String storeObject = 'Store';
  final String allAction = 'All';
  final String insertAction = 'Insert';
  final String updateAction = 'Update';
  final String deleteAction = 'Delete';

  List<History> _listAllHistory = List<History>();
  List<History> _listHistoryShow = List<History>();
  List<String> _listObjectNames = List<String>();
  List<String> _listActionNames = List<String>();
  String dropdownObjectValue;
  String dropdownActionValue;
  @override
  void initState() { 
    super.initState();
    _listAllHistory = initListHistory.toList();
    _listHistoryShow = _listAllHistory.toList();
    _listObjectNames = [
      allObject,
      buildingObject,
      storeObject,
    ];
    _listActionNames = [
      allAction,
      insertAction,
      updateAction,
      deleteAction,
    ];
    dropdownObjectValue = _listObjectNames[0];
    dropdownActionValue = _listActionNames[0];
  }

  @override
  void dispose() { 
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Config.secondColor,
      appBar: appBar(context),
      endDrawer: appEndDrawer(context),
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
                  fit: BoxFit.fill,
                ),
            ),
          )
        )
      ],
    );
  }

  Widget body(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        children: [
          listHistoryWidget(context),
        ],
      ),
    );
  }

  Widget listHistoryWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          headerWidget(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
          for (int i = 0; i < _listHistoryShow.length; i++) 
            historyWidget(context, _listHistoryShow[i]),
        ],
      ),
    );
  }

  Widget headerWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.01,
        right: MediaQuery.of(context).size.width * 0.05,
        left: MediaQuery.of(context).size.width * 0.05,
      ),
      child: Row(
        children: [
          if (_listObjectNames != null)
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Config.secondColor,
                ),
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width * 0.02,
                ),
              ),
              width: MediaQuery.of(context).size.width * 0.43,
              height: MediaQuery.of(context).size.height * 0.05,
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.02,
                right: MediaQuery.of(context).size.width * 0.02,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dropdownObjectValue,
                  icon: Icon(Icons.arrow_drop_down),
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: Config.textSizeSmall,
                  ),
                  onChanged: (String objectValue) {
                    setState(() {
                      onObjectChange(objectValue, null);
                    });
                  },
                  items: _listObjectNames.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              )
            ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.04,
          ),
          if (_listActionNames != null)
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Config.secondColor,
                ),
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width * 0.02,
                ),
              ),
              width: MediaQuery.of(context).size.width * 0.43,
              height: MediaQuery.of(context).size.height * 0.05,
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.02,
                right: MediaQuery.of(context).size.width * 0.02,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dropdownActionValue,
                  icon: Icon(Icons.arrow_drop_down),
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: Config.textSizeSmall,
                  ),
                  onChanged: (String actionValue) {
                    setState(() {
                      onObjectChange(null, actionValue);
                    });
                  },
                  items: _listActionNames.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              )
            ),
        ],
      ),
    );
  }

  Widget historyWidget(BuildContext context, History history) {
    return FlatButton(
      onPressed: () {
        if (history.geom != null) {
          if (history.geom.contains('MULTIPOLYGON')) {
            String historyStr = history.geom.substring(history.geom.indexOf(' ') + 1, history.geom.length);
            historyStr = historyStr.replaceAll('(', '').replaceAll(')', '').toString();
            List<String> listPointStr = historyStr.split(',').toList();
            for (int i = 0; i < listPointStr.length; i++) {
              listPointStr[i] = '[' + listPointStr[i].trim().replaceAll(' ', ',') + ']';
            }
            List<LatLng> listPoint = new List<LatLng>();
            listPointStr.forEach((pointStr) {
              listPoint.add(new LatLng(jsonDecode(pointStr)[1], jsonDecode(pointStr)[0]));
            });
            historyLocation = getCenterPolygon(listPoint);
          } else {
            String latitudeStr = history.geom.toString().split(' ')[2].toString();
            String longitudeStr = history.geom.toString().split(' ')[1].toString();
            latitudeStr = latitudeStr.replaceAll(')', '');
            longitudeStr = longitudeStr.replaceAll('(', '');
            historyLocation = new LatLng(double.parse(latitudeStr), double.parse(longitudeStr));
          }
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => GeneralPage(index: 3,)),
          );
        } else {
          showToastMessage(context, Config.locationNoAvailableMessage);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.08,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.005,
          top: MediaQuery.of(context).size.height * 0.005,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(
            color: Config.secondColor,
          ),
          borderRadius: BorderRadius.circular(
            MediaQuery.of(context).size.width * 0.02,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 2,
              offset: Offset(2, 3), // Shadow position
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.175,
              decoration: BoxDecoration(
                color: Config.secondColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(MediaQuery.of(context).size.width * 0.0175),
                  topLeft: Radius.circular(MediaQuery.of(context).size.width * 0.0175),
                ),
              ),
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.height * 0.02,
              ),
              child: history.storeId == null 
                ? SvgPicture.asset(
                  Config.buildingSvgIcon,
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.075,
                )
                : SvgPicture.asset(
                  Config.headerStoreSvgIcon,
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.075,
                ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01,
                  left: MediaQuery.of(context).size.width * 0.02,
                  right: MediaQuery.of(context).size.width * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        history.referenceName,
                        style: TextStyle(
                          fontSize: Config.textSizeSmall * 0.85,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                          history.createDate.split('T')[0],
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.225,
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.height * 0.02,
              ),
              child: actionWidget(context, history.action),
            ),
          ],
        ),
      ),
    );
  }

  MaterialColor statusColor(int action) {
    if (action == 1 || action == 4){
      return Colors.green;
    } else if (action == 2 || action == 5) {
      return Colors.yellow;
    } else if (action == 3 || action == 6) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  Widget actionWidget(BuildContext context, int action) {
    if (action == 1) {
      return Container(
        child: Text(
          'Insert',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: Config.textSizeSuperSmall,
            color: statusColor(action),
          ),
        ),
      );
    } else if (action == 2) {
      return Container(
        child: Text(
          'Update',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: Config.textSizeSuperSmall,
            color: statusColor(action),
          ),
        ),
      );
    } else if (action == 3) {
      return Container(
        child: Text(
          'Delete',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: Config.textSizeSuperSmall,
            color: statusColor(action),
          ),
        ),
      );
    } else if (action == 4) {
      return Container(
        child: Text(
          'Insert',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: Config.textSizeSuperSmall,
            color: statusColor(action),
          ),
        ),
      );
    } else if (action == 5) {
      return Container(
        child: Text(
          'Update',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: Config.textSizeSuperSmall,
            color: statusColor(action),
          ),
        ),
      );
    } else {
      return Container(
        child: Text(
          'Delete',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: Config.textSizeSuperSmall,
            color: statusColor(action),
          ),
        ),
      );
    } 
  }

  void onObjectChange(String objectValue, String actionValue) {
    setState(() {
      if (objectValue != null) {
        dropdownObjectValue = objectValue;
      }
      if (actionValue != null) {
        dropdownActionValue = actionValue;
      }
      List<History> tmp = List<History>();
      _listAllHistory.forEach((history) {
        if (dropdownObjectValue == buildingObject) {
          if (dropdownActionValue == allAction) {
            if (history.buildingId != null) {
              tmp.add(history);
            }
          } else {
            if (history.buildingId != null &&
              (history.action == checkStatus(dropdownActionValue)[0] ||
              history.action == checkStatus(dropdownActionValue)[1])
            ) {
              tmp.add(history);
            }
          }
      } else if (dropdownObjectValue == storeObject) {
        if (dropdownActionValue == allAction) {
          if (history.storeId != null) {
            tmp.add(history);
          }
        } else {
          if (history.storeId != null &&
              (history.action == checkStatus(dropdownActionValue)[0] ||
              history.action == checkStatus(dropdownActionValue)[1])
            ) {
              tmp.add(history);
            }
        }
      } else {
        if (dropdownActionValue == allAction) {
          tmp = _listAllHistory.toList();
        } else {
          if (history.action == checkStatus(dropdownActionValue)[0] ||
            history.action == checkStatus(dropdownActionValue)[1]
          ) {
            tmp.add(history);
          }
        }
      }
      });
      _listHistoryShow = tmp.toList();
    });
  }

  List<int> checkStatus(String value) {
    if (value == insertAction) {
      return [1,4];
    } else if (value == updateAction) {
      return [2,5];
    } else {
      return [3,6];
    }
  }

  void openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }
}