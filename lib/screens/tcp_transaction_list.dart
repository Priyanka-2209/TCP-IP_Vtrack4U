import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modal/tcp_transaction.dart';

class TcpTransactionList extends StatefulWidget {
  const TcpTransactionList({super.key});

  @override
  State<TcpTransactionList> createState() => _TcpTransactionListState();
}

class _TcpTransactionListState extends State<TcpTransactionList> {
  List<TcpTransaction> tcpTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTcpTransactions();
  }

  Future<void> _fetchTcpTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var data = json.encode({
      "per_page": "100000",
    });

    try {
      var dio = Dio();
      var response = await dio.post(
        'https://absolutewebservices.in/vtrack4utcpip/api/tcptransactionshistory',
        options: Options(
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        var jsonData = response.data['data']['tcptransactions'];
        setState(() {
          tcpTransactions = List<TcpTransaction>.from(
              jsonData.map((item) => TcpTransaction.fromJson(item)));
          _isLoading = false;
        });
      } else {
        print("Error: ${response.statusMessage}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF123456),
          title: Text(
            'TCP Transaction List',
            style: TextStyle(color: Colors.white),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/dashboard', (route) => false);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: tcpTransactions.length,
                itemBuilder: (context, index) {
                  var transaction = tcpTransactions[index];
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                        '${transaction.ipAddress} : ${transaction.port}',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction Date: ${transaction.transactionDate}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Message: ${transaction.messageData}',
                            style: TextStyle(fontSize: 12),
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
