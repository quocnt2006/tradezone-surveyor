import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_map_surveyor/bloc/brand_bloc.dart';
import 'package:osm_map_surveyor/events/brand_event.dart';
import 'package:osm_map_surveyor/models/brand.dart';
import 'package:osm_map_surveyor/models/store.dart';
import 'package:osm_map_surveyor/repositories/brand_repository.dart';
import 'package:osm_map_surveyor/screens/drawer/drawer_view.dart';
import 'package:osm_map_surveyor/screens/storegeneral/updatestore/update_store_screen.dart';
import 'package:osm_map_surveyor/states/brand_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/popup_utils.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';

class BrandStoresScreen extends StatefulWidget {
  final Brand brand;
  BrandStoresScreen({Key key, this.brand}) : super(key: key);

  @override
  _BrandStoresScreenState createState() => _BrandStoresScreenState(this.brand);
}

class _BrandStoresScreenState extends State<BrandStoresScreen> {
  Brand brand;
  _BrandStoresScreenState(this.brand);

  BrandBloc _brandBloc;
  List<Store> _listStore = new List<Store>();
  bool _isLoading;

  @override
  void initState() { 
    super.initState();
    _brandBloc = new BrandBloc(brandRepository: BrandRepository());
    _brandBloc.add(LoadBrandStores(id: brand.id));
    _isLoading = true;
  }

  @override
  void dispose() { 
    _brandBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: body(context),
      endDrawer: appEndDrawer(context),
    );
  }

  Widget body(BuildContext context) {
    return Stack(
      children: [
        brandBlocListenerWidget(),
        CustomScrollView(
          slivers: [
            // Add the app bar to the CustomScrollView.
            SliverAppBar(
              // Provide a brand header title.
              actions: [
                brandHeaderWidget(context)
              ],
              floating: true,
              // Display a placeholder widget to visualize the shrinking size.
              //flexibleSpace: Placeholder(),
              toolbarHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            listStoreWidget(context),
          ],
        ),
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

  Widget brandBlocListenerWidget() {
    return BlocListener(
      bloc: _brandBloc,
      listener: (context, state) {
        if (state is LoadBrandStoresFinishState) {
          setState(() {
            if (state.listStores != null) {
              _listStore = state.listStores.toList();
              _isLoading = false;
            } else {
              PopupUtils.utilShowLoginDialog(Config.loadingBrandStoreFail, Config.loadingBrandStoreFailBody, context);
            }
          });
        }
      },
      child: SizedBox(),
    );
  }

  Widget brandHeaderWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            brand.imageUrl,
          ),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.075,
            child: Row(
              children: [
                Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.075,
                  width: MediaQuery.of(context).size.height * 0.075,
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.005,
                  ),
                  child: Image.network(
                    brand.iconUrl,
                  ),
                ),
                Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.075,
                  width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.height * 0.075,
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.015,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand.name.toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: Config.textSizeSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        brand.segmentName.toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: Config.textSizeSuperSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget listStoreWidget(BuildContext context) {
    return !_isLoading 
      ? _listStore.length > 0
        ? SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return storeWidget(context, index);
            },
            childCount: _listStore.length,
          ),
        )
        : SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Text(
                  'No store available',
                  style: TextStyle(
                    fontSize: Config.textSizeSmall,
                  )
                ),
              );
            },
            childCount: 1,
          ),
        )
      : SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return loadingWidget(context);
          },
          childCount: 1,
        ),
      );
  }

  Widget storeWidget(BuildContext context,int index) {
    return GestureDetector(
      onTap: () {
        goToUpdateStorePage(_listStore[index].id);
      },
      child: Container(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.025,
          right: MediaQuery.of(context).size.width * 0.025,
          top: MediaQuery.of(context).size.height * 0.01,
        ),
        height: MediaQuery.of(context).size.height * 0.125,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black26,
            width: MediaQuery.of(context).size.height * 0.001,
          ),
          borderRadius: BorderRadius.circular(
            MediaQuery.of(context).size.width * 0.02,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 1.25,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.65,
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
                    height: MediaQuery.of(context).size.height * 0.125,
                    width: MediaQuery.of(context).size.width * 0.125,
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.02,
                    ),
                    child: _listStore[index].imageUrl != null 
                      ? Image.network(_listStore[index].imageUrl)
                      : Image.network(brand.iconUrl),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.125,
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.025,
                      right: MediaQuery.of(context).size.width * 0.025,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Tooltip(
                          message: _listStore[index].name.toString(),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Text(
                              _listStore[index].name.toString().length > 35 
                                ? _listStore[index].name.toString().substring(0, 32) + '...'
                                : _listStore[index].name.toString(),
                              style: TextStyle(
                                fontSize: Config.textSizeMedium * 0.65,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Text(
                            _listStore[index].type.toString(),
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
              width: MediaQuery.of(context).size.width * 0.25,
              height: MediaQuery.of(context).size.height * 0.125,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.05,
                bottom: MediaQuery.of(context).size.width * 0.05,
              ),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    setStatus(_listStore[index].status),
                    style: TextStyle(
                      color: setColorStatus(_listStore[index].status),
                      fontStyle: FontStyle.italic,
                    )
                  ),
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

  Color setColorStatus(int status) {
    if (status == 1) {
      return Colors.green;
    } else if (status == 2) {
      return Colors.red;
    } else if (status == 3) {
      return Colors.yellow;
    } else {
      return Colors.yellow;
    }
  }

  String setStatus(int status) {
    if (status == 1) {
      return 'Surveyed';
    } else if (status == 2) {
      return 'Need survey';
    } else if (status == 3){
      return 'Need approve';
    } else {
      return 'Waiting update';
    }
  }

  void goToUpdateStorePage(
    int storeId
  ) async {
    dynamic rs;
    rs = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateStoreScreen(
          storeId: storeId,
        )
      )
    );
    if (rs != null) {
      if (rs[1]) {
        setState(() {
          _isLoading = false;
        });
        _brandBloc.add(LoadBrandStores(id: brand.id));
        if (rs[2]) {
          showToast(context, Config.deleteStoreSuccessMessage, true);
        } else {
          showToast(context, Config.deleteStoreFailMessage, false);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        _brandBloc.add(LoadBrandStores(id: brand.id));
        if (rs[0]) {
          showToast(context, Config.updateNeedSurveyStoreSuccessMessage, true);
        }
      }
    }
  }
}