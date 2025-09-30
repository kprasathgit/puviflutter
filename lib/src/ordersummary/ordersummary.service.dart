import 'package:puvi/src/common/apiservice.dart';
import 'package:puvi/src/common/customexception.dart';
import 'package:puvi/src/common/urls.dart';

class OrderSummaryService {
  Future<String?> createOrder(Map<String, dynamic> payload) async {
    try {
      final result = await ApiService.post<String>(
        url: Urls.createOrder,
        body: payload,
        fromJson: (json) {
          // backend returns { "secureKey": "..." }
          if (json is Map && json['secureKey'] != null) {
            return json['secureKey'].toString();
          }
          return "";
        },
      );
      if (!result.status) {
        throw CustomException(result.message ?? "Order creation failed");
      }
      return result.returnObject;
    } on CustomException {
      rethrow;
    } catch (e) {
      // throw CustomException("Unexpected error: $e");
      return null;
    }
  }
}
