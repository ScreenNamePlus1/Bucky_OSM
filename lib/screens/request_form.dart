import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../maps/osm_service.dart';
import '../providers/app_state.dart';

class RequestForm extends StatefulWidget {
  @override
  _RequestFormState createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final _formKey = GlobalKey<FormState>();
  String pickup = '';
  String dropoff = '';
  String details = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.read(appStateProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Create Delivery Request')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Pickup Address',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => pickup = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Drop-off Address',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => dropoff = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Package Details (Optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => details = value,
                maxLines: 3,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final pickupResult = await OSMService.geocodeAddress(pickup);
                      final dropoffResult = await OSMService.geocodeAddress(dropoff);
                      if (pickupResult == null || dropoffResult == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Invalid pickup or dropoff address')),
                        );
                        return;
                      }
                      await FirebaseFirestore.instance.collection('requests').add({
                        'userId': appState.state['userId'] ?? '',
                        'pickup': pickup,
                        'pickupLocation': GeoPoint(
                          double.parse(pickupResult['lat']),
                          double.parse(pickupResult['lon']),
                        ),
                        'dropoff': dropoff,
                        'dropoffLocation': GeoPoint(
                          double.parse(dropoffResult['lat']),
                          double.parse(dropoffResult['lon']),
                        ),
                        'details': details.isEmpty ? null : details,
                        'status': 'pending',
                        'createdAt': Timestamp.now(),
                      });
                      ScaffoldMessenger.of(context).showSnac
kBar(
                        SnackBar(content: Text('Request created successfully')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: Text('Submit Request'),
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