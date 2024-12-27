class TcpTransaction {
  final int id;
  final String messageData;
  final String ipAddress;
  final String port;
  final String transactionDate;

  TcpTransaction({
    required this.id,
    required this.messageData,
    required this.ipAddress,
    required this.port,
    required this.transactionDate
  });

  factory TcpTransaction.fromJson(Map<String, dynamic> json) {
    return TcpTransaction(
      id: json['id'],
      messageData: json['message_data'],
      ipAddress: json['ip_address'],
      port: json['port'],
      transactionDate: json['transaction_date']
    );
  }
}
