import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/osm_service.dart';
import '../providers.dart';
import '../models/request.dart';
import 'package:uuid/uuid.dart';

class RequestForm extends ConsumerStatefulWidget {
  const RequestForm({super.key});

  @override
  _RequestFormState createState() => _RequestFormState();
}

class _RequestFormState extends ConsumerState<RequestForm> {
  final _formKey = GlobalKey<FormState>();
  String restaurantName = '';
  String orderDetails = '';
  String deliveryAddress = '';
  double estimatedCost = 0.0;
  double offerAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Delivery Request')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => restaurantName = value,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Order Details',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => orderDetails = value,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => deliveryAddress = value,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Estimated Cost ($)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) => estimatedCost = double.tryParse(value) ?? 0.0,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final cost = double.tryParse(value);
                  return cost == null || cost <= 0 ? 'Enter a valid amount' : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Offer Amount ($)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) => offerAmount = double.tryParse(value) ?? 0.0,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final amount = double.tryParse(value);
                  return amount == null || amount <= 0 ? 'Enter a valid amount' : null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final addressResult = await OSMService.geocodeAddress(deliveryAddress);
                      if (addressResult == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid delivery address')),
                        );
                        return;
                      }
                      final request = Request(
                        id: const Uuid().v4(),
                        customerId: appState['userId'] ?? '',
                        restaurantName: restaurantName,
                        orderDetails: orderDetails,
                        estimatedCost: estimatedCost,
                        offerAmount: offerAmount,
                        deliveryAddress: deliveryAddress,
                      );
                      await ref.read(firestoreServiceProvider).createRequest(request);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Request created successfully')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```