import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:osm_map_surveyor/screens/brandscreen/brand_screen.dart';
import 'package:osm_map_surveyor/screens/map/map_general_page.dart';
import 'package:osm_map_surveyor/screens/systemzonescreen/systemzone_screen.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/popup_utils.dart';
import 'package:osm_map_surveyor/screens/historyscreen/history_screen.dart';
final FirebaseMessaging fcm = FirebaseMessaging();
class GeneralPage extends StatefulWidget {
  final int index;
  GeneralPage({Key key, this.index}) : super(key: key);

  @override
  _GeneralPageState createState() => _GeneralPageState(index);
}
class _GeneralPageState extends State<GeneralPage> {
  static List<Widget> _widgetOptions = <Widget>[
    SystemzoneScreen(),
    BrandScreen(),
    HistoryScreen(),
    MapGeneralPage(),
  ];
  int initIndex;
  _GeneralPageState(this.initIndex);
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        PopupUtils.utilShowMessageDialog(
          message['notification']['title'],
          message['notification']['body'],
          context
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    if (this.initIndex != null) _onItemTapped(this.initIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: Config.textSizeSmall,
        unselectedItemColor: Config.secondColor.withOpacity(0.4),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'System zone',
            icon: Icon(Icons.settings_applications_rounded),
          ),
          BottomNavigationBarItem(
            label: 'Brand',
            icon: Icon(Icons.local_offer_sharp),
          ),
          BottomNavigationBarItem(
            label: 'History',
            icon: Icon(Icons.history),
          ),
          BottomNavigationBarItem(
            label: 'Map',
            icon: Icon(Icons.map),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Config.secondColor,
        backgroundColor: Config.secondColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
