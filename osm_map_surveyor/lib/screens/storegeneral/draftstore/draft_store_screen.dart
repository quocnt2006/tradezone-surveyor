import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:osm_map_surveyor/models/store.dart';
import 'package:osm_map_surveyor/screens/storegeneral/createstore/create_store_screen.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geodesy/geodesy.dart';

class DraftStoreScreen extends StatefulWidget {
  final LatLng systemZoneCenter;

  const DraftStoreScreen({Key key, this.systemZoneCenter}) : super(key: key);
  
  @override
  _DraftStoreScreenState createState() => _DraftStoreScreenState(this.systemZoneCenter);
}

class _DraftStoreScreenState extends State<DraftStoreScreen> {
  LatLng systemZoneCenter;
  _DraftStoreScreenState(this.systemZoneCenter);

  List<Store> listDraftStores;

  @override
  void initState() { 
    super.initState();
    initDraftStores();
  }

  void initDraftStores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        int i = 1;
        bool isNotFound = false;
        while (!isNotFound) {
          String storePrefs = prefs.getString(Config.draftStore + i.toString());
          if (storePrefs == null) {
            isNotFound = true;
          } else {
            if (listDraftStores == null) {
              listDraftStores = [];
            }
            Store tmp = Store.fromJson(jsonDecode(storePrefs));
            listDraftStores.add(tmp);
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
                'Draft store',
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
                  return listDraftStores != null
                    ? _storeWidget(context, index)
                    : _noDraftStoreWidget(context);
                },
                childCount: listDraftStores != null ? listDraftStores.length : 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _storeWidget(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _goToCreateStorePage(index);
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
              child: listDraftStores[index].imageUrl == null
                ? SvgPicture.asset(
                    Config.shopSvgIcon,
                    color: Config.secondColor,
                  )
                : Image.network(listDraftStores[index].imageUrl),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.02,
                ),
                child: listDraftStores[index].name == null
                  ? Text("No name")
                  : listDraftStores[index].name.isEmpty
                    ? Text("No name")
                    : listDraftStores[index].name.length > 43
                      ? Tooltip(
                          message: listDraftStores[index].name,
                          child: Text(listDraftStores[index].name.substring(0, 40) + "..."),
                        )
                      : Text(listDraftStores[index].name),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _noDraftStoreWidget(BuildContext context) {
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
              'No draft store available!',
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _goToCreateStorePage(int index) async {
    final prefs = await SharedPreferences.getInstance();
    dynamic rs = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => CreateStoreScreen(
          initStore: listDraftStores[index],
          sharePreferenceId: (index+1).toString(),
          systemZoneCenter: systemZoneCenter,
        )
      )
    );

    if (rs != null) {
      setState(() {
        listDraftStores = null;
        int i = 1;
        bool isNotFound = false;
        while (!isNotFound) {
          String storePrefs = prefs.getString(Config.draftStore + i.toString());
          if (storePrefs == null) {
            isNotFound = true;
          } else {
            if (listDraftStores == null) {
              listDraftStores = [];
            }
            Store tmp = Store.fromJson(jsonDecode(storePrefs));
            listDraftStores.add(tmp);
            i += 1;
          }
        }
      });
      if (rs[1]) {
      } else {
        if (rs[0]) {
          Navigator.pop(context, true);
        } else {
          showToast(context, Config.saveDraftStoreSuccessMessage, true);
        }
      }
    }
  }
}