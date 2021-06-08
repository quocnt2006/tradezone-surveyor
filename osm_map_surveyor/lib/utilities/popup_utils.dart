import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';

class PopupUtils {
  static utilShowMessageDialog(
      String header, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(MediaQuery.of(context).size.width * 0.02),
          )
        ),
        title: new Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height * 0.055,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(MediaQuery.of(context).size.width * 0.02),
              topRight: Radius.circular(MediaQuery.of(context).size.width * 0.02),
            ),
            color: Config.secondColor,
          ),
          child: Text(
            header,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: Config.textSizeSmall, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            textColor: Config.secondColor,
            padding: EdgeInsets.all(8.0),
            splashColor: Config.secondColor,
            child: Text(Config.okButtonPopup),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  static utilShowLoginDialog(String header, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(MediaQuery.of(context).size.width * 0.02),
          )
        ),
        title: new Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height * 0.055,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(MediaQuery.of(context).size.width * 0.02),
              topRight: Radius.circular(MediaQuery.of(context).size.width * 0.02),
            ),
            color: Colors.redAccent,
          ),
          child: Text(
            header,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: Config.textSizeSmall),
            textAlign: TextAlign.center,
          ),
        ),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            textColor: Config.secondColor,
            padding: EdgeInsets.all(8.0),
            splashColor: Config.secondColor,
            child: Text(Config.okButtonPopup),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
