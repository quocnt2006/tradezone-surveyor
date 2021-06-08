import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_map_surveyor/bloc/building_bloc.dart';
import 'package:osm_map_surveyor/events/building_event.dart';
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/repositories/building_repository.dart';
import 'package:osm_map_surveyor/screens/map/map_general_page.dart';
import 'package:osm_map_surveyor/states/building_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';

class BuildingDetailsPopup extends StatefulWidget {
  BuildingDetailsPopup({Key key}) : super(key: key);

  @override
  _BuildingDetailsPopupState createState() => _BuildingDetailsPopupState();
}

class _BuildingDetailsPopupState extends State<BuildingDetailsPopup> {
  Building building;
  String statusText = 'Only read';
  Color statusColor = Colors.grey.withOpacity(0.1);
  Color statusBorderColor = Colors.grey;

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
    super.dispose();
    _buildingBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            buildingBlocListener(),
            if (!_isLoadingBuilding) loadingWidget(context),
            if (_isLoadingBuilding) buildingDetails(context),
          ],
        ),
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
              'Address : ' +  (building.address == null ? 'No data available' : building.address.toString()),
            )
          ),
        ],
      ),
    );
  }

  Widget buildingBlocListener() {
    return BlocListener(
      bloc: _buildingBloc,
      listener: (BuildContext context,BuildingState state) {
        if (state is LoadBuildingDetailsByIdFinishState) {
          setState(() {
            building = state.building;
            _isLoadingBuilding = true;
          });
        }
      },
      child: SizedBox(),
    );
  }

  void goToCategoryPage() {

  }
}