import 'package:hyper_local/config/api_base_helper.dart';
import 'package:hyper_local/config/api_routes.dart';
import '../../../config/helper.dart';
import '../../../services/location/location_service.dart';

class CategoryRepository {
  Future<Map<String, dynamic>> fetchCategory({
    required int perPage,
    required int currentPage,
    bool homeOnly = true,
    bool includeNoProduct = false,
  }) async {
    try{
      final coords = LocationService.getApiCoordinates();
      final query = StringBuffer(
        '${ApiRoutes.categoryApi}?per_page=$perPage&page=$currentPage'
        '&latitude=${coords.latitude}&longitude=${coords.longitude}',
      );
      if (homeOnly) {
        query.write('&home=true');
      }
      if (includeNoProduct) {
        query.write('&include_no_product=true');
      }
      final response = await AppHelpers.apiBaseHelper.getAPICall(
        query.toString(),
        {},
      );
      return response.data;
    }catch(e){
      throw ApiException('Failed to fetch categories');
    }
  }

  Future<Map<String, dynamic>> fetchFilterCategory({
    required int perPage,
    required int currentPage,
    List<int>? categoryIds,
  }) async {
    try{
      final coords = LocationService.getApiCoordinates();
      final queryParams = <String, dynamic>{
        'per_page': perPage.toString(),
        'page': currentPage.toString(),
        'latitude': coords.latitude.toString(),
        'longitude': coords.longitude.toString(),
        'home': 'true',
      };

      if (categoryIds != null && categoryIds.isNotEmpty) {
        queryParams['ids[]'] = categoryIds.map((id) => id.toString()).toList();
      }

      final response = await AppHelpers.apiBaseHelper.getAPICall(
          ApiRoutes.filterCategoryApi,
          queryParams,
      );
      return response.data;
    }catch(e){
      throw ApiException('Failed to fetch categories');
    }
  }
}