import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class subTenantList extends StatefulWidget {
  final String userid;
  const subTenantList({Key? key, required this.userid}) : super(key: key);

  @override
  _SubTenantListState createState() => _SubTenantListState();
}

class _SubTenantListState extends State<subTenantList> {
  final _firestore = FirebaseFirestore.instance;
  final _firestorage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of Sub Tenants'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Sub-Tenant')
            .where('mainAccountId', isEqualTo: widget.userid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No sub-tenants found'));
          }

          final subTenants = snapshot.data!.docs;
          return ListView.builder(
            itemCount: subTenants.length,
            itemBuilder: (context, index) {
              final subTenant = subTenants[index].data() as Map<String, dynamic>;
              final createdAt = subTenant['createdAt'] as Timestamp?;
              final formattedDate = createdAt != null
                  ? DateFormat('MMMM dd, yyyy hh:mm:ss a').format(createdAt.toDate())
                  : 'Date not available';

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: subTenant['profileImage'] != null
                                ? NetworkImage(subTenant['profileImage'])
                                : null,
                            child: subTenant['profileImage'] == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${subTenant['name'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Contact: ${subTenant['contact'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Created: $formattedDate',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Remarks: ${subTenant['remarks'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}