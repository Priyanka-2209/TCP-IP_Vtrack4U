import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../list_data/provider_list.dart';
import '../modal/provider_modal.dart';

class CheckConnection extends StatefulWidget {
  const CheckConnection({super.key});

  @override
  State<CheckConnection> createState() => _CheckConnectionState();
}

class _CheckConnectionState extends State<CheckConnection> {
  String? selectedProvider;

  Map<String, String> ipAddressToPort = {};
  Map<String, String> ipAddressToState = {};
  Map<String, String> ipAddressToProviderId = {};
  String? selectedPort;

  List<String> ipAddresses = [];

  String? selectedIpAddress;

  @override
  void initState() {
    _fetchProviders();
    super.initState();
  }

  Future<void> _fetchProviders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      try {
        var headers = {'Authorization': 'Bearer $token'};
        var dio = Dio();
        var response = await dio.request(
          'https://absolutewebservices.in/vtrack4utcpip/api/providers',
          options: Options(
            method: 'GET',
            headers: headers,
          ),
        );

        if (response.statusCode == 200) {
          print("Fetched Providers: ${response.data}");

          setState(() {
            var providers = response.data['providers'];
            List<ProviderModal> providerModals = List<ProviderModal>.from(
                providers.map((provider) => ProviderModal.fromJson(provider)));
            ipAddressToPort.clear();
            ipAddressToState.clear();
            ipAddressToProviderId.clear();
            ipAddresses.clear();

            for (var provider in providerModals) {
              ipAddressToPort[provider.ipAddress] = provider.port;
              ipAddressToState[
                      '${provider.ipAddress}:${provider.port} {${provider.name}}'] =
                  '${provider.ipAddress}:${provider.port}';
              ipAddressToProviderId['${provider.ipAddress}-${provider.port}'] =
                  provider.id.toString();
            }

            ipAddresses = ipAddressToState.keys.toList();

            print("ipAddresses List: $ipAddresses");
          });
        } else {
          print(response.statusMessage);
        }
      } catch (e) {
        print("Error fetching providers: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    var screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color(0xFF123456),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: screenHeight * 0.13,
        backgroundColor: const Color(0xFF123456),
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/dashboard', (route) => false);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: Container(
          alignment: Alignment.bottomLeft,
          width: double.infinity,
          child: const Text(
            'Check Connection',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        padding: EdgeInsets.only(
            left: 20.0,
            right: 20,
            top: screenHeight * 0.03,
            bottom: screenHeight * 0.03),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                child: DropdownButtonFormField<String>(
                  value: selectedProvider,
                  hint: const Text(
                    'Select Provider',
                    style: TextStyle(color: Colors.grey),
                  ),
                  items: providers.map((String provider) {
                    return DropdownMenuItem<String>(
                      value: provider,
                      child: Text(provider),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedProvider = newValue;
                      ipAddresses.clear();

                      if (selectedProvider == 'Airtel') {
                        _fetchProviders();
                      }
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF123456), width: 1)),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              SizedBox(
                child: DropdownButtonFormField<String>(
                  value: selectedIpAddress,
                  // Should now store the combined value (IP:Port)
                  hint: const Text(
                    'Select IP Address',
                    style: TextStyle(color: Colors.grey),
                  ),
                  items: ipAddressToState.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.value, // Combined IP and Port
                      child: Text(entry.key), // Display "IP:Port {Name}"
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedIpAddress = newValue;
                      print('Selected IP Address: $selectedIpAddress');

                      if (newValue != null) {
                        selectedPort = newValue.split(':')[1];
                      }
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              if (selectedPort != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.blue.shade50,
                  ),
                  child: Text(
                    '$selectedIpAddress \n$selectedPort',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              Container(
                margin: EdgeInsets.only(top: screenHeight * 0.02),
                child: Center(
                  child: ElevatedButton(
                      child: Text(
                        'Check Connection',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF123456),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () async {
                        String? ip = selectedIpAddress?.split(':')[0];
                        if (ip != null && selectedPort != null) {
                          try {
                            Socket socket = await Socket.connect(
                                ip, int.parse(selectedPort!));
                            print(
                                'Connected to: Remote ${socket.address}:${socket.remotePort}');
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'Connection Established',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ));
                            socket.destroy(); // Close the socket after use
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'Error connecting to $selectedIpAddress:$selectedPort - $e',
                                style: TextStyle(color: Colors.white),
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                            ));
                            print(
                                'Error connecting to $selectedIpAddress:$selectedPort - $e');
                          }
                        } else {
                          print(
                              'IP Address or Port is null. Ensure both are selected.');
                        }
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
