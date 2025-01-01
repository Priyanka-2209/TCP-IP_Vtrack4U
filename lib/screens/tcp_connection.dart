import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_searchable_dropdown/flutter_searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtrack_for_you/custom_feild/CustomTextFeildLatLong.dart';

import '../custom_feild/CustomTextFeild.dart';
import '../list_data/provider_list.dart';
import '../modal/provider_modal.dart';
import '../modal/user_vehicle_modal.dart';
import '../services/logout_service.dart';
import '../services/provider_service.dart';
import '../services/tcp_transaction_store_service.dart';
import '../services/transaction_update_service.dart';
import '../services/vehicle_service.dart';
import '../util/snack_bar_util.dart';

class TcpConnection extends StatefulWidget {
  const TcpConnection({super.key});

  @override
  State<TcpConnection> createState() => _TcpConnectionState();
}

class _TcpConnectionState extends State<TcpConnection> {
  final UserVehicleService _userVehicleService = UserVehicleService();
  final UserLogOutService _userLogOutService = UserLogOutService();
  late ProviderService _providerService = ProviderService();
  late TransactionUpdateService _transactionUpdateService =
      TransactionUpdateService();
  late TcpTransactionStore _tcpTransactionStore = TcpTransactionStore();

  String latLongPattern = r'^\d{1,3}\.\d{7}$';

  bool _isLoading = false;
  final _imeiController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();

  var focusNodeImei = FocusNode();
  var focusNodeLat = FocusNode();
  var focusNodeLong = FocusNode();

  bool isFocusedImei = false;
  bool isFocusedLat = false;
  bool isFocusedLong = false;

  bool isEmptyImei = false;
  bool isEmptyLat = false;
  bool isEmptyLong = false;

  bool isImeiVisible = false;
  bool isLatVisible = false;
  bool isLongVisible = false;

  String? selectedProvider,
      selectedVehicleNo,
      selectedPortno,
      selectedIpAddress;

  Map<String, String> ipAddressToPort = {};
  Map<String, String> ipAddressToState = {};
  Map<String, String> ipAddressToProviderId = {};

  List<String> ipAddresses = [];
  List<UserVehicle> _userVehicles = [];

  var vehicleId = '';

  @override
  void initState() {
    focusNodeImei.addListener(() {
      setState(() {
        isFocusedImei = focusNodeImei.hasFocus;
        if (!isFocusedImei) {
          isEmptyImei = _imeiController.text.trim().isEmpty;
        }
      });
    });

    focusNodeLat.addListener(() {
      setState(() {
        isFocusedLat = focusNodeLat.hasFocus;
        if (!isFocusedLat) {
          isEmptyLat = _latController.text.trim().isEmpty;
          if (!isFocusedLat && !_isValidLatLong(_latController.text)) {
            SnackBarUtil.showSnackBar(
              context: context,
              message: 'Invalid latitude format. Please use: 11.1111111',
            );
          }
        }
      });
    });

    focusNodeLong.addListener(() {
      setState(() {
        isFocusedLong = focusNodeLong.hasFocus;
        if (!isFocusedLong) {
          isEmptyLong = _longController.text.trim().isEmpty;
          if (!isFocusedLong && !_isValidLatLong(_longController.text)) {
            SnackBarUtil.showSnackBar(
              context: context,
              message: 'Invalid longitude format. Please use: 11.1111111',
            );
          }
        }
      });
    });

    _loadUserVehicles();
    _fetchProviders();
    super.initState();
  }

  Future<void> _fetchProviders() async {
    try {
      List<ProviderModal> providerModels =
          await _providerService.fetchProviders();
      setState(() {
        ipAddressToPort.clear();
        ipAddressToState.clear();
        ipAddressToProviderId.clear();
        ipAddresses.clear();
        for (var provider in providerModels) {
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
    } catch (e) {
      print("Error fetching providers: $e");
      SnackBarUtil.showSnackBar(
        context: context,
        message: 'Error fetching providers: $e',
      );
    }
  }

  Future<void> _loadUserVehicles() async {
    List<UserVehicle> vehicles = await _userVehicleService.fetchUserVehicles();
    setState(() {
      _userVehicles = vehicles;
    });
  }

  bool _isValidLatLong(String value) {
    RegExp regExp = RegExp(latLongPattern);
    return regExp.hasMatch(value);
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
        toolbarHeight: screenHeight * 0.10,
        backgroundColor: const Color(0xFF123456),
        actions: [
          IconButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String token = prefs.getString('token') ?? '';
                await _userLogOutService.logout_user(token, context);
                prefs.clear();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
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
            children: [
              Container(
                height: screenHeight * 0.07,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF123456)),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: SingleChildScrollView(
                  child: SearchableDropdown.single(
                    items: _userVehicles.map((vehicle) {
                      return DropdownMenuItem<String>(
                        value: vehicle.vehNumber,
                        child: Text(vehicle.vehNumber),
                      );
                    }).toList(),
                    value: selectedVehicleNo,
                    hint: const Text(
                      'Select Vehicle',
                      style: TextStyle(color: Colors.grey),
                    ),
                    searchHint: "Search Vehicle",
                    onChanged: (String? newVehNo) {
                      setState(() {
                        selectedVehicleNo = newVehNo;

                        UserVehicle? selectedImei = _userVehicles.firstWhere(
                          (vehicle) => vehicle.vehNumber == newVehNo,
                          orElse: () => UserVehicle(
                            vehNumber: '',
                            imeiNumber: '',
                            id: 0,
                            userId: 0,
                            gpsDeviceType: '',
                          ),
                        );

                        if (selectedImei != null) {
                          _imeiController.text = selectedImei.imeiNumber ?? '';
                        } else {
                          _imeiController.clear();
                        }
                      });
                    },
                    clearIcon: Icon(Icons.clear),
                    closeButton: "close",
                    isExpanded: true,
                    dialogBox: true,
                    menuBackgroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.005),
                child: CustomTextField(
                  hintText: 'Enter IMEI Number',
                  isFocused: isFocusedImei,
                  isEmpty: isEmptyImei,
                  controller: _imeiController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  isDarkMode: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isEmptyImei = value.trim().isEmpty;
                    });
                  },
                  focusNode: focusNodeImei,
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.005),
                child: CustomTextFieldLatLong(
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
                child: CustomTextFieldLatLong(
                  hintText: 'Enter Longitude',
                  isFocused: isFocusedLong,
                  isEmpty: isEmptyLong,
                  controller: _longController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                  hint: const Text(
                    'Select IP Address',
                    style: TextStyle(color: Colors.grey),
                  ),
                  items: ipAddressToState.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.value,
                      child: Text(entry.key),
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_imeiController.text.trim().isEmpty ||
                                  _latController.text.trim().isEmpty ||
                                  _longController.text.trim().isEmpty) {
                                setState(() {
                                  isEmptyImei =
                                      _imeiController.text.trim().isEmpty;
                                  isEmptyLat =
                                      _latController.text.trim().isEmpty;
                                  isEmptyLong =
                                      _longController.text.trim().isEmpty;
                                });
                                SnackBarUtil.showSnackBar(
                                  context: context,
                                  message: 'Fields are empty',
                                );
                              } else {
                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  await sendString();
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
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
                Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _imeiController.clear();
                          _latController.clear();
                          _longController.clear();
                          selectedProvider = null;
                          selectedVehicleNo = null;
                          selectedIpAddress = null;
                          selectedPortno = null;
                        });
                      },
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: Color(0xFF123456),
                            )
                          : Text(
                              'Clear Form',
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
              ]),
            ],
          ),
        ),
      ),
    ));
  }

  Future<void> sendString() async {
    String selectedIp = selectedIpAddress?.split(':')[0] ?? '';
    String? selectedPort = selectedIpAddress?.split(':')[1] ?? '';
    String ipPortKey = '$selectedIp-$selectedPort';

    print('ipPortKey: $ipPortKey');
    print('IMEI No: ${_imeiController.text}');
    print('selectedIp: $selectedIp');
    print('selectedPort: $selectedPort');
    print('ipAddresstoProviderID: $ipAddressToProviderId');

    String providerId = ipAddressToProviderId[ipPortKey] ?? '';
    print('providerId: $providerId');

    if (providerId.isEmpty) {
      SnackBarUtil.showSnackBar(
        context: context,
        message: 'Provider ID not found for IP address: $selectedIp',
      );
      // setState(() {
      //   _isLoading = false; // Stop loading
      // });
      return;
    }

    UserVehicle? selectedVehicle = _userVehicles.firstWhere(
      (vehicle) => vehicle.vehNumber == selectedVehicleNo,
    );

    if (selectedVehicle == null) {
      SnackBarUtil.showSnackBar(
        context: context,
        message: 'No vehicle found with the provided IMEI.',
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    String vehicleId = selectedVehicle.id.toString();
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _tcpTransactionStore.storeTransaction(
          vehicleId: vehicleId,
          latitude: _latController.text,
          longitude: _longController.text,
          providerId: providerId,
          serviceType: selectedProvider!);
      print('response:::: $response[data]');

      if (response['success']) {
        Map<String, dynamic> tcpData = response['tcpData'];
        String msgData = tcpData['message_data'];
        int id = tcpData['id'];
        String status = '';

        // //open socket code
        // bool socketSuccess = await sendToTcpSocket(msgData, selectedIp, selectedPort);
        // if (socketSuccess) {
        //   await transactionUpdate(id, status = 'Success');
        //   print("Sucess Status: $status");
        // } else {
        //   await transactionUpdate(id, status = 'fail');
        //   print("Fail Status: $status");
        // }

        // close socket code
        await transactionUpdate(id, status = 'Success');
      } else {
        SnackBarUtil.showSnackBar(
          context: context,
          message: response['message'],
        );
      }
    } catch (e) {
      SnackBarUtil.showSnackBar(
        context: context,
        message: 'An unexpected error occurred: $e',
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading in all cases
      });
    }
  }

  Future<bool> sendToTcpSocket(String msgData, String ip, String? port) async {
    try {
      int? portNumber = int.tryParse(port!);
      // int? portNumber = 2022;
      Socket socket = await Socket.connect(ip, portNumber!)
          .timeout(Duration(minutes: 1), onTimeout: () {
        throw TimeoutException('Connection timeout. Please try again.');
      });
      socket.write(msgData);
      await socket.flush();
      await socket.close();
      return true;
    } on TimeoutException catch (e) {
      SnackBarUtil.showSnackBar(
        context: context,
        message: 'Connection timeout. Please try again.',
      );
      return false;
    } catch (e) {
      SnackBarUtil.showSnackBar(
        context: context,
        message: 'Error: Unable to connect to TCP server',
      );
      return false;
    }
  }

  Future<void> transactionUpdate(int id, String status) async {
    try {
      String successMessage = await _transactionUpdateService.transactionUpdate(
          id, status, context);
      print('Transaction Update Response: $status}');
      SnackBarUtil.showSnackBar(
        context: context,
        message: successMessage,
        backgroundColor: Colors.green,
      );
    } on DioError catch (e) {
      print('DioError during transaction update: ${e.response?.data}');
      SnackBarUtil.showSnackBar(
        context: context,
        message: 'Error updating transaction: ${e.message}',
      );
    } catch (e) {
      print('Unexpected error: $e');
      SnackBarUtil.showSnackBar(
        context: context,
        message: 'An unexpected error occurred: $e',
      );
    }
  }
}
