import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:osm_map_surveyor/behaviorsubject/floor_behavior.dart';
import 'package:osm_map_surveyor/models/floorarea.dart';
import 'package:osm_map_surveyor/models/floor.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/building/floor/floorareas/create_floor_area_page.dart';
import 'package:osm_map_surveyor/screens/buildinggeneralpage/building/floor/floorareas/update_floor_area_page.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';

class CreateFloorPage extends StatefulWidget {
  final bool isAddFloor;
  CreateFloorPage({Key key, this.isAddFloor}) : super(key: key);

  @override
  _CreateFloorPageState createState() => _CreateFloorPageState(this.isAddFloor);
}

class _CreateFloorPageState extends State<CreateFloorPage> {
  bool isAddFloor;
  _CreateFloorPageState(this.isAddFloor);

  TextEditingController _nameTextController = TextEditingController();
  FloorBehavior _floorBehavior = FloorBehavior();
  bool _isShowFloorAreas = false;
  List<FloorArea> floorAreas;
  Floor floor = Floor();

  @override
  void initState() {
    super.initState();
    _nameTextController.addListener(
      () {
        _floorBehavior.nameSink.add(_nameTextController.text);
      }
    );
    _floorBehavior.nameSink.add(_nameTextController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: body(context),
    );
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _floorBehavior.dispose();
    super.dispose();
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
          Navigator.pop(context);
        },
      ),
      backgroundColor: Config.secondColor,
      title: Container(
        child: Text(
          isAddFloor? 'Add floor' : 'Add basement',
          style: TextStyle(
            fontSize: Config.textSizeMedium,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.01,
          ),
          child: Column(
            children: <Widget>[
              floorNameTextField(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
              listFloorAreasButton(context),
              listFloorsWidget(context),
            ],
          ),
        ),
        submitButton(context),
      ],
    );
  }

  Widget floorNameTextField(BuildContext context) {
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
              stream: _floorBehavior.nameStream,
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
                    hintText: isAddFloor? "Input the floor name" : "Input the basement name",
                    errorText: snapshot.data,
                  ),
                  controller: _nameTextController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget submitButton(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.065,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.02
      ),
      child: StreamBuilder(
        stream: _floorBehavior.nameStream,
        builder: (context, snapshot) {
          return RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
            ),
            color: Config.secondColor,
            disabledColor: Config.secondColor.withOpacity(0.5),
            onPressed: snapshot.data == null? 
            () {
              floor.id = 0;
              floor.name = _nameTextController.text;
              floor.floorAreas = floorAreas;
              Navigator.pop(context, floor);
            } : null,
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
                  isAddFloor? "Add floor" : "Add basement",
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

  Widget listFloorAreasButton(BuildContext context) {
    return FlatButton(
      onPressed: () {
        setState(() {
          if (_isShowFloorAreas) {
            _isShowFloorAreas = false;
          } else {
            _isShowFloorAreas = true;
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
                Config.areaSvgIcon,
                color: Config.secondColor,
              ),
            ),
            Expanded(
              child: Text(
                "Floor Areas",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Config.textSizeSuperSmall,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              child: floorAreas != null ? 
                Text(floorAreas.length.toString() + (floorAreas.length < 2 ? " floor area" : " floor areas"))
                : Text('0 floor area'),
            ),
            _isShowFloorAreas ? 
              Icon(
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

  Widget listFloorsWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(),
      child: _isShowFloorAreas ? 
        Column(
          children: <Widget>[
            if (floorAreas != null)
              for (var i = 0; i < floorAreas.length; i++)
                floorAreaWidget(context, floorAreas[i], i),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
            addFloorAreaButton(context),
          ],
        ) : SizedBox(),
    );
  }

  Widget addFloorAreaButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.05,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: RaisedButton(
        onPressed: () {
          goToCreateFloorAreaPage();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
        ),
        color: Config.secondColor,
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.1,
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            Text(
              "Add floor area",
              style: TextStyle(
                fontSize: Config.textSizeSuperSmall,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget floorAreaWidget(BuildContext context, FloorArea floorArea, int index) {
    return FlatButton(
      onPressed: () {
        goToUpdateFloorAreaPage(floorArea, index);
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.01,
        ),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.06,
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
                    Text(floorArea.name),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void goToCreateFloorAreaPage() async {
    final rs = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => CreateFloorAreaPage()
      )
    );
    if (rs != null) {
      setState(() {
        if (floorAreas == null) {
          floorAreas = new List<FloorArea>();
        }
        floorAreas.add(rs);
        showToast(context, Config.addFloorAreaSuccessMessage, true);
      });
    }
  }

  void goToUpdateFloorAreaPage(FloorArea floorArea, int index) async {
    final rs = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => 
        UpdateFloorAreaPage(
          floorArea: floorArea,
          isEditable: true,
        )
      )
    );
    if (rs != null) {
      setState(() {
        if(rs[0]) {
          floorAreas[index] = rs[1];
          showToast(context, Config.updateFloorAreaSuccessMessage, true);
        } else {
          floorAreas.removeAt(index);
          showToast(context, Config.deleteFloorAreaSuccessMessage, true);
        }
      });
    }
  }
}
