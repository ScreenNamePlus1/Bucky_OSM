import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/Provider.dart';
import 'package:intl/intl.dart'; // Add to pubspec.yaml
import '../providers/app_state.dart';

class BidForm extends StatefulWidget {
  @override
  _BidFormState createState() => _BidFormState();
}

class _BidFormState extends State<BidForm> {
  final _formKey = GlobalKey<FormState>();
  double amount = 0.0;
  final currencyFormat = NumberFormat.currency(symbol: '$');

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final requestId = args['requestId'] as String;
    final dropoff = args['dropoff'] as String;

    return Scaffold(
      appBar: AppBar(title: Text('Place Bid for Delivery to $dropoff')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Bid Amount ($)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0.0;
                  setState(() {}); // Update UI for formatted display
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) return 'Enter a valid positive amount';
                  return null;
                },
              ),
              SizedBox(height: 8),
              Text('Formatted Amount: ${currencyFormat.format(amount)}', style: TextStyle(fontStyle: FontStyle.italic)),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await FirebaseFirestore.instance.collection('bids').add({
                        'requestId': requestId,
                        'driverId': appState.userId,
                        'amount': amount,
                        'createdAt': Timestamp.now(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bid placed successfully')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: Text('Submit Bid'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}