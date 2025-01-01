import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Global_API_Var/constant.dart';

class TcpTransactionStore {
  Future<Map<String, dynamic>> storeTransaction(
      {required String vehicleId,
      required String latitude,
      required String longitude,
      required String providerId,
      required String serviceType}) async {

    var dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = await prefs.getString('token') ?? '';
    final String url = '${ApiConstants.baseUrl}tcptransactions';

    print('vehicleId : $vehicleId');
    print('latitude : $latitude');
    print('longitude : $longitude');
    print('providerId : $providerId');
    print('serviceType : $serviceType');

    try{
      final response = await dio.post(url,
        data: {
          "user_vehicle_details_id": vehicleId,
          "message_data": "test",
          "latitude": latitude,
          "logitude":longitude,
          "provider_id": providerId,
          "service_type": serviceType
        },
        options: Options(
          validateStatus: (status) {
            return status != null && status < 500;
          },
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "tcpData": response.data['tcp_data'],
        };
      } else {
        return {
          "success": false,
          "message": response.data['message'] ?? 'Unknown error occurred',
        };
      }
    } catch(e) {
      throw Exception('Error sending transaction: $e');
    }
  }
}
