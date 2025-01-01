import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Global_API_Var/constant.dart';
import '../modal/provider_modal.dart';

class ProviderService {
  Future<List<ProviderModal>> fetchProviders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    if (token.isNotEmpty) {
      try {
        var headers = {'Authorization': 'Bearer $token'};
        var dio = Dio();
        var response = await dio.request(
          '${ApiConstants.baseUrl}providers',
          options: Options(
            method: 'GET',
            headers: headers,
          ),
        );

        if (response.statusCode == 200) {
          print("Fetched Providers: ${response.data}");
          var providers = response.data['providers'] as List<dynamic>;
          return providers
              .map((providers) => ProviderModal.fromJson(providers))
              .toList();
        } else {
          print(response.statusMessage);
          throw Exception('Failed to fetch providers: ${response.statusMessage}');
        }
      } catch (e) {
        print("Error fetching providers: $e");
        throw Exception('Error fetching providers: $e');
      }
    } else {
      print('Token is Empty');
      throw Exception('Authentication token is missing.');
    }
  }
}