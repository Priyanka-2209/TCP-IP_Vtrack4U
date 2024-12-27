class FetchUserDataModal {
  final String id;
  final String roleId;
  final String firstName;
  final String middleName;
  final String lastName;
  final String? profileImage;
  final String email;
  final String address;
  final String mobile;
  final String gender;
  final String city;
  final String state;
  final String country;
  final String pincode;

  FetchUserDataModal({
    required this.id,
    required this.roleId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    this.profileImage,
    required this.email,
    required this.address,
    required this.mobile,
    required this.gender,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });

  factory FetchUserDataModal.fromJson(Map<String, dynamic> json) {
    return FetchUserDataModal(
      id: json['data']['user_data']['id'].toString(),
      roleId: json['data']['user_data']['role_id'].toString(),
      firstName: json['data']['user_data']['first_name'] ?? '',
      middleName: json['data']['user_data']['middle_name'] ?? '',
      lastName: json['data']['user_data']['last_name'] ?? '',
      profileImage: json['data']['user_data']['profile_image'],
      email: json['data']['user_data']['email'] ?? '',
      address: json['data']['user_data']['address'] ?? '',
      mobile: json['data']['user_data']['mobile'] ?? '',
      gender: json['data']['user_data']['gender'] ?? '',
      city: json['data']['user_data']['city'] ?? '',
      state: json['data']['user_data']['state'] ?? '',
      country: json['data']['user_data']['country'] ?? '',
      pincode: json['data']['user_data']['pincode'] ?? '',
    );
  }
}
