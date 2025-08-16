import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers.dart';
import '../services/auth_service.dart';

class CustomerHome extends ConsumerStatefulWidget {
  const CustomerHome({super.key});

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends ConsumerState<CustomerHome> {
  String? _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              ref.read(appStateProvider.notifier).clearUser();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: _selectedStatus,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Requests')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
              DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
            ],
            onChanged: (value) {
              setState(() => _selectedStatus = value);
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('requests')
                  .where('customerId', isEqualTo: appState['userId'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No requests found.'));
                }
                final docs = _selectedStatus == 'all'
                    ? snapshot.data!.docs
                    : snapshot.data!.docs.where((doc) => doc['status'] == _selectedStatus).toList();
                
                if (docs.isEmpty) {
                  return const Center(child: Text('No requests match the selected status.'));
                }
                
                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: docs.map((doc) {
                    return Card(
                      child: ListTile(
                        title: Text('Delivery to ${doc['deliveryAddress']}'),
                        subtitle: Text('Status: ${doc['status']}'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/bids',
                          arguments: {'requestId': doc.id},
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/request'),
        child: const Icon(Icons.add),
        tooltip: 'Create New Request',
      ),
    );
  }
}
