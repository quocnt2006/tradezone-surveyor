import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:osm_map_surveyor/models/floor.dart';
import 'package:osm_map_surveyor/models/floorarea.dart';
import 'package:osm_map_surveyor/models/store.dart';
import 'package:osm_map_surveyor/screens/map/map_popup/building_popup/building_needsurvey_popup.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';

class BuildingFloorPopup extends StatefulWidget {
  BuildingFloorPopup({Key key}) : super(key: key);

  @override
  _BuildingFloorPopupState createState() => _BuildingFloorPopupState();
}

class _BuildingFloorPopupState extends State<BuildingFloorPopup> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.525,
          alignment: Alignment.topRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  'Buidling floor',
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
              floorsWidget(context),
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

  Widget floorsWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.45,
      child: ListView(
        children: [
          for (var i = 0; i < listFloorPopup.length; i++) 
            FloorWidget(floor: listFloorPopup[i], index: i,),
        ],
      ),
    );
  }
}

class FloorWidget extends StatefulWidget {
  final Floor floor;
  final int index;
  FloorWidget({Key key, this.floor, this.index}) : super(key: key);

  @override
  _FloorWidgetState createState() => _FloorWidgetState(this.floor, this.index);
}

class _FloorWidgetState extends State<FloorWidget> {
  Floor floor;
  int index;
  _FloorWidgetState(this.floor, this.index);
  bool _isShowFloorAreas = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        setState(() {
          if (_isShowFloorAreas) {
            _isShowFloorAreas = false;
          } else {
            if (floor.floorAreas.length > 0) {
              _isShowFloorAreas = true;
            } else {
              showToastMessage(context, Config.noFloorAreaAvailableMessage);
            }
          }
        });
      },
      child: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.01,
              ),
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: MediaQuery.of(context).size.width * 0.002,
                  color: Config.secondColor
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
                    width: MediaQuery.of(context).size.width * 0.1,
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
                      Config.floorSvgIcon,
                      color: Config.secondColor,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("Floor "),
                          Text(floor.name.toString()),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.1,
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
                    child: _isShowFloorAreas ? Icon(Icons.keyboard_arrow_down) : Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
            if (_isShowFloorAreas) 
              for (var i = 0; i < floor.floorAreas.length; i++)
                FloorAreaWidget(floorArea: floor.floorAreas[i], index: i,),
          ],
        ),
      ),
    );
  }
}

class FloorAreaWidget extends StatefulWidget {
  final FloorArea floorArea;
  final int index;
  FloorAreaWidget({Key key, this.floorArea, this.index}) : super(key: key);

  @override
  _FloorAreaWidgetState createState() => _FloorAreaWidgetState(this.floorArea, this.index);
}

class _FloorAreaWidgetState extends State<FloorAreaWidget> {
  FloorArea floorArea;
  int index;
  _FloorAreaWidgetState(this.floorArea, this.index);

  bool _isShowStore = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          FlatButton(
            onPressed: () {
              setState(() {
                if (_isShowStore) {
                  _isShowStore = false;
                } else {
                  if (floorArea.stores.length > 0) {
                    _isShowStore = true;
                  } else {
                    showToastMessage(context, Config.noStorevailableMessage);
                  }
                }
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.01,
              ),
              width: MediaQuery.of(context).size.width,
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
                    width: MediaQuery.of(context).size.width * 0.075,
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
                      Config.areaSvgIcon,
                      color: Config.secondColor,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("Area"),
                          Text(floorArea.name),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.075,
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
                    child: _isShowStore ? Icon(Icons.arrow_downward) : Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ),
          if (_isShowStore) 
              for (var i = 0; i < floorArea.stores.length; i++)
                storeWidget(context, floorArea.stores[i]),
        ],
      ),
    );
  }

  Widget storeWidget(BuildContext context, Store store) {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.06,
        right: MediaQuery.of(context).size.width * 0.06,
        bottom: MediaQuery.of(context).size.height * 0.01,
      ),
      height: MediaQuery.of(context).size.height * 0.05,
      decoration: BoxDecoration(
        color: Config.thirdColor,
        border: Border.all(
          width: MediaQuery.of(context).size.width * 0.002,
          color: Config.secondColor,
        ),
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.01),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.1,
            height: MediaQuery.of(context).size.height * 0.05,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Config.firstColor,
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
            child: store.imageUrl == null
              ? SvgPicture.asset(
                Config.shopSvgIcon,
                color: Config.secondColor,
              )
              : Image.network(store.imageUrl),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.02,
              ),
              child: store.name == null
                ? Text("No name")
                : store.name.isEmpty
                  ? Text("No name")
                  : store.name.length > 43
                    ? Tooltip(
                      message: store.name,
                      child: Text(store.name.substring(0, 40) + "..."),
                    )
                    : Text(store.name),
            ),
          ),
        ],
      ),
    );
  }
}