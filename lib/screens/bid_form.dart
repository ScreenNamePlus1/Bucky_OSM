import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class BidForm extends StatefulWidget {
  @override
  _BidFormState createState() => _BidFormState();
}

class _BidFormState extends State<BidForm> {
  final _formKey = GlobalKey<FormState>();
  double amount = 0.0;
  final _amountFocus = FocusNode();
  DateTime? _lastSubmission;

  @override
  void dispose() {
    _amountFocus.dispose();
    super.dispose();
  }

  bool _canSubmit() {
    if (_lastSubmission == null) return true;
    return DateTime.now().difference(_lastSubmission!).inSeconds >= 60;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final requestId = args['requestId'] as String;
    final dropoff = args['dropoff'] as String;

    return Scaffold(
      appBar: AppBar(title: Text(Intl.message('Place Bid for Delivery to $dropoff', name: 'bidFormTitle'))),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: Intl.message('Bid Amount ($)', name: 'bidAmountLabel'),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                focusNode: _amountFocus,
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0.0;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return Intl.message('Required', name: 'required');
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return Intl.message('Enter a valid amount', name: 'invalidAmount');
                  }
                  return null;
                },
                semanticsLabel: Intl.message('Enter your bid amount in dollars', name: 'bidAmountSemantics'),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _canSubmit()
                    ? () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await FirebaseFirestore.instance.collection('bids').add({
                              'requestId': requestId,
                              'driverId': appState.userId,
                              'amount': amount,
                              'createdAt': Timestamp.now(),
                            });
                            setState(() => _lastSubmission = DateTime.now());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(Int