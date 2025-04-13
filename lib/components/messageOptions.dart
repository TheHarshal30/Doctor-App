// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_build_context_synchronously, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessageOptionsPopup extends StatefulWidget {
  final VoidCallback onClose;
  final String accountSid;
  final String authToken;
  final String twilioNumber;
  final String toNumber;

  const MessageOptionsPopup({
    Key? key,
    required this.onClose,
    required this.accountSid,
    required this.authToken,
    required this.twilioNumber,
    required this.toNumber,
  }) : super(key: key);

  @override
  _MessageOptionsPopupState createState() => _MessageOptionsPopupState();
}

class _MessageOptionsPopupState extends State<MessageOptionsPopup> {
  bool _showTemplate = false;
  String _selectedOption = '';
  String _messageTemplate = '';

  void _showMessageTemplate(String option) {
    setState(() {
      _selectedOption = option;
      _showTemplate = true;
      _messageTemplate = _getDefaultTemplate(option);
    });
  }

  String _getDefaultTemplate(String option) {
    switch (option) {
      case 'Appointment Reminder':
        return 'Your appointment is scheduled for [DATE] at [TIME].';
      case 'Appointment Missed':
        return 'You missed your appointment on [DATE] at [TIME].';
      case 'Tracking ID sharing':
        return 'Your tracking ID for the recent order is [TRACKING_ID].';
      case 'Payment Reminder':
        return 'This is a reminder that your payment of [AMOUNT] is due on [DATE].';
      default:
        return '';
    }
  }

  Future<void> sendWhatsAppMessage(String message) async {
    final Uri url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/${widget.accountSid}/Messages.json');

    final Map<String, String> headers = {
      'Authorization': 'Basic ' +
          base64Encode(utf8.encode('${widget.accountSid}:${widget.authToken}')),
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final Map<String, String> body = {
      'From': widget.twilioNumber,
      'To': widget.toNumber,
      'Body': message,
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        print(response);
      } else {
        print(response);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: 300,
        padding: EdgeInsets.all(16),
        child: _showTemplate ? _buildMessageTemplate() : _buildOptionsList(),
      ),
    );
  }

  Widget _buildOptionsList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Select Message Type',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              _buildOptionButton('Appointment Reminder'),
              _buildOptionButton('Appointment Missed'),
              _buildOptionButton('Tracking ID sharing'),
              _buildOptionButton('Payment Reminder'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(String option) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () => _showMessageTemplate(option),
        child: Text(option),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
        ),
      ),
    );
  }

  Widget _buildMessageTemplate() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_selectedOption,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Expanded(
          child: TextField(
            maxLines: null,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Customize your message',
            ),
            controller: TextEditingController(text: _messageTemplate),
            onChanged: (value) => _messageTemplate = value,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showTemplate = false;
                });
              },
              child: Text('Back'),
            ),
            ElevatedButton(
              onPressed: () {
                sendWhatsAppMessage(_messageTemplate);
                widget.onClose();
              },
              child: Text('Send'),
            ),
          ],
        ),
      ],
    );
  }
}
