import 'package:hyper_local/config/api_base_helper.dart';
import 'package:hyper_local/config/api_routes.dart';

import '../../../config/helper.dart';
import '../../../services/location/location_service.dart';

class ShoppingListRepository {
  Future<Map<String, dynamic>> createShoppingList({required String keywords}) async {
    try{
      final coords = LocationService.getApiCoordinates();
      final latitude = coords.latitude;
      final longitude = coords.longitude;
      final response = await AppHelpers.apiBaseHelper.getAPICall(
          '${ApiRoutes.shoppingListApi}?latitude=$latitude&longitude=$longitude&keywords=$keywords&per_page=40',
          {}
      );
      if(response.statusCode ==  200){
        return response.data;
      }
      return {};
    } catch(e) {
      throw ApiException(e.toString());
    }
  }
}