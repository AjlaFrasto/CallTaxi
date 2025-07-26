import 'package:flutter/material.dart';
import 'package:calltaxi_mobile_client/utils/network_utils.dart';
import 'package:http/http.dart' as http;

class DebugScreen extends StatefulWidget {
  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _connectionStatus = 'Not tested';
  bool _isTesting = false;

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _connectionStatus = 'Testing...';
    });

    try {
      final url = NetworkUtils.getBaseUrl();
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Connection timed out');
            },
          );

      setState(() {
        _connectionStatus = 'Connected! Status: ${response.statusCode}';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Failed: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network Debug'),
        backgroundColor: Color(0xFFFF6F00),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Base URL:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(NetworkUtils.getBaseUrl()),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isTesting ? null : _testConnection,
                      child: _isTesting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Test Connection'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF6F00),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Status: $_connectionStatus'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Setup Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(NetworkUtils.getNetworkSetupInstructions()),
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
