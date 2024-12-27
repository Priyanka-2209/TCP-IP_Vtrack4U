class UserVehicle {
  final int id;
  final int userId;
  final String vehNumber;
  final String imeiNumber;
  final String gpsDeviceType;
  final String? createdAt;
  final String? updatedAt;

  UserVehicle({
    required this.id,
    required this.userId,
    required this.vehNumber,
    required this.imeiNumber,
    required this.gpsDeviceType,
    this.createdAt,
    this.updatedAt,
  });

  factory UserVehicle.fromJson(Map<String, dynamic> json) {
    return UserVehicle(
      id: json['id'],
      userId: json['user_id'],
      vehNumber: json['veh_number'],
      imeiNumber: json['imei_number'],
      gpsDeviceType: json['gps_device_type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
