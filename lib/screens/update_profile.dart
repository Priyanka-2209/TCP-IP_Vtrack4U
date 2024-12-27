import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../custom_feild/CustomTextFeild.dart';
import '../modal/fetch_user_data_modal.dart';
import '../services/user_service.dart';
import 'dashboard.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  String? _imageBase64;
  late UserService _userService;
  FetchUserDataModal? _userData;
  bool isLoading = false;

  bool _isPageLoading = true;

  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _mnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();

  var focusNodeFname = FocusNode();
  var focusNodeMname = FocusNode();
  var focusNodeLname = FocusNode();
  var focusNodeDob = FocusNode();
  var focusNodeContact = FocusNode();
  var focusNodeAddress = FocusNode();
  var focusNodeCountry = FocusNode();
  var focusNodeState = FocusNode();
  var focusNodeCity = FocusNode();
  var focusNodeZipcode = FocusNode();

  bool isFocusedFname = false;
  bool isFocusedMname = false;
  bool isFocusedLname = false;
  bool isFocusedDob = false;
  bool isFocusedContact = false;
  bool isFocusedAddress = false;
  bool isFocusedState = false;
  bool isFocusedCity = false;
  bool isFocusedCountry = false;
  bool isFocusedZipCode = false;

  bool isEmptyFname = false;
  bool isEmptyMname = false;
  bool isEmptyLname = false;
  bool isEmptyDob = false;
  bool isEmptyContact = false;
  bool isEmptyAddress = false;
  bool isEmptyState = false;
  bool isEmptyCity = false;
  bool isEmptyCountry = false;
  bool isEmptyZipCode = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    focusNodeFname.addListener(() {
      setState(() {
        isFocusedFname = focusNodeFname.hasFocus;
      });
    });
    focusNodeMname.addListener(() {
      setState(() {
        isFocusedMname = focusNodeMname.hasFocus;
      });
    });
    focusNodeLname.addListener(() {
      setState(() {
        isFocusedLname = focusNodeLname.hasFocus;
      });
    });
    focusNodeDob.addListener(() {
      setState(() {
        isFocusedDob = focusNodeDob.hasFocus;
      });
    });
    focusNodeContact.addListener(() {
      setState(() {
        isFocusedContact = focusNodeContact.hasFocus;
      });
    });
    focusNodeAddress.addListener(() {
      setState(() {
        isFocusedAddress = focusNodeAddress.hasFocus;
      });
    });
    focusNodeCountry.addListener(() {
      setState(() {
        isFocusedCountry = focusNodeCountry.hasFocus;
      });
    });
    focusNodeState.addListener(() {
      setState(() {
        isFocusedState = focusNodeState.hasFocus;
      });
    });
    focusNodeCity.addListener(() {
      setState(() {
        isFocusedCity = focusNodeCity.hasFocus;
      });
    });
    focusNodeZipcode.addListener(() {
      setState(() {
        isFocusedZipCode = focusNodeZipcode.hasFocus;
      });
    });

    _userService = UserService();

    _initializePageData();


    super.initState();
  }

  Future<void> _initializePageData() async {
    try {
      await _fetchUserData();
    } catch (e) {
      print("Error initializing page data: $e");
    } finally {
      setState(() {
        _isPageLoading = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? ''; // Get the token from shared preferences
    if (token.isNotEmpty) {
      FetchUserDataModal? fetchedData = await _userService.getUserInfo(token);
      print("Fetched User Data: $fetchedData"); // Debug print

      setState(() {
        _userData = fetchedData;
        if (_userData != null) {
          _fnameController.text = _userData!.firstName ?? '';
          _mnameController.text = _userData!.middleName ?? '';
          _lnameController.text = _userData!.lastName ?? '';
          _mobileController.text = _userData!.mobile ?? '';
          _addressController.text = _userData!.address ?? '';
          _countryController.text = _userData!.country ?? '';
          _stateController.text = _userData!.state ?? '';
          _cityController.text = _userData!.city ?? '';
          _zipcodeController.text = _userData!.pincode ?? '';
        }
      });
    } else {
      print("Token is missing.");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      setState(() {
        _imageBase64 = base64Image; // Update the base64 string
      });
    }
  }


  Future<void> submitData() async {
    setState(() {
      isLoading = true;
    });

    await updateUserData();

    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Dashboard()),
    );
  }

  Future<void> updateUserData() async {
    var dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = await prefs.getString('token') ?? '';

    String? imageUrl;
    if (_imageBase64 != null) {
      imageUrl = 'data:image/jpeg;base64,$_imageBase64';
    } else if (_userData?.profileImage != null) {
      imageUrl = _userData!.profileImage;
    }

    print('image64: $_imageBase64');
    print('imageUrl = $imageUrl');

    final String url = 'https://absolutewebservices.in/vtrack4utcpip/api/updateprofile/${_userData?.id}';
    try {
      final response = await dio.post(
        url,
        data: {
          'first_name': _fnameController.text.trim(),
          'middle_name': _mnameController.text.trim(),
          'last_name': _lnameController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'country': _countryController.text.trim(),
          'pincode': _zipcodeController.text.trim(),
          'mobile': _mobileController.text.trim(),
          'gender': '',
          'state': _stateController.text.trim(),
          'profile_image': imageUrl,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('User data updated successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to update user: ${response.data}'),
          ),
        );
      }
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: ${e.message}'),
        ),
      );
    }
  }


  @override
  void dispose() {
    _fnameController.dispose();
    _mnameController.dispose();
    _lnameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _zipcodeController.dispose();
    focusNodeFname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF123456),
        title: Text(
          'Update Profile',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: _isPageLoading ? Center(child: CircularProgressIndicator(),) : SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child:
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _imageBase64 == null
                        ? (_userData?.profileImage != null
                        ? NetworkImage(_userData!.profileImage!)
                        : null)
                        : MemoryImage(base64Decode(_imageBase64!)) as ImageProvider,
                    child: (_imageBase64 == null && _userData?.profileImage == null)
                        ? Center(
                      child: Text(
                        'No Image Found',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Color(0xFF123456),
                      radius: 20,
                      child: IconButton(
                        onPressed: _pickImage,
                        icon: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.02),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    top: screenHeight * 0.03,
                    right: screenWidth * 0.03,
                    left: screenWidth * 0.03,
                    bottom: screenHeight * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text('First Name'),
                    ),
                    CustomTextField(
                      hintText: 'First Name',
                      isFocused: isFocusedFname,
                      isEmpty: isEmptyFname,
                      controller: _fnameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      isDarkMode: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isEmptyFname = value.trim().isEmpty;
                        });
                      },
                      focusNode: focusNodeFname,
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text('Middle Name'),
                    ),
                    CustomTextField(
                      hintText: 'Middle Name',
                      isFocused: isFocusedMname,
                      isEmpty: isEmptyMname,
                      controller: _mnameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      isDarkMode: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isEmptyMname = value.trim().isEmpty;
                        });
                      },
                      focusNode: focusNodeMname,
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Last Name',
                      ),
                    ),
                    CustomTextField(
                      hintText: 'Last Name',
                      isFocused: isFocusedLname,
                      isEmpty: isEmptyLname,
                      controller: _lnameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      isDarkMode: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isEmptyLname = value.trim().isEmpty;
                        });
                      },
                      focusNode: focusNodeLname,
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Mobile',
                      ),
                    ),
                    CustomTextField(
                      hintText: 'Mobile',
                      isFocused: isFocusedContact,
                      isEmpty: isEmptyContact,
                      controller: _mobileController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      isDarkMode: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isEmptyContact = value.trim().isEmpty;
                        });
                      },
                      focusNode: focusNodeContact,
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Address',
                      ),
                    ),
                    CustomTextField(
                      hintText: 'Address',
                      isFocused: isFocusedAddress,
                      isEmpty: isEmptyAddress,
                      controller: _addressController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      isDarkMode: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isEmptyAddress = value.trim().isEmpty;
                        });
                      },
                      focusNode: focusNodeAddress,
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Country',
                      ),
                    ),
                    CustomTextField(
                      hintText: 'Country',
                      isFocused: isFocusedCountry,
                      isEmpty: isEmptyCountry,
                      controller: _countryController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      isDarkMode: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isEmptyCountry = value.trim().isEmpty;
                        });
                      },
                      focusNode: focusNodeCountry,
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'State',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    CustomTextField(
                      hintText: 'State',
                      isFocused: isFocusedState,
                      isEmpty: isEmptyState,
                      controller: _stateController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      isDarkMode: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isEmptyState = value.trim().isEmpty;
                        });
                      },
                      focusNode: focusNodeState,
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'City',
                      ),
                    ),
                    CustomTextField(
                      hintText: 'City',
                      isFocused: isFocusedCity,
                      isEmpty: isEmptyCity,
                      controller: _cityController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      isDarkMode: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isEmptyCity = value.trim().isEmpty;
                        });
                      },
                      focusNode: focusNodeCity,
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Zip code',
                      ),
                    ),
                    CustomTextField(
                      hintText: 'Zip code',
                      isFocused: isFocusedZipCode,
                      isEmpty: isEmptyZipCode,
                      controller: _zipcodeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      isDarkMode: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isEmptyZipCode = value.trim().isEmpty;
                        });
                      },
                      focusNode: focusNodeZipcode,
                    ),
                    Center(
                      child: isLoading
                          ? CircularProgressIndicator()
                          : Container(
                              width: screenWidth * 0.50,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : () {
                                  submitData();
                                },
                                child:  isLoading ? CircularProgressIndicator() :Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? Colors.grey[700]
                                      : Color(0xFF123456),
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
          ],
        ),
      ),
    );
  }
}
