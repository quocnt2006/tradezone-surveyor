import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:osm_map_surveyor/bloc/brand_bloc.dart';
import 'package:osm_map_surveyor/bloc/building_bloc.dart';
import 'package:osm_map_surveyor/bloc/city_bloc.dart';
import 'package:osm_map_surveyor/bloc/history_bloc.dart';
import 'package:osm_map_surveyor/bloc/segment_bloc.dart';
import 'package:osm_map_surveyor/bloc/store_bloc.dart';
import 'package:osm_map_surveyor/bloc/systemzone_bloc.dart';
import 'package:osm_map_surveyor/events/brand_event.dart';
import 'package:osm_map_surveyor/events/building_event.dart';
import 'package:osm_map_surveyor/events/city_event.dart';
import 'package:osm_map_surveyor/events/history_event.dart';
import 'package:osm_map_surveyor/events/segment_event.dart';
import 'package:osm_map_surveyor/events/store_event.dart';
import 'package:osm_map_surveyor/events/systemzone_event.dart';
import 'package:osm_map_surveyor/models/brand.dart';
import 'package:osm_map_surveyor/models/buiildingpolygon.dart';
import 'package:osm_map_surveyor/models/building.dart';
import 'package:osm_map_surveyor/models/buildingtypes.dart';
import 'package:osm_map_surveyor/models/district.dart';
import 'package:osm_map_surveyor/models/history.dart';
import 'package:osm_map_surveyor/models/segment.dart';
import 'package:osm_map_surveyor/models/store.dart';
import 'package:osm_map_surveyor/models/storepoint.dart';
import 'package:osm_map_surveyor/models/systemzone.dart';
import 'package:osm_map_surveyor/repositories/brand_repository.dart';
import 'package:osm_map_surveyor/repositories/building_repository.dart';
import 'package:osm_map_surveyor/repositories/city_repository.dart';
import 'package:osm_map_surveyor/repositories/history_repository.dart';
import 'package:osm_map_surveyor/repositories/segment_repository.dart';
import 'package:osm_map_surveyor/repositories/store_repository.dart';
import 'package:osm_map_surveyor/repositories/systemzone_repository.dart';
import 'package:osm_map_surveyor/states/brand_state.dart';
import 'package:osm_map_surveyor/states/building_state.dart';
import 'package:osm_map_surveyor/states/city_state.dart';
import 'package:osm_map_surveyor/states/history_state.dart';
import 'package:osm_map_surveyor/states/segment_state.dart';
import 'package:osm_map_surveyor/states/store_state.dart';
import 'package:osm_map_surveyor/states/systemzone_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/geojson_utils.dart';

List<BuildingType> initListBuildingTypes = new List<BuildingType>();
List<String> initListBuildingTypeNames = new List<String>();
List<Building> initListNeedSurveyBuildings = new List<Building>();
List<Brand> initListBrands = new List<Brand>();
List<String> initListBrandNames = new List<String>();
List<Store> initListNeedSurveyStores = new List<Store>();
List<Polygon> initListNeedSurveySystemZonePolygons = new List<Polygon>();
List<Polygon> initListNeedSurveySystemZoneForDrawPolygons = new List<Polygon>();
List<SystemZone> initListNeedSurveySystemZone = new List<SystemZone>();
List<Polygon> initListCampusPolygons = new List<Polygon>();
List<BuildingPolygon> initListNeedSurveyBuildingPolygons = new List<BuildingPolygon>();
List<Segment> initListSegments = new List<Segment>();
List<StorePoint> initListStorePointsOnMap = new List<StorePoint>();
List<History> initListHistory = new List<History>();
List<District> initListDistrict = new List<District>();

class LoadingPage extends StatefulWidget {
  LoadingPage({Key key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  BuildingBloc _buildingBloc;
  StoreBloc _storeBloc;
  BrandBloc _brandBloc;
  SystemZoneBloc _systemZoneBloc;
  SegmentBloc _segmentBloc;
  HistoryBloc _historyBloc;
  CityBloc _cityBloc;
  bool _isLoadBuildingTypes = false;
  bool _isLoadNeedSurveyBuilding = false;
  bool _isLoadBrands = false;
  bool _isLoadNeedSurveyStore = false;
  bool _isLoadNeedSurveySystemZoneOnMap = false;
  bool _isLoadNeedSurveyBuildingOnMap = false;
  bool _isLoadListSegments = false;
  bool _isLoadListNeedSurveyStorePointsOnMap = false;
  bool _isLoadListHistory = false;
  bool _isLoadListDistrict = false;
  bool _isLoadListCampus = false;

  @override
  void initState() { 
    super.initState();
    _buildingBloc = BuildingBloc(buildingRepository: BuildingRepository());
    _storeBloc = StoreBloc(storeRepository: StoreRepository());
    _brandBloc = BrandBloc(brandRepository: BrandRepository());
    _systemZoneBloc = SystemZoneBloc(systemZoneRepository: SystemZoneRepository());
    _segmentBloc = SegmentBloc(segmentRepository: SegmentRepository());
    _historyBloc = HistoryBloc(historyRepository: HistoryRepository());
    _cityBloc = CityBloc(cityRepository: CityRepository());
    _buildingBloc.add(LoadListBuildingTypes());
  }

  @override
  void dispose() {
    super.dispose();
    _brandBloc.close();
    _storeBloc.close();
    _buildingBloc.close();
    _systemZoneBloc.close();
    _segmentBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: body(context),
      ), 
      onWillPop: () {
        return;
      },
    );
  }

  Widget body(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Config.loadingBackgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            blocListenerWidet(),
            Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.175,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Config.thirdColor,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            )
          ],
        ),
      ),
    );
  }

  Widget blocListenerWidet() {
    return MultiBlocListener(
      listeners: [
        buildingBlocListener(),
        storeBlocListener(),
        brandBlocListener(),
        systemZoneBlocListener(),
        categoryBlocListener(),
        historyBlocListener(),
        cityBlocListener(),
      ],
      child: SizedBox(),
    );
  }

  Widget buildingBlocListener() {
    return BlocListener(
      bloc: _buildingBloc,
      listener: (BuildContext context,BuildingState state) async {
        if (state is LoadBuildingListTypesFinishState) {
          if (state.listTypes != null) {
            initListBuildingTypes = state.listTypes.toList();
            initListBuildingTypes.forEach((buildingType) {
              initListBuildingTypeNames.add(buildingType.name.toString());
            });
            _isLoadBuildingTypes = true;
            checkLoadingPage();
            _buildingBloc.add(LoadNeedSurveyBuildings());
          } else {
            Navigator.pop(context, false);
          }
        } else if (state is LoadNeedSurveyBuildingsFinishState) {
          if (state.listBuildings != null) {
            initListNeedSurveyBuildings = state.listBuildings.results.toList();
            _isLoadNeedSurveyBuilding = true;
            checkLoadingPage();
            _buildingBloc.add(LoadListNeedSurveyBuildingsMap());
          } else {
            Navigator.pop(context, false);
          }
        } else if (state is LoadListNeedSurveyBuildingsMapFinishState) {
          if (state.rs != null) {
            await getInitNeedSurveyBuildingPolygons(state.rs.toString());
            _isLoadNeedSurveyBuildingOnMap = true;
            checkLoadingPage();
            _storeBloc.add(LoadNeedSurveyStores());
          } else {
            Navigator.pop(context, false);
          }
        } else if (state is LoadCampusFinishDataState) {
          if (state.rs != null) {
            await getInitListCampusPolygons(state.rs.toString());
            _isLoadListCampus = true;
            checkLoadingPage();
          } else {
            Navigator.pop(context, false);
          }
        }
      },
      child: SizedBox(),
    );
  }

  Widget storeBlocListener() {
    return BlocListener(
      bloc: _storeBloc,
      listener: (BuildContext context,StoreState state) async {
        if (state is LoadNeedSurveyStoresFinishState) {
          if (state.listStores != null) {
            initListNeedSurveyStores = state.listStores.results.toList();
            _isLoadNeedSurveyStore = true;
            checkLoadingPage();
            _brandBloc.add(LoadBrands());
          } else {
            Navigator.pop(context, false);
          }
        } else if (state is LoadListNeedSurveyStoresMapFinishState) {
          if (state.rs != null) {
            await getInitStoreOnMapPoints(state.rs.toString()); 
            _isLoadListNeedSurveyStorePointsOnMap = true;
            checkLoadingPage();
            _historyBloc.add(LoadListHistory());
          } else {
            Navigator.pop(context, false);
          }
        }
      },
      child: SizedBox(),
    );
  }

  Widget brandBlocListener() {
    return BlocListener(
      bloc: _brandBloc,
      listener: (BuildContext context,BrandState state) {
        if (state is LoadBrandsFinishState) {
          if (state.listBrands != null) {
            initListBrands = state.listBrands.toList();
            initListBrands.forEach((brand) {
              initListBrandNames.add(brand.name.toString());
            });
            _isLoadBrands = true;
            checkLoadingPage();
            _systemZoneBloc.add(LoadNeedSurveySystemZoneMap());
          } else {
            Navigator.pop(context, false);
          }
        }
      },
      child: SizedBox(),
    );
  }

  Widget systemZoneBlocListener() {
    return BlocListener(
      bloc: _systemZoneBloc,
      listener: (BuildContext context,SystemZoneState state) async {
        if (state is LoadNeedSurveySystemZoneMapFinishState) {
          if (state.rs != null) {
            await getInitNeedSurveySystemZonePolygons(state.rs.toString());
            _isLoadNeedSurveySystemZoneOnMap = true;
            checkLoadingPage();
            _segmentBloc.add(LoadListSegments());
          } else {
            Navigator.pop(context, false);
          }
        }
      },
      child: SizedBox(),
    );
  }

  Widget categoryBlocListener() {
    return BlocListener(
      bloc: _segmentBloc,
      listener: (BuildContext context,SegmentState state) {
        if (state is LoadListSegmentsFinishState) {
          if (state.listSegments != null) {
            initListSegments = state.listSegments.toList();
            _isLoadListSegments = true;
            checkLoadingPage();
            _storeBloc.add(LoadListNeedSurveyStoresMap());
          } else {
            Navigator.pop(context, false);
          }
        }
      },
      child: SizedBox(),
    ); 
  }

  Widget historyBlocListener() {
    return BlocListener(
      bloc: _historyBloc,
      listener: (BuildContext context,HistoryState state) {
        if (state is LoadListHistoryFinishState) {
          if (state.listHistory != null) {
            initListHistory = state.listHistory.toList();
            _isLoadListHistory = true;
            checkLoadingPage();
            _cityBloc.add(LoadListDistrict());
          } else {
            Navigator.pop(context, false);
          }
        }
      },
    );
  }

  Widget cityBlocListener() {
    return BlocListener(
      bloc: _cityBloc,
      listener: (BuildContext context,CityState state) {
        if (state is LoadListDistrictFinishState) {
          if (state.listDistrict != null) {
            initListDistrict = state.listDistrict.toList();
            _isLoadListDistrict = true;
            checkLoadingPage();
            _buildingBloc.add(LoadCampus());
          } else {
            Navigator.pop(context, false);
          }
        }
      },
    );
  }

  checkLoadingPage() {
    if (
      _isLoadBuildingTypes && 
      _isLoadNeedSurveyBuilding && 
      _isLoadBrands && 
      _isLoadNeedSurveyStore && 
      _isLoadNeedSurveySystemZoneOnMap && 
      _isLoadNeedSurveyBuildingOnMap && 
      _isLoadListSegments && 
      _isLoadListNeedSurveyStorePointsOnMap && 
      _isLoadListHistory && 
      _isLoadListDistrict && 
      _isLoadListCampus
    ) {
      Navigator.pop(context, true);
    }
  }
}