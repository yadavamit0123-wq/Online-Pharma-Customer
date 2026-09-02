import '../../../config/api_base_helper.dart';
import '../../../config/api_routes.dart';
import '../../../config/helper.dart';
import '../../../model/sorting_model/sorting_model.dart';
import '../../../services/location/location_service.dart';

class SearchRepository {
  Future<Map<String, dynamic>> fetchSearchData({
    SortType? sortType,
    String? type,
    required String query,
    required int perPage,
    required int currentPage
  }) async {
    try {
      final coords = LocationService.getApiCoordinates();
      final latitude = coords.latitude;
      final longitude = coords.longitude;

      final apiUrl = '${ApiRoutes.searchApi}?search=$query&per_page=$perPage&page=$currentPage&latitude=$latitude&longitude=$longitude&sort=${sortType ?? SortType.relevance}';

      final response = await AppHelpers.apiBaseHelper.getAPICall(
        apiUrl,
        {},
      );
      return response.data;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}