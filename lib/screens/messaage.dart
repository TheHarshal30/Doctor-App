import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MessageSender(),
    );
  }
}

class MessageSender extends StatefulWidget {
  @override
  _MessageSenderState createState() => _MessageSenderState();
}

class _MessageSenderState extends State<MessageSender> {
  final TextEditingController _phoneController = TextEditingController();
  String _statusMessage = '';

  void sendMessage(String phoneNumber) async {
    final url =
        Uri.parse('https://graph.facebook.com/v19.0/350710691457323/messages');
    final headers = {
      'Authorization':
          'Bearer EAAW3ZAlytfLwBO2Acm8vgOJimA1ew9AwQRt9u3ZBPxINq7y75x4JDAzxYPeBZAvAdXD0eUHVwh8FplMsZAxgngDWbN0rPQunNePCTbxqVrxJHd1OH44my3xSfzZBZBIeLuWjSbmfO52HSyPB8o0IPXAPy1lLZCDqFwNZCZCmkVgq1Vy5h8EqQiM9gJNZARl93tUxLuqSEDsf9ZCVMrzlBjnXXZArelRBOJ8ZD',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      "messaging_product": "whatsapp",
      "to": phoneNumber,
      "type": "template",
      "template": {
        "name": "hello_world",
        "language": {"code": "en_US"}
      }
    });

    final response = await http.post(url, headers: headers, body: body);

    setState(() {
      if (response.statusCode == 200) {
        _statusMessage = 'Message sent successfully!';
      } else {
        _statusMessage = 'Failed to send message: ${response.statusCode}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facebook API Example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter phone number',
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendMessage(_phoneController.text);
              },
              child: Text('Send Message'),
            ),
            SizedBox(height: 20),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }
}
