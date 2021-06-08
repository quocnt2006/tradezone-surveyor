import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osm_map_surveyor/bloc/store_bloc.dart';
import 'package:osm_map_surveyor/events/store_event.dart';
import 'package:osm_map_surveyor/models/store.dart';
import 'package:osm_map_surveyor/repositories/store_repository.dart';
import 'package:osm_map_surveyor/screens/map/map_general_page.dart';
import 'package:osm_map_surveyor/states/store_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';
import 'package:osm_map_surveyor/utilities/utilities.dart';

class StoreDetailsPopup extends StatefulWidget {
  StoreDetailsPopup({Key key}) : super(key: key);

  @override
  _StoreDetailsPopupState createState() => _StoreDetailsPopupState();
}

class _StoreDetailsPopupState extends State<StoreDetailsPopup> {
  Store store;
  String statusText = 'Only read';
  Color statusColor = Colors.grey.withOpacity(0.1);
  Color statusBorderColor = Colors.grey;

  StoreBloc _storeBloc;
  bool _isLoadingStore = false;

  @override
  void initState() { 
    super.initState();
    _storeBloc = StoreBloc(storeRepository: StoreRepository());
    _storeBloc.add(LoadStoreById(id: storePopupId));
  }

  @override
  void dispose() {
    _storeBloc.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.525,
          child: Column(
            children: [
              storeBlocListener(),
              if (!_isLoadingStore) loadingWidget(context),
              if (_isLoadingStore) storeDetails(context),
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

  Widget storeBlocListener() {
    return BlocListener(
      bloc: _storeBloc,
      listener: (BuildContext context,StoreState state) {
        if (state is LoadStoreByIdFinishState) {
          setState(() {
            store = state.store;
            _isLoadingStore = true;
          });
        }
      },
      child: SizedBox(),
    );
  }

  Widget storeDetails(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Text(
              'Store details',
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
          Container(
            width: MediaQuery.of(context).size.width,
            child: Text(
              store.name == null ? 'No name yet' : store.name.toString(),
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          Container(
            height: MediaQuery.of(context).size.height * 0.04,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: statusColor,
                border: Border.all(
                  color: statusBorderColor,
                ),
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width * 0.01,
                ),
              ),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.3,
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusBorderColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          Container(
            width: MediaQuery.of(context).size.width,
            child: store.imageUrl != null 
              ? Container(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Image.network(store.imageUrl), 
              )
              : SizedBox(),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          Container(
            child: Text(
              'Type : ' + (store.type == null ? 'No data available' : store.type.toString()),
            )
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          Container(
            child: Text(
              'Address : ' + (store.address == null ? 'No data available' : store.address.toString()),
            )
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
          Container(
            child: Text(
              'Ability to serve : ' + (store.abilityToServe == null ? 'No data available' : store.abilityToServe.toString()),
            ),
          ),
        ],
      ),
    );
  }
}