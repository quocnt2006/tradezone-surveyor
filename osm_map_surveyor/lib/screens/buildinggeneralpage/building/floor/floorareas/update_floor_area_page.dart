import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/behaviorsubject/floor_area_behavior.dart';
import 'package:osm_map_surveyor/models/floorarea.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';

class UpdateFloorAreaPage extends StatefulWidget {
  final FloorArea floorArea;
  final bool isEditable;
  UpdateFloorAreaPage({Key key, this.floorArea, this.isEditable}) : super(key: key);

  @override
  _UpdateFloorAreaPageState createState() => _UpdateFloorAreaPageState(this.floorArea, this.isEditable);
}

class _UpdateFloorAreaPageState extends State<UpdateFloorAreaPage> {
  FloorArea initFloorArea;
  bool isEditable;
  _UpdateFloorAreaPageState(this.initFloorArea, this.isEditable);

  final _nameTextController = TextEditingController();
  FloorAreaBehavior _floorAreaBehavior = FloorAreaBehavior();

  @override
  void initState() {
    super.initState();
    _nameTextController.addListener(() {
      _floorAreaBehavior.nameFloorAreaSink.add(_nameTextController.text);
    });
    _floorAreaBehavior.nameFloorAreaSink.add(_nameTextController.text);
    initFloorAreaFunction();
  }

  void initFloorAreaFunction() {
    if (initFloorArea != null) {
      _nameTextController.text = initFloorArea.name;
      _floorAreaBehavior.nameFloorAreaSink.add(_nameTextController.text);
    }
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
    _floorAreaBehavior.dispose();
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
      title: Center(
        child: Text(
          isEditable? 'Update floor area' : 'Floor area',
          style: TextStyle(fontSize: Config.textSizeMedium, color: Colors.white,),
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
              floorAreaNameTextField(context),
            ],
          ),
        ),
        if (isEditable) footerWidget(context),
      ],
    );
  }

  Widget floorAreaNameTextField(BuildContext context) {
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
          isEditable 
            ? Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              child: StreamBuilder(
                stream: _floorAreaBehavior.nameFloorAreaStream,
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
                      hintText: "Input the floor area name",
                      errorText: snapshot.data,
                    ),
                    controller: _nameTextController,
                  );
                },
              ),
            )
            : Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                initFloorArea.name != null ? initFloorArea.name.toString() : 'Not available',
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget footerWidget(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          deleteButton(context),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.02,
          ),
          updateButton(context),
        ],
      ),
    );
  }

  Widget deleteButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.475,
      height: MediaQuery.of(context).size.height * 0.065,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
        ),
        color: Config.secondColor,
        onPressed: () {
          showDeleteFloorAreaDialog(Config.deleteFloorAreaHeader, Config.deleteFloorAreaBody, context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.1,
              child: Icon(
                Icons.cancel_outlined,
                color: Colors.white,
                size: MediaQuery.of(context).size.width * 0.06,
              ),
            ),
            Text(
               "Delete",
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

  Widget updateButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.475,
      height: MediaQuery.of(context).size.height * 0.065,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.01,
        right: MediaQuery.of(context).size.width * 0.01,
      ),
      child: StreamBuilder(
        stream: _floorAreaBehavior.nameFloorAreaStream,
        builder: (context, snapshot) {
          return RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
            ),
            color: Config.secondColor,
            onPressed: snapshot.data == null ? () {
              FloorArea floorArea = FloorArea();
              floorArea.id = initFloorArea.id;
              floorArea.name = _nameTextController.text;
              Navigator.pop(context, [true, floorArea]);
            } : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Icon(
                    Icons.update,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                ),
                Text(
                  "Update",
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

  void showDeleteFloorAreaDialog(String header, String message, BuildContext context) {
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
              Navigator.pop(context, [false, null]);
            },
          ),
        ],
      ),
    );
  }
}
