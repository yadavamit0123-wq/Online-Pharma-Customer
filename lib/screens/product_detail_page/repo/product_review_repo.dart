import 'package:hyper_local/config/api_base_helper.dart';
import 'package:hyper_local/config/api_routes.dart';
import '../../../services/location/location_service.dart';

class ProductReviewRepository {
  final ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  Future<Map<String, dynamic>> fetchProductReview({required String productSlug}) async {
    try{
      final coords = LocationService.getApiCoordinates();
      final latitude = coords.latitude;
      final longitude = coords.longitude;
      final response = await apiBaseHelper.getAPICall(
          '${ApiRoutes.productDetailApi}$productSlug/reviews?latitude=$latitude&longitude=$longitude', {}
      );
      return response.data;
    } catch(e) {
      throw ApiException(e.toString());
    }
  }
}