import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:osm_map_surveyor/provider/authentication_provider.dart';
import 'package:osm_map_surveyor/screens/brandscreen/brandstoresscreen/brand_stores_screen.dart';
import 'package:osm_map_surveyor/screens/drawer/drawer_view.dart';
import 'package:osm_map_surveyor/screens/loadingpage/loading_page.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';

class BrandScreen extends StatefulWidget {
  @override
  _BrandScreenState createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() { 
    super.initState();
  }

  @override
  void dispose() { 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(context),
      endDrawer: appEndDrawer(context),
      body: body(context),
    );
  }

  Widget appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(
        color: Config.iconThemeColor,
      ),
      backgroundColor: Config.secondColor,
      title: Container(
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.025,
              ),
              width: MediaQuery.of(context).size.width * 0.1,
              child: Image.asset(
                Config.logoOfficialPng,
              ),
            ),
            Expanded(
              child: Text(
                'Surveyor',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: Config.textSizeSmall * 1.1,
                ),
              ),
            )
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
              openEndDrawer();
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

  Widget body(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return brandWidget(context, index);
            },
            childCount: initListBrands.length,
          ),
        ),
      ],
    ); 
  }

  Widget brandWidget(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, 
          MaterialPageRoute(builder: (context) => 
            BrandStoresScreen(brand: initListBrands[index],)
          )
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Config.secondColor,
              width: MediaQuery.of(context).size.height * 0.005,
            ),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.135,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.125,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.05,
                bottom: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.height * 0.065,
                    child: initListBrands[index].iconUrl != null
                      ? initListBrands[index].iconUrl.isNotEmpty 
                        ? CircleAvatar(
                          backgroundImage: NetworkImage(
                            initListBrands[index].iconUrl.trim().toString(),
                          ),
                        )
                        : Icon(Icons.local_offer_rounded)
                      : Icon(Icons.local_offer_rounded),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Tooltip(
                          message: initListBrands[index].name,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Text(
                              initListBrands[index].name.length > 18 ? initListBrands[index].name.substring(0, 16) + '...': initListBrands[index].name,
                              style: TextStyle(
                                fontSize: Config.textSizeMedium * 0.675,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Text(
                            initListBrands[index].segmentName,
                            style: TextStyle(
                              fontSize: Config.textSizeSuperSmall,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.125,
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
                top: MediaQuery.of(context).size.width * 0.05,
                bottom: MediaQuery.of(context).size.width * 0.05,
              ),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Go to details',
                    style: TextStyle(
                      fontSize: Config.textSizeSuperSmall,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios, 
                    size: Config.textSizeSuperSmall,
                    color: Config.redColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }
}