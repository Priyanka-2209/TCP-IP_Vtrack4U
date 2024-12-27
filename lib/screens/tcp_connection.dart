import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../custom_feild/CustomTextFeild.dart';
import '../list_data/provider_list.dart';
import '../modal/provider_modal.dart';
import '../modal/user_vehicle_modal.dart';
import '../services/vehicle_service.dart';

class TcpConnection extends StatefulWidget {
  const TcpConnection({super.key});

  @override
  State<TcpConnection> createState() => _TcpConnectionState();
}

class _TcpConnectionState extends State<TcpConnection> {
  bool _isLoading = false;
  final TextEditingController _vehicleNoController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();

  var focusNodeVehicleNum = FocusNode();
  var focusNodeLat = FocusNode();
  var focusNodeLong = FocusNode();

  bool isFocusedVehicleNum = false;
  bool isFocusedLat = false;
  bool isFocusedLong = false;

  bool isEmptyVehicleNum = false;
  bool isEmptyLat = false;
  bool isEmptyLong = false;

  bool isVehicleNumVisible = false;
  bool isLatVisible = false;
  bool isLongVisible = false;

  final UserVehicleService _userVehicleService = UserVehicleService();

  List<UserVehicle> _userVehicles = [];
  String? selectedProvider;
  String? selectedImei;

  Map<String, String> ipAddressToPort = {};
  Map<String, String> ipAddressToState = {};
  Map<String, String> ipAddressToProviderId = {};
  String? selectedPortno;

  List<String> ipAddresses = [];

  String? selectedIpAddress;
  var vehicleId = '';

  @override
  void initState() {
    focusNodeVehicleNum.addListener(() {
      setState(() {
        isFocusedVehicleNum = focusNodeVehicleNum.hasFocus;
        if (!isFocusedVehicleNum) {
          isEmptyVehicleNum = _vehicleNoController.text.trim().isEmpty;
        }
      });
    });

    focusNodeLat.addListener(() {
      setState(() {
        isFocusedLat = focusNodeLat.hasFocus;
        if (!isFocusedLat) {
          isEmptyLat = _latController.text.trim().isEmpty;
        }
      });
    });

    focusNodeLong.addListener(() {
      setState(() {
        isFocusedLong = focusNodeLong.hasFocus;
        if (!isFocusedLong) {
          isEmptyLong = _longController.text.trim().isEmpty;
        }
      });
    });

    _loadUserVehicles();
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
                      '${provider.ipAddress} (${provider.port})[${provider.name}]'] =
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

  Future<void> _loadUserVehicles() async {
    List<UserVehicle> vehicles = await _userVehicleService.fetchUserVehicles();
    setState(() {
      _userVehicles = vehicles;
    });
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
            'TCP Connection',
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
              SizedBox(
                child: DropdownButtonFormField<String>(
                  value: selectedImei,
                  hint: const Text(
                    'Select IMEI',
                    style: TextStyle(color: Colors.grey),
                  ),
                  items: _userVehicles.map((vehicle) {
                    return DropdownMenuItem<String>(
                      value: vehicle.imeiNumber,
                      child: Text(vehicle.imeiNumber),
                    );
                  }).toList(),
                  onChanged: (String? newImei) {
                    setState(() {
                      selectedImei = newImei;

                      UserVehicle? selectedVehicle = _userVehicles.firstWhere(
                        (vehicle) => vehicle.imeiNumber == newImei,
                      );

                      if (selectedVehicle != null) {
                        _vehicleNoController.text =
                            selectedVehicle.vehNumber ?? '';
                      } else {
                        _vehicleNoController.clear();
                      }
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF123456), width: 1),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.005),
                child: CustomTextField(
                  hintText: 'Enter Vehicle Number',
                  isFocused: isFocusedVehicleNum,
                  isEmpty: isEmptyVehicleNum,
                  controller: _vehicleNoController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  isDarkMode: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isEmptyVehicleNum = value.trim().isEmpty;
                    });
                  },
                  focusNode: focusNodeVehicleNum,
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.005),
                child: CustomTextField(
                  hintText: 'Enter Latitude',
                  isFocused: isFocusedLat,
                  isEmpty: isEmptyLat,
                  controller: _latController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  isDarkMode: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isEmptyLat = value.trim().isEmpty;
                    });
                  },
                  focusNode: focusNodeLat,
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.005),
                child: CustomTextField(
                  hintText: 'Enter Latitude',
                  isFocused: isFocusedLong,
                  isEmpty: isEmptyLong,
                  controller: _longController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  isDarkMode: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isEmptyLong = value.trim().isEmpty;
                    });
                  },
                  focusNode: focusNodeLong,
                ),
              ),
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
                        selectedPortno = newValue.split(':')[1];
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
              if (selectedPortno != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.blue.shade50,
                  ),
                  child: Text(
                    '$selectedIpAddress \n$selectedPortno',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              Container(
                margin: EdgeInsets.only(top: screenHeight * 0.02),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_vehicleNoController.text.trim().isEmpty ||
                                _latController.text.trim().isEmpty ||
                                _longController.text.trim().isEmpty) {
                              setState(() {
                                isEmptyVehicleNum =
                                    _vehicleNoController.text.trim().isEmpty;
                                isEmptyLat = _latController.text.trim().isEmpty;
                                isEmptyLong =
                                    _longController.text.trim().isEmpty;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  content: Text('Fields are empty'),
                                ),
                              );
                            } else {
                              setState(() {
                                _isLoading = true; // Start loading
                              });

                              try {
                                await sendString(); // Perform the operation
                              } finally {
                                setState(() {
                                  _isLoading = false; // Stop loading
                                });
                              }

                              // String? ip = selectedIpAddress?.split(':')[0];
                              // if (ip != null && selectedPort != null) {
                              //   try {
                              //     Socket socket = await Socket.connect(
                              //         ip, int.parse(selectedPort!));
                              //     print(
                              //         'Connected to: Remote ${socket.address}:${socket.remotePort}');
                              //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              //       content: Text(
                              //         'Connection Established',
                              //         style: TextStyle(color: Colors.white),
                              //       ),
                              //       backgroundColor: Colors.green,
                              //       behavior: SnackBarBehavior.floating,
                              //     ));
                              //     try {
                              //       await sendString(); // Perform the operation
                              //     } finally {
                              //       setState(() {
                              //         _isLoading = false; // Stop loading
                              //       });
                              //     }
                              //     socket.destroy(); // Close the socket after use
                              //   } catch (e) {
                              //     print(
                              //         'Error connecting to $selectedIpAddress:$selectedPort - $e');
                              //   }
                              // } else {
                              //   print(
                              //       'IP Address or Port is null. Ensure both are selected.');
                              // }
                            }
                          },
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Color(0xFF123456),
                          )
                        : Text(
                            'Send String',
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Future<void> sendString() async {
    var dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = await prefs.getString('token') ?? '';
    final String url =
        'https://absolutewebservices.in/vtrack4utcpip/api/tcptransactions';
    try {
      String selectedIp = selectedIpAddress?.split(':')[0] ?? '';
      String? selectedPort =
          selectedIpAddress?.split(':')[1] ?? ''; // Extracting the port

      String ipPortKey = '$selectedIp-$selectedPort';
      print('ipPortKey: $ipPortKey');

      print('selectedIp: $selectedIp');
      print('selectedPort: $selectedPort');
      print('ipAddresstoProviderID: $ipAddressToProviderId');

      String providerId = ipAddressToProviderId[ipPortKey] ?? '';
      if (providerId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text('Provider ID not found for IP address: $selectedIp'),
          ),
        );
        return;
      }

      UserVehicle? selectedVehicle = _userVehicles.firstWhere(
        (vehicle) => vehicle.imeiNumber == selectedImei,
      );

      if (selectedVehicle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text('No vehicle found with the provided IMEI.'),
          ),
        );
        return;
      }

      String vehicleId = selectedVehicle.id.toString();
      print('VehicleID: $vehicleId');
      final response = await dio.post(
        url,
        data: {
          "user_vehicle_details_id": vehicleId,
          "message_data": "test",
          "latitude": _latController.text,
          "logitude": _longController.text,
          "provider_id": providerId,
          "service_type": selectedProvider
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
        String successMessage = response.data['message'];
        String status = response.data['tcp_data']['status'];
        int id = response.data['tcp_data']['id'];
        print('Status : $status');
        print('id : $id');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              content: Text(
                successMessage,
                style: TextStyle(color: Colors.white),
              )),
        );
        await transactionUpdate(id);

        setState(() {
          _vehicleNoController.clear();
          _latController.clear();
          _longController.clear();
          selectedProvider = null;
          selectedImei = null;
          selectedIpAddress = null;
          selectedPortno = null;
        });
      } else {
        print('Server response status: ${response.statusCode}');
        print('Server response data: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              content: Text('Failed to update data: ${response.data}')),
        );
      }
    } on DioError catch (e) {
      print('DioError: ${e.response?.statusCode} - ${e.response?.data}');
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  Future<void> transactionUpdate(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text('Authentication token not found. Please login again.'),
        ),
      );
      return;
    }

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var data = {"status": "Success"};

    var dio = Dio();
    final String url =
        'https://absolutewebservices.in/vtrack4utcpip/api/tcptransactionsupdatebyid/$id';

    try {
      var response = await dio.post(
        url,
        options: Options(
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        String successMessage = response.data['message'];
        print('Transaction Update Response: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            content: Text(
              successMessage,
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else {
        print('Failed to update transaction: ${response.statusMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Failed to update transaction. Please try again.',
            ),
          ),
        );
      }
    } on DioError catch (e) {
      print('DioError during transaction update: ${e.response?.data}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text('Error updating transaction: ${e.message}'),
        ),
      );
    } catch (e) {
      print('Unexpected error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text('An unexpected error occurred: $e'),
        ),
      );
    }
  }
}
