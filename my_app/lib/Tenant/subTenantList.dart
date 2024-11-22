import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class subTenantlist extends StatefulWidget {
  final userid;
  const subTenantlist({Key? key, required this.userid}) : super(key: key);

  @override
  _subTenantlistState createState() => _subTenantlistState();
}

class _subTenantlistState extends State<subTenantlist> {
  final _firestore = FirebaseFirestore.instance;
  final _firestorage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('List of Sub Tenants')),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('Sub-Tenant')
                            .where('mainAccountId', isEqualTo: widget.userid)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text('Something went wrong'));
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(child: Text('No sub-tenants found'));
                          }

                          final subTenants = snapshot.data!.docs;
                          return ListView.builder(
                              itemCount: subTenants.length,
                              itemBuilder: (context, index) {
                                final subTenant = subTenants[index].data()
                                    as Map<String, dynamic>;
                                return Card(
                                    child: InkWell(
                                        child: Container(
                                            height: 150,
                                            width: double.infinity,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(20),
                                                  child: Column(
                                                    children: [
                                                      customText(
                                                          subTenant['name'],
                                                          'Name'),
                                                      customText(
                                                          subTenant['remarks'],
                                                          'Remarks')
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ))));
                              });
                        }))
              ]),
        ));
  }

  Widget customText(String title, String Role) {
    return Text('${Role}: ${title}',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }
}
