import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_map_surveyor/bloc/building_bloc.dart';
import 'package:osm_map_surveyor/events/building_event.dart';
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/models/floor.dart';
import 'package:osm_map_surveyor/repositories/building_repository.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/updatebuilding/buildingsegment/analysis_screen.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/updatebuilding/buildingsegment/building_segment_screen.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/updatebuilding/update_building_screen.dart';
import 'package:osm_map_surveyor/screens/map/map_general_page.dart';
import 'package:osm_map_surveyor/screens/map/map_popup/building_popup/buildingfloorpopup/building_floor_popup.dart';
import 'package:osm_map_surveyor/states/building_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

List<Floor> listFloorPopup = List<Floor>();

class BuildingNeedSurveyPopup extends StatefulWidget {
  BuildingNeedSurveyPopup({Key key}) : super(key: key);

  @override
  _BuildingNeedSurveyPopupState createState() => _BuildingNeedSurveyPopupState();
}

class _BuildingNeedSurveyPopupState extends State<BuildingNeedSurveyPopup> {
  Building building;
  String statusText;
  Color statusColor;
  Color statusBorderColor;

  BuildingBloc _buildingBloc;
  bool _isLoadingBuilding = false;

  @override
  void initState() {
    super.initState();
    _buildingBloc = BuildingBloc(buildingRepository: BuildingRepository());
    _buildingBloc.add(LoadBuildingDetailsById(id: buildingPopupId));
  }

  @override
  void dispose() {
    _buildingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              buildingBlocListener(),
              if (!_isLoadingBuilding) loadingWidget(context),
              if (_isLoadingBuilding) buildingDetails(context),
            ],
          ),
        )
      ),
      actions: <Widget>[
        FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
        )
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

  Widget buildingDetails(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Text(
              'Building details',
              style: TextStyle(
                fontSize: Config.textSizeSmall * 1.25,
                fontWeight: FontWeight.bold,
                color: Config.secondColor,
              ),
            ),
          ),
          SizedBox(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.001,
              color: Config.secondColor,
            ),
            height: MediaQuery.of(context).size.height * 0.001,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Text(
              building.name == null ? 'No name yet' : building.name.toString(),
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          Container(
            height: MediaQuery.of(context).size.height * 0.04,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: statusColor,
                border: Border.all(
                  color: statusBorderColor,
                ),
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width * 0.01,
                ),
              ),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.3,
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusBorderColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          Container(
            width: MediaQuery.of(context).size.width,
            child: building.imageUrl != null 
              ? Container(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Image.network(building. imageUrl), 
              )
              : SizedBox(),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          Container(
            child: Row(
              children: [
                Text(
                  'Floor number : ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  building.numberOfFloor == null ? 'No data available' : building.numberOfFloor.toString(),
                ),
              ],
            )
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          Container(
            child: Text(
              'Address : ' + (building.address == null ? 'No data available' : building.address.toString()),
            )
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          buildingFloorButton(context),
          if (building.status == 1) SizedBox(height: MediaQuery.of(context).size.height * 0.01,), 
          if (building.status == 1) categoriesButton(context),
          if (building.status == 2) SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          if (building.status == 2) surveyButton(context),
        ],
      ),
    );
  }

  Widget categoriesButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        color: Config.secondColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            MediaQuery.of(context).size.width * 0.02,
          ),
        ),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => BuildingSegmentsScreen(
              buildingId: building.id,
              buildingName: building.name,
            ),      
          );
        },
        child: Text(
          'Building segment',
          style: TextStyle(
            color: Colors.white,
            fontSize: Config.textSizeSmall,
          ),
        ),
      ),
    );
  }

  Widget buildingFloorButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        color: Config.secondColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            MediaQuery.of(context).size.width * 0.02,
          ),
        ),
        onPressed: () async {
          if (building.floors != null) {
            if (building.floors.length > 0) {
              listFloorPopup = building.floors.toList();
              await showDialog(
                context: context,
                builder: (context) => BuildingFloorPopup(),      
              );
              listFloorPopup.clear();
            } else {
              showToastMessage(Config.noFloorAvailableMessage);
            }
          } else {
            showToastMessage(Config.noFloorAvailableMessage);
          }
        },
        child: Text(
          'Building floor',
          style: TextStyle(
            color: Colors.white,
            fontSize: Config.textSizeSmall,
          ),
        ),
      ),
    );
  }

  Widget surveyButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        color: Config.secondColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            MediaQuery.of(context).size.width * 0.02,
          ),
        ),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          String buildingPrefs = prefs.getString(Config.draftUpdateBuilding + building.id.toString());
          if (buildingPrefs != null) {
            goToUpdateBuildingPage(building, building.id.toString());
          } else {
            goToUpdateBuildingPage(building, null);
          }
        },
        child: Text(
          'Survey building',
          style: TextStyle(
            color: Colors.white,
            fontSize: Config.textSizeSmall,
          ),
        ),
      ),
    );
  }

  Widget buildingBlocListener() {
    return BlocListener(
      bloc: _buildingBloc,
      listener: (BuildContext context,BuildingState state) async {
        if (state is LoadBuildingDetailsByIdFinishState) {
          setState(() {
            building = state.building;
            if (building.status == 1) {
              statusText = 'Surveyed';
              statusColor = Colors.green.withOpacity(0.1);
              statusBorderColor = Colors.green;
            } else if (building.status == 2) {
              statusText = 'Need survey';
              statusColor = Colors.yellow.withOpacity(0.1);
              statusBorderColor = Colors.yellow;
            } else if (building.status == 3) {
              statusText = 'Need approve';
              statusColor = Colors.grey.withOpacity(0.1);
              statusBorderColor = Colors.grey;
            }
            _isLoadingBuilding = true;
          });
        }
      },
      child: SizedBox(),
    );
  }

  void goToCategoryPage(int id, String name) async {
    dynamic rs = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => AnalysisScreen(buildingId: id, buildingName: name,)
      ),
    );
    
    if (rs != null) {
      if (rs) {
        showToast(Config.saveBuildingAnalysisSuccessMessage, true);
      }
    }
  }

  void goToUpdateBuildingPage(
    Building building, String shareNeedSurveyDraftPreferenceId
  ) async {
    dynamic rs;
    rs = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateBuildingScreen(
          buildingId: building.id,
          systemZoneCenter: null,
        )
      )
    );
    if (rs != null) {
      if (rs[1]) {
        if (rs[2]) {
          Navigator.pop(context, [false, true]);
        } else {
          Navigator.pop(context, [false, false]);
        }
      } else {
        if (rs[0]) {
          Navigator.pop(context, [true, true]);
        } else {
          showToast(Config.saveNeedSurveyDraftBuildingSuccessMessage, true);
        }
      }
    }
  }

  void showToast(String message,bool isSuccess) {
    Toast.show(
      message,
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.BOTTOM,
      backgroundColor: isSuccess ? Colors.greenAccent : Colors.redAccent,
      backgroundRadius: MediaQuery.of(context).size.width * 0.01,
    );
  }

  void showToastMessage(String message) {
    Toast.show(
      message,
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.BOTTOM,
      backgroundColor: Colors.grey[400],
      backgroundRadius: MediaQuery.of(context).size.width * 0.01,
    );
  }
}