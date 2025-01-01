import 'package:dio/dio.dart';

import '../Global_API_Var/constant.dart';
import '../modal/fetch_user_data_modal.dart';

class UserService {
  final Dio dio = Dio();

  Future<FetchUserDataModal?> getUserInfo(String token) async {
    var headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      var response = await dio.get(
        '${ApiConstants.baseUrl}getuserinfo',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return FetchUserDataModal.fromJson(response.data);
      } else {
        print('Error: ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
