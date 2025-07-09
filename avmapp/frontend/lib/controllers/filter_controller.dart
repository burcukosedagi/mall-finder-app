import 'package:frontend/services/api/property_api.dart';

import '../models/brand.dart';
import '../models/facility.dart';

class FilterController {
  Future<List<Brand>> fetchBrands() async {
    return await PropertyApi.fetchBrands();
  }

  Future<List<Facility>> fetchFacilities() async {
    return await PropertyApi.fetchFacilities();
  }
}
