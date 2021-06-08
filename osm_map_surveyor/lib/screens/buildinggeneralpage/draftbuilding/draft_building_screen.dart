import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geodesy/geodesy.dart';
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/createbuilding/create_building_screen.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraftBuildingScreen extends StatefulWidget {
  final LatLng systemZoneCenter;

  const DraftBuildingScreen({Key key, this.systemZoneCenter}) : super(key: key);
  
  @override
  _DraftBuildingScreenState createState() => _DraftBuildingScreenState(this.systemZoneCenter);
}

class _DraftBuildingScreenState extends State<DraftBuildingScreen> {
  LatLng systemZoneCenter;
  _DraftBuildingScreenState(this.systemZoneCenter);

  List<Building> listDraftBuildings;

  @override
  void initState() { 
    super.initState();
    initDraftBuildings();
  }

  void initDraftBuildings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        int i = 1;
        bool isNotFound = false;
        while (!isNotFound) {
          String buildingPrefs = prefs.getString(Config.draftBuilding + i.toString());
          if (buildingPrefs == null) {
            isNotFound = true;
          } else {
            if (listDraftBuildings == null) {
              listDraftBuildings = [];
            }
            Building tmp = Building.fromJson(jsonDecode(buildingPrefs));
            listDraftBuildings.add(tmp);
            i += 1;
          }
        }
      },
    );
  }

  @override
  void dispose() { 
    
    super.dispose();
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
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios, 
          color: Colors.white,
          size: MediaQuery.of(context).size.height * 0.025,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      iconTheme: IconThemeData(
        color: Config.iconThemeColor,
      ),
      backgroundColor: Config.secondColor,
      title: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                'Draft building',
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.01,
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return listDraftBuildings != null
                    ? _buildingWidget(context, index)
                    : _noDraftBuildingWidget(context);
                },
                childCount: listDraftBuildings != null ? listDraftBuildings.length : 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildingWidget(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _goToCreateBuildingPage(index);
      },
      child: Container(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.02,
          bottom: MediaQuery.of(context).size.height * 0.005,
          top: MediaQuery.of(context).size.height * 0.005,
        ),
        height: MediaQuery.of(context).size.height * 0.075,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Config.secondColor,
            width: MediaQuery.of(context).size.height * 0.001,
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
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.1,
              height: MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Config.redColor,
                    width: 1.0,
                  ),
                ),
              ),
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.02,
              ),
              padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.02,
              ),
              child: listDraftBuildings[index].imageUrl == null
                ? setIconBuilding(listDraftBuildings[index].type)
                : Image.network(listDraftBuildings[index].imageUrl),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.02,
                ),
                child: listDraftBuildings[index].name == null
                  ? Text("No name")
                  : listDraftBuildings[index].name.isEmpty
                    ? Text("No name")
                    : listDraftBuildings[index].name.length > 43
                      ? Tooltip(
                          message: listDraftBuildings[index].name,
                          child: Text(listDraftBuildings[index].name.substring(0, 40) + "..."),
                        )
                      : Text(listDraftBuildings[index].name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SvgPicture setIconBuilding(String type) {
    if (type != null) {
      if (type.contains("Educational")) {
        return SvgPicture.asset(
          Config.schoolSvgIcon,
          color: Config.secondColor,
        );
      } else if (type.contains("Residential")) {
        return SvgPicture.asset(
          Config.apartmentSvgIcon,
          color: Config.secondColor,
        );
      } else if (type.contains("Business")) {
        return SvgPicture.asset(
          Config.buildingDefaultSvgIcon,
          color: Config.secondColor,
        );
      } else if (type.contains("Industrial")) {
        return SvgPicture.asset(
          Config.industrialSvgIcon,
          color: Config.secondColor,
        );
      } else if (type.contains("Service")) {
        return SvgPicture.asset(
          Config.serviceSvgIcon,
          color: Config.secondColor,
        );
      }
    }
    return SvgPicture.asset(
      Config.buildingSvgIcon,
      color: Config.secondColor,
    );
  }

  Widget _noDraftBuildingWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.1,
      ),
      height: MediaQuery.of(context).size.height * 0.2,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Column(
          children: [
            Text(
              'No draft building available!',
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _goToCreateBuildingPage(int index) async {
    final prefs = await SharedPreferences.getInstance();
    dynamic rs = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => CreateBuildingScreen(
          initBuilding: listDraftBuildings[index],
          sharePreferenceId: (index+1).toString(),
          systemZoneCenter: systemZoneCenter,
        )
      )
    );

    if (rs != null) {
      setState(() {
        listDraftBuildings = null;
        int i = 1;
        bool isNotFound = false;
        while (!isNotFound) {
          String buildingPrefs = prefs.getString(Config.draftBuilding + i.toString());
          if (buildingPrefs == null) {
            isNotFound = true;
          } else {
            if (listDraftBuildings == null) {
              listDraftBuildings = [];
            }
            Building tmp = Building.fromJson(jsonDecode(buildingPrefs));
            listDraftBuildings.add(tmp);
            i += 1;
          }
        }
      });
      if (rs[1]) {
        showToast(context, Config.deleteDraftBuildingSuccessMessage, true);
      } else {
        if (rs[0]) {
          Navigator.pop(context, true);
        } else {
          showToast(context, Config.saveDraftBuildingSuccessMessage, true);
        }
      }
    }
  }
}