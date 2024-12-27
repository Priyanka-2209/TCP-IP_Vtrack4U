import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordService {
  final Dio dio = Dio();

  Future<Map<String, dynamic>> updatePassword({
    required String userId,
    required String oldpassword,
    required String newPassword,
    required String cnfmPassword}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url =
        'https://absolutewebservices.in/vtrack4utcpip/api/changepassword/$userId';

    var headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      var response = await dio.post(
        url,
        data: {
          'password': oldpassword,
          'new_password': newPassword,
          're_new_password': cnfmPassword
        },
        options: Options(headers: headers),
      );
      return {
        'status': response.statusCode,
        'data': response.data,
      };
    }on DioError catch (e) {
      throw Exception('DioError: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
}}
