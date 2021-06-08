import 'package:osm_map_surveyor/models/history.dart';
import 'package:osm_map_surveyor/provider/history_provider.dart';

class HistoryRepository {
  HistoryProvider _historyProvider = HistoryProvider();
  
  Future<List<History>> fetchListHistory() async {
    return await _historyProvider.fetchListHistory();
  }
}