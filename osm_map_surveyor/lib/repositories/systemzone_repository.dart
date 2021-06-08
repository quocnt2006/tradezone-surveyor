import 'package:osm_map_surveyor/models/listbuildings.dart';
import 'package:osm_map_surveyor/models/liststores.dart';
import 'package:osm_map_surveyor/models/listsystemzone.dart';
import 'package:osm_map_surveyor/provider/systemzone_provider.dart';

class SystemZoneRepository {
  SystemzoneProvider _systemzoneProvider = SystemzoneProvider();

  Future<String> fetchNeedSurveySystemZoneMap() async {
    return await _systemzoneProvider.fetchNeedSurveySystemZoneMap();
  }

  Future<ListSystemZone> getListSystemZone(int districtId, int page, int pageSize, bool isMe) async {
    return await _systemzoneProvider.getListSystemZone(districtId, page, pageSize, isMe);
  }

  Future<ListBuildings> getListSystemZoneBuilding(int id, int page, int pageSize) async {
    return await _systemzoneProvider.getListSystemZoneBuilding(id, page, pageSize);  
  }

  Future<ListStores> getListSystemZoneStores(int id, int page, int pageSize) async {
    return await _systemzoneProvider.getListSystemZoneStores(id, page, pageSize);  
  }
}