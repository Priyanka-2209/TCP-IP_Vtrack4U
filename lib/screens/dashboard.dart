import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtrack_for_you/screens/change_password.dart';
import 'package:vtrack_for_you/screens/check_connection.dart';
import 'package:vtrack_for_you/screens/tcp_connection.dart';
import 'package:vtrack_for_you/screens/tcp_transaction_list.dart';
import 'package:vtrack_for_you/screens/update_profile.dart';
import 'package:vtrack_for_you/services/logout_service.dart';

import '../custom_feild/truck_list_card.dart';
import '../custom_feild/user_information_card.dart';
import '../modal/fetch_user_data_modal.dart';
import '../modal/user_vehicle_modal.dart';
import '../services/user_service.dart';
import '../services/vehicle_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late UserService _userService;
  late UserLogOutService _userLogOutService;
  FetchUserDataModal? _userData;

  final UserVehicleService _userVehicleService = UserVehicleService();


  bool _isPageLoading = true;
  List<UserVehicle> _userVehicles = [];

  @override
  void initState() {
    _userService = UserService();
    _userLogOutService = UserLogOutService();
    _initializePageData();
    super.initState();
  }

  Future<void> _loadUserVehicles() async {
    List<UserVehicle> vehicles = await _userVehicleService.fetchUserVehicles();
    setState(() {
      _userVehicles = vehicles;
    });
  }
  Future<void> _initializePageData() async {
    try {
      await Future.wait([
        _fetchUserData(),
        // _fetchUserVehicles(),
        _loadUserVehicles(),
      ]);
    } catch (e) {
      print("Error initializing page data: $e");
    } finally {
      setState(() {
        _isPageLoading = false; // Set to false once all data is loaded
      });
    }
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      FetchUserDataModal? fetchedData = await _userService.getUserInfo(token);
      setState(() {
        _userData = fetchedData;
      });
    } else {
      print("Token is missing.");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("User Vehicles: $_userVehicles");
    var screenHeight = MediaQuery.sizeOf(context).height;
    var screenWidth = MediaQuery.sizeOf(context).width;

    final List<Color> backgroundColors = [
      Colors.grey.shade100,
      Colors.blue.shade50,
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF123456),
        title: Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => UpdateProfile()));
            },
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF123456)),
                child: Text(
                  'Welcome ${_userData?.firstName}\n${_userData?.email}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(0),
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TcpConnection()));
                    },
                    title: Text(
                      'Add TCP Transaction',
                      style: TextStyle(color: Color(0xFF123456), fontSize: 14),
                    ),
                    leading: Icon(
                      Icons.add,
                      size: 16,
                      color: Color(0xFF123456),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TcpTransactionList()));
                    },
                    title: Text(
                      'TCP Transaction List',
                      style: TextStyle(color: Color(0xFF123456), fontSize: 14),
                    ),
                    leading: Icon(
                      Icons.list,
                      size: 16,
                      color: Color(0xFF123456),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CheckConnection()));
                    },
                    title: Text(
                      'Check Connection',
                      style: TextStyle(color: Color(0xFF123456), fontSize: 14),
                    ),
                    leading: Icon(
                      Icons.private_connectivity_outlined,
                      size: 16,
                      color: Color(0xFF123456),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangePassword()));
                },
                title: Text(
                  'Change Password',
                  style: TextStyle(color: Color(0xFF123456), fontSize: 14),
                ),
                leading: Icon(
                  Icons.password,
                  size: 16,
                  color: Color(0xFF123456),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: ListTile(
                title: Text('Logout',
                    style: TextStyle(color: Color(0xFF123456), fontSize: 14)),
                leading: Icon(
                  Icons.logout,
                  color: Color(0xFF123456),
                  size: 16,
                ),
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String token = prefs.getString('token') ??
                      ''; // Get the token from shared preferences
                  await _userLogOutService.logout_user(token);
                  prefs.clear();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false); // Close the drawer
                },
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
          child: _isPageLoading ? Center(child: CircularProgressIndicator(),) : Container(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02, vertical: screenHeight * 0.01),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_userData != null)
              Container(
                padding: EdgeInsets.all(5.0),
                child: UserInformationCard(
                  name: _userData!.firstName,
                  email: _userData!.email,
                  phoneNumber: _userData!.mobile,
                  address: _userData!.address,
                  city: _userData!.city,
                  state: _userData!.state,
                  country: _userData!.country,
                  zipcode: _userData!.pincode,
                  imageurl: _userData!.profileImage ?? 'https://www.w3schools.com/w3images/avatar2.png',
                ),
              ),
            SizedBox(
              height: screenHeight * 0.006,
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                'Truck Detail',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color(0xFF123456),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child:_userVehicles.isEmpty
                  ? Center(child: Text('No Vehicle Information Found'))
                  : ListView.builder(
                      itemCount: _userVehicles.length,
                      itemBuilder: (context, index) {
                        var backgroundColor =
                            backgroundColors[index % backgroundColors.length];
                        var vehicle = _userVehicles[index];
                        return TruckListCard(
                          backgroundColor: backgroundColor,
                          vehicle: vehicle,
                        );
                      },
                    ),
            ),
          ],
        ),
      )),
    );
  }
}
