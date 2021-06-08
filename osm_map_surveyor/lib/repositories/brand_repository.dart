import 'package:osm_map_surveyor/models/brand.dart';
import 'package:osm_map_surveyor/models/store.dart';
import 'package:osm_map_surveyor/provider/brand_provider.dart';

class BrandRepository {
  BrandProvider _brandProvider = new BrandProvider();

  Future<List<Brand>> fetchListBrands() async {
    return await _brandProvider.fetchListBrands();
  }

  Future<List<Store>> fetchListBrandStores(int id) async {
    return await _brandProvider.fetchListBrandStores(id);
  }
}