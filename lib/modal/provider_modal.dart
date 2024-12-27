class ProviderModal {
  final int id;
  final String name;
  final String ipAddress;
  final String port;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  ProviderModal({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ProviderModal.fromJson(Map<String, dynamic> json) {
    return ProviderModal(
      id: json['id'],
      name: json['name'],
      ipAddress: json['ip_address'],
      port: json['port'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
