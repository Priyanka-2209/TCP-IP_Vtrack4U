import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Global_API_Var/constant.dart';
import '../modal/user_vehicle_modal.dart';

class UserVehicleService {
  Future<List<UserVehicle>> fetchUserVehicles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      try {
        var headers = {'Authorization': 'Bearer $token'};
        var dio = Dio();
        var response = await dio.request(
          '${ApiConstants.baseUrl}user_vehicle',
          options: Options(
            method: 'GET',
            headers: headers,
          ),
        );

        if (response.statusCode == 200) {
          var data = response.data['user_vehicle'];
          return List<UserVehicle>.from(
              data.map((vehicle) => UserVehicle.fromJson(vehicle)));
        } else {
          print(response.statusMessage);
        }
      } catch (e) {
        print("Error fetching user vehicles: $e");
      }
    }
    return [];
  }
}
