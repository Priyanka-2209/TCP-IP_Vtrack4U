import 'package:dio/dio.dart';

class UserLogOutService {
  final Dio dio = Dio();

  Future<void> logout_user(String token) async {
    var headers = {
      'Authorization': 'Bearer $token',
      'Cookie': 'vtrack4u_tcp_ip_session=$token',
    };

    try {
      var response = await dio.post(
        'https://absolutewebservices.in/vtrack4utcpip/api/userlogout',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print(response);
      } else {
        // Handle error if statusCode is not 200
        print('Error: ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
