import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers.dart';
import '../models/bid.dart';
import 'package:uuid/uuid.dart';

class BidForm extends ConsumerStatefulWidget {
  const BidForm({super.key});

  @override
  _BidFormState createState() => _BidFormState();
}

class _BidFormState extends ConsumerState<BidForm> {
  final _formKey = GlobalKey<FormState>();
  double counterOffer = 0.0;
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
    final appState = ref.watch(appStateProvider);
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final requestId = args['requestId'] as String;
    final deliveryAddress = args['deliveryAddress'] as String;

    return Scaffold(
      appBar: AppBar(title: Text('Place Bid for Delivery to $deliveryAddress')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Bid Amount (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                focusNode: _amountFocus,
                onChanged: (value) {
                  counterOffer = double.tryParse(value) ?? 0.0;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 5.0) {
                    return 'Enter a valid amount. Minimum bid is \$5.00';
                  }
                  return null;
                },
                semanticsLabel: 'Enter your bid amount in dollars',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _canSubmit()
                    ? () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final bid = Bid(
                              id: const Uuid().v4(),
                              requestId: requestId,
                              driverId: appState['userId'] ?? '',
                              counterOffer: counterOffer,
                              timestamp: DateTime.now(),
                            );
                            await FirebaseFirestore.instance.collection('bids').doc(bid.id).set(bid.toMap());
                            setState(() => _lastSubmission = DateTime.now());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bid submitted successfully')),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      }
                    : null,
                child: const Text('Submit Bid'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
