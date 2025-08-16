import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class BidForm extends StatefulWidget {
  @override
  _BidFormState createState() => _BidFormState();
}

class _BidFormState extends State<BidForm> {
  final _formKey = GlobalKey<FormState>();
  double amount = 0.0;
  bool _isLoading = false;

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
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) return 'Enter a valid positive amount';
                  return null;
                },
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
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
                          } finally {
                            setState(() => _isLoading = false);
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