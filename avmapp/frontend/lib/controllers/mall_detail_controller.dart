import 'package:frontend/services/api/mall_api.dart';

class MallDetailController {
  Future<List<String>> fetchStores(int mallId) async {
    return await MallApi.fetchMallStores(mallId);
  }
}
