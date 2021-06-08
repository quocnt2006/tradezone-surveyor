import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/screens/sign_in_page.dart';
import 'package:flutter/services.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Map-based Tradezone Surveyor',
      theme: ThemeData(
        primaryColor: Config.secondColor,
        fontFamily: 'OpenSans',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primarySwatch: Config.swatchTimePickerColor,
      ),
      home: LoginScreen(),
    );
  }
}
