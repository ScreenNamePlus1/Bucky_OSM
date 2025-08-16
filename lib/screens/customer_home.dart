import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class CustomerHome extends StatefulWidget {
  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  String? _selectedStatus = 'all'; 
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
            await Provider.of<AuthService>(context, listen: false).signOut();
            Navigator.pushReplacementNamed(context, '/login');
           },
          ),
        ],
      ),
      body: StreamBuilder(
       body: Column(
        children: [
         DropdownButton<String>(
          value: 'all',
          items: [
        DropdownMenuItem(value: 'all', child: Text('All Requests')),
        DropdownMenuItem(value: 'pending', child: Text('Pending')),
        DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
        DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedStatus = value;
        });
      },
    ),
    body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('userId', isEqualTo: appState.userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No requests found.'));
          }
          return ListView(
            padding: EdgeInsets.all(16.0),
            children: snapshot.data!.docs.map((doc) {
              return Card(
                child: ListTile(
                  title: Text('Delivery to ${doc['dropoff']}'),
                  subtitle: Text('Status: ${doc['status']}'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/bids',
                    arguments: doc.id,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/request'),
        child: Icon(Icons.add),
        tooltip: 'Create New Request',
      ),
    );
  }
}