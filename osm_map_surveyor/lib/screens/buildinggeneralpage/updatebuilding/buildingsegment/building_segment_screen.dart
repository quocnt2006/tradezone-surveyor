import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:osm_map_surveyor/bloc/building_bloc.dart';
import 'package:osm_map_surveyor/events/building_event.dart';
import 'package:osm_map_surveyor/models/buildinganalysis.dart';
import 'package:osm_map_surveyor/provider/authentication_provider.dart';
import 'package:osm_map_surveyor/repositories/building_repository.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/updatebuilding/buildingsegment/analysis_screen.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/updatebuilding/buildingsegment/segment_widget.dart';
import 'package:osm_map_surveyor/screens/drawer/drawer_view.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/states/building_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';

List<BuildingAnalysis> listBuildingAnalysises;

class BuildingSegmentsScreen extends StatefulWidget {
  final int buildingId;
  final String buildingName;
  BuildingSegmentsScreen({Key key, this.buildingId, this.buildingName}) : super(key: key);

  @override
  _BuildingSegmentsScreenState createState() => _BuildingSegmentsScreenState(this.buildingId, this.buildingName);
}

class _BuildingSegmentsScreenState extends State<BuildingSegmentsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int buildingId;
  String buildingName;
  _BuildingSegmentsScreenState(this.buildingId, this.buildingName);

  BuildingBloc _buildingBloc;
  bool _isLoadingSegments;
  bool _isDeleting;
  bool _isCanCreateSegment;

  @override
  void initState() { 
    super.initState();
    _buildingBloc = BuildingBloc(buildingRepository: BuildingRepository());
    _buildingBloc.add(LoadListBuildingAnalysis(id: buildingId));
    _isLoadingSegments = false;
    listBuildingAnalysises = new List<BuildingAnalysis>();
    _isDeleting = false;
    _isCanCreateSegment = true;
  }
  
  @override
  void dispose() { 
    _buildingBloc.close();
    listBuildingAnalysises.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: appEndDrawer(context),
      appBar: appBar(context),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              buildingBlocListner(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              if (!_isLoadingSegments) loadingWidget(context),
              if (_isLoadingSegments) bodyDetails(context),
              if (_isLoadingSegments && _isCanCreateSegment) saveButton(context),
            ],
          ),
        ),
      ),
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
          Navigator.of(context).pop();
        },
      ), 
      backgroundColor: Config.secondColor,
      title: Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Building Segments',
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
              _openEndDrawer();
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
  
  Widget buildingBlocListner() {
    return BlocListener(
      bloc: _buildingBloc,
      listener: (BuildContext context,BuildingState state) {
        if (state is LoadListBuildingAnalysisFinishState) {
          setState(() {
            listBuildingAnalysises.clear();
            state.listBuildingAnalysis.length == initListSegments.length ? _isCanCreateSegment = false : _isCanCreateSegment = true;
            listBuildingAnalysises = state.listBuildingAnalysis.toList();
            _isLoadingSegments = true;
            _isDeleting = false;
          });
        } else if (state is DeleteBuildingAnalysisState) {
          setState(() {
            showToast(context, Config.deleteSegmentSuccessMessage, true);
            _buildingBloc.add(LoadListBuildingAnalysis(id: buildingId));
          });
        }
      },
      child: SizedBox(),
    );
  }

  Widget bodyDetails(BuildContext context) {
    return Container(
      child: Column(
        children: [
          for(int i = 0; i < listBuildingAnalysises.length; i++) 
            Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.01,
              ),
              child: Stack(
                
                children: [
                  SegmentWidget(index: i,),
                  deleteButton(context, listBuildingAnalysises[i]),
                ],
              ),
            ),
          if (_isLoadingSegments && listBuildingAnalysises.length == 0) Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.2,
              bottom: MediaQuery.of(context).size.height * 0.2,
            ),
            child: Text(
              'No building segments',
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
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
        top: MediaQuery.of(context).size.height * 0.01,
      ),
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: RaisedButton(
        onPressed: () {
          _goToSegmentBuilding();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
        ),
        color: Config.secondColor,
        disabledColor: Config.secondColor.withOpacity(0.5),
        child: Row(
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
              "Create segment",
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

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  void _goToSegmentBuilding() async {
    dynamic rs = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => AnalysisScreen(buildingId: buildingId, buildingName: buildingName,))
    );

    if (rs != null) {
      _isLoadingSegments = false;
      listBuildingAnalysises.clear();
      showToast(context, Config.createSegmentSuccessMessage, true);
      _buildingBloc.add(LoadListBuildingAnalysis(id: buildingId));
    }
  }

  Widget deleteButton(BuildContext context, BuildingAnalysis buildingAnalysis) {
    return Positioned(
      right: MediaQuery.of(context).size.width * 0.065,
      top: MediaQuery.of(context).size.height * 0.004,
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.12,
        height: MediaQuery.of(context).size.width * 0.1,
        child: IconButton(
          onPressed: () async {
            if(!_isDeleting) await showDeleteBuildingAnalysisDialog(
              Config.deleteBuildingCategoryHeader, 
              Config.deleteBuildingCategoryMessage, 
              context,
              buildingAnalysis.buildingId, 
              buildingAnalysis.segmentId
            );
          },
          color: Colors.redAccent,
          icon: Icon(Icons.delete_forever, size: MediaQuery.of(context).size.width * 0.075,),
        ),
      ),
    );
  }

  showDeleteBuildingAnalysisDialog(String header, String message, BuildContext context, int buildingId, int categoryId) {
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
              setState(() {
                _buildingBloc.add(DeleteBuildingAnalysis(buildingId: buildingId, categoryId: categoryId));
                _isDeleting = true;
              });
            },
          ),
        ],
      ),
    );
  }
}