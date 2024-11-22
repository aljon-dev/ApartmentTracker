

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/Tenant/complainRequest.dart';

import 'package:my_app/Tenant/maintenanceRequestPage.dart';
import 'package:my_app/Tenant/paymentTransaction.dart';
import 'package:my_app/Tenant/settingsPage.dart';

import 'notificationPage.dart';

class Announcement {
  final String id;
  final String announcement;

  Announcement({
    required this.id,
    required this.announcement,
  });

  factory Announcement.fromFirestore(Map<String, dynamic> data, String id) {
    return Announcement(
      id: id,
      announcement: data['announce'] ?? '',
    );
  }
}

class homePage extends StatefulWidget {
  final String userid;

  const homePage({super.key, required this.userid});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<homePage> {

  // Firebasedatabase for Database and Auth 
  final _firestore = FirebaseFirestore.instance;
  final _fireAuth = FirebaseAuth.instance;

  
  String username = "";

  // The selected Indexes for Navigations in the bottom
  int _selectedIndex = 0;

  late PageController _pageController;

  // Current Date
  int dateMonth = DateTime.now().month - 1;

  // List of months 
  List<String> Months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  String? monthToday;

 // Get user Details 
  Future<void> getUserDetails() async {
     String userid =  _fireAuth.currentUser!.uid;
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('tenants').doc(userid).get();

    Map<String, dynamic>? userData =
        documentSnapshot.data() as Map<String, dynamic>?;

    if (userData != null) {
      setState(() {
        username = userData['username'];
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

// Automatic Fetching the userData and Current Months 
  @override
  void initState() {
    super.initState();
    monthToday = Months[dateMonth];

    
  
    setState(() {
      getUserDetails();
      _pageController = PageController();
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              settingsPage(userid: widget.userid)));
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person_2, color: Colors.white),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(username, style: const TextStyle(fontSize: 16)),
                  const Text('Tenant', style: TextStyle(fontSize: 12)),
                ],
              )
            ],
          ),
          actions: [
            IconButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> notificationPage(userid:widget.userid)));
            }, icon: const Icon(Icons.notifications))
          ]),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          _buildHomePage(),
          _RequestPage(), // Request Screen
          _TransactionHistory(), // Transactions Screen
        
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.airplane_ticket), label: 'Request'),
          BottomNavigationBarItem(
              icon: Icon(Icons.request_page), label: 'History'),
         
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Announcement',style:TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            )),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('announcement').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No Announcements');
                }

                final data = snapshot.data!.docs;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: List.generate(data.length, (index) {
                        var doc = data[index];
                        Announcement announcement = Announcement.fromFirestore(
                            doc.data() as Map<String, dynamic>, doc.id);

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Container(
                            width: 300,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.campaign, size: 40),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(announcement.announcement)
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
            const Text('Billings',style:TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            )),
            StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('Billings')
                    .where('uid', isEqualTo: widget.userid)
                    .where('month', isEqualTo: Months[dateMonth])
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error');
                  }
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final monthlybills = snapshot.data!.docs;

                  return SizedBox(
                    height: 170,
                    width: double.infinity,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: monthlybills.length,
                        itemBuilder: (context, index) {
                          final monthly = monthlybills[index];
                          String dateTimeStr = monthly['datetime'];
                          dateTimeStr = dateTimeStr.replaceAll('–', '-');

                          DateTime now = DateTime.now();

                          Color borderColor;
                          DateTime dueDate = DateFormat('yyyy-MM-dd - HH:mm')
                              .parse(dateTimeStr);

                          String status;

                          if (now.isAfter(dueDate)) {
                            borderColor = Colors.red;
                          } else if (now.isAtSameMomentAs(dueDate)) {
                            borderColor = Colors.green;
                          } else {
                            borderColor = Colors.orange;
                          }

                          if (monthly['status'] == ('paid')) {
                            status = 'Status: Paid';
                            borderColor = Colors.green;
                          } else if (monthly['status'] == 'Under Review') {
                            status = 'Status: Under Review';
                          } else {
                            status = 'Status: Unpaid';
                          }

                          return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 10),
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: borderColor, width: 2),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(children: [
                                      Text('Due Date: ${monthly['datetime']}'),
                                      SizedBox(height: 5),
                                      Text(status),
                                      monthly['status'] == ('paid')
                                          ? SizedBox(
                                              width: 150,
                                              child: ElevatedButton(
                                                  onPressed: () {},
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.black,
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10))),
                                                  child: Text('Already Paid')),
                                            )
                                          : SizedBox(
                                              width: 150,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                paymentTransaction(
                                                                    userid: widget
                                                                        .userid,
                                                                    salesId:
                                                                        monthly
                                                                            .id)));
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.black,
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10))),
                                                  child: Text('Pay now')),
                                            )
                                    ]),
                                  ),
                                ),
                              ));
                        }),
                  );
                }),
            const SizedBox(height: 20),
            const Text('Emergency Hotlines',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const ListTile(
              leading: Icon(Icons.local_hospital),
              title: Text('City Health Office'),
              subtitle: Text('095-852-0317'),
            ),
            const ListTile(
              leading: Icon(Icons.local_hospital),
              title: Text('City Health Office'),
              subtitle: Text('095-852-0317'),
            ),
            const ListTile(
              leading: Icon(Icons.local_hospital),
              title: Text('City Health Office'),
              subtitle: Text('095-852-0317'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _RequestPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Request ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Card(
            child: ListTile(
              tileColor: const Color.fromARGB(185, 248, 248, 248),
              title: const Text('Complain Request'),
              leading: const Icon(Icons.key),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                           complainRequest()));
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Card(
            child: ListTile(
              tileColor: const Color.fromARGB(185, 248, 248, 248),
              title: const Text('Maintenance Request'),
              leading: const Icon(Icons.hardware),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Maintenancerequestpage(userid: widget.userid)));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _TransactionHistory() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transaction History',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('sales_record')
                      .where('uid', isEqualTo: widget.userid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final monthlyHistory = snapshot.data!.docs;

                    return ListView.builder(
                        itemCount: monthlyHistory.length,
                        itemBuilder: (context, index) {
                          final history = monthlyHistory[index];

                          return Card(
                            child: InkWell(
                              onTap: () {},
                              child: ListTile(
                                title: Text(
                                    '${history['month']}  ${history['year']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Status: ${history['status']}'),
                                    Text(
                                        'Rental Cost: ${history['rental_cost']}'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  }))
        ],
      ),
    );
  }
}
