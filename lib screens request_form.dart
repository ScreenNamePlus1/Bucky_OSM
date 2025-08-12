import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/request.dart';
import 'package:uuid/uuid.dart';

class RequestFormScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _restaurantController = TextEditingController();
  final _orderController = TextEditingController();
  final _costController = TextEditingController();
  final _offerController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Delivery Request')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _restaurantController,
                decoration: InputDecoration(labelText: 'Restaurant Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _orderController,
                decoration: InputDecoration(labelText: 'Order Details'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _costController,
                decoration: InputDecoration(labelText: 'Estimated Food Cost (\$)'),
                keyboardType: TextInputType.number,
                validator: (value) => double.tryParse(value!) == null ? 'Enter a number' : null,
              ),
              TextFormField(
                controller: _offerController,
                decoration: InputDecoration(labelText: 'Delivery Offer (\$)'),
                keyboardType: TextInputType.number,
                validator: (value) => double.tryParse(value!) == null ? 'Enter a number' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Delivery Address'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final request = DeliveryRequest(
                      id: Uuid().v4(),
                      customerId: AuthService()._auth.currentUser!.uid,
                      restaurantName: _restaurantController.text,
                      orderDetails: _orderController.text,
                      estimatedCost: double.parse(_costController.text),
                      offerAmount: double.parse(_offerController.text),
                      deliveryAddress: _addressController.text,
                    );
                    await FirestoreService().postRequest(request);
                    Navigator.pop(context);
                  }
                },
                child: Text('Post Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
