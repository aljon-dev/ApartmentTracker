import 'dart:io';
import 'dart:math';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_app/Tenant/paymentTransaction.dart';

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

class homePageSub extends StatefulWidget {
  final String userid;
  

  const homePageSub({super.key, required this.userid});
  

  @override
  _homePageSubState createState() => _homePageSubState();
}

class _homePageSubState extends State<homePageSub> {
  final _firestore = FirebaseFirestore.instance;
  final picker = ImagePicker();

  
  final now = DateTime.now();

  
  List<String> DateMonth = [ 'January','February','March','April','May','June','July','August','September','October','November','December'];

  String? currentDate;


  String username = "";
  String? userProfile;
  String? mainAccountId;

  String? buildingnumber;
  String? unitnumber;
  String RequestType = 'Sub_tenant'; 

  final TextEditingController _RemarksController  = TextEditingController();

  



  int _selectedIndex = 0; 
  late PageController _pageController;





  

  Future<void> sendRequest () async { 

      try{
          if(_RemarksController.text.isEmpty ){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
          }else{
            _firestore.collection('borrow_keys').add({
              'buildnumber':  buildingnumber,
              'for':RequestType,
              'remarks':_RemarksController.text,
              'uid':widget.userid,
              'unitnumber':unitnumber,
         });
         _RemarksController.text = "";
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent')));

        }

      }catch (e){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
  
  }  

  Future<void> getUserDetails() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('Sub-Tenant').doc(widget.userid).get();

    Map<String, dynamic>? userData =
        documentSnapshot.data() as Map<String, dynamic>?;

    if (userData != null) {
      setState(() {
        username = userData['name'];
        userProfile = userData['image'];
        mainAccountId = userData['mainAccountId'];
        
      });
    }
  }

    Future<void> getMainAccountDetails() async{
      DocumentSnapshot documentSnapshot =  await _firestore.collection('tenant').doc(mainAccountId).get();
      Map<String,dynamic>? tenantDetails = documentSnapshot.data() as Map<String,dynamic>?;

      if(tenantDetails !=null){
        setState(() {
          buildingnumber = tenantDetails['buildingNumber'];
          unitnumber = tenantDetails['unitNumber'];
          });
      }


    }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void initState() {
    super.initState();

    setState(() {

      currentDate = DateMonth[now.month-1];
      _pageController = PageController();
    
    });
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                child: Image.network(userProfile!),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(username, style: const TextStyle(fontSize: 16)),
                  const Text('Sub Tenant', style: TextStyle(fontSize: 12)),
                ],
              )
            ],
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
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
          _RequestKeyPage(), 
           _TransactionHistory(), 
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.airplane_ticket), label: 'Request'),
          BottomNavigationBarItem(
              icon: Icon(Icons.request_page), label: 'Transactions'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
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
            const SizedBox(height: 20),
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

            if(mainAccountId != null) ...[
             StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('sales_record').where('uid',isEqualTo:mainAccountId).snapshots(), 
                builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                    if(snapshot.hasError){
                      return  const Text('Error');
                    }
                    if(!snapshot.hasData){
                      return const CircularProgressIndicator();
                    }

                    final monthlybills = snapshot.data!.docs;


                    return SizedBox(height: 170,
                    width: double.infinity,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: monthlybills.length,
                      itemBuilder: (context,index){
                        final monthly = monthlybills[index];
                        String dateTimeStr = monthly['datetime'];
                        dateTimeStr = dateTimeStr.replaceAll('–', '-');

                        DateTime now = DateTime.now();

                        Color borderColor;
                        DateTime dueDate = DateFormat('yyyy-MM-dd - HH:mm').parse(dateTimeStr);

                        String status;

                      if(now.isAfter(dueDate)){
                          borderColor = Colors.red;
                      }else if(now.isAtSameMomentAs(dueDate)){
                          borderColor = Colors.green;
                      }else{
                            borderColor = Colors.orange;
                      }

                      if(monthly['status'] == ('paid')){
                            status = 'Status: Paid';
                      }else{
                           status = 'Status: unpaid';
                      }



                      return Padding(padding:  const EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                      child:Card(
                        elevation: 5,
                        shape:RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                      
                        ),
                           
                            child:Container( 
                               decoration: BoxDecoration(
                                border: Border.all(color: borderColor,width: 2),
                              ),
                            child:Padding(padding: EdgeInsets.all(16) 
                             ,
                              child: Column(
                                children: [
                              Text('Due Date: ${monthly['datetime']}'),
                              SizedBox(height: 5),

                            
                               Text(status) ,



                              monthly['status'] == ('paid')?   
                              SizedBox(width: 150,
                              child: ElevatedButton(onPressed: () {},
                                style:ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape:RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                  )
                                ),
                               child: Text('Already Paid')),
                              )
                                : 
                                  SizedBox(width: 150,
                              child: ElevatedButton(onPressed: () {

                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> paymentTransaction(userid: widget.userid, salesId: monthly.id)));

                              },
                                style:ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape:RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                  )
                                ),
                               child: Text('Pay now')),
                              )
                             


                            ]

                              ),
                               

                            ),
                           
                          ),
                          )
                      );


                      }
                      ),
                      );
                }
                ),
            ]else ...[
              const Center(child: Text('Loading Information Bills'),)
            ],



         
                              
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

  Widget _RequestKeyPage() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child:Image.network('${userProfile}')
            ),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Remarks',
                hintText: 'Please specify the person and your relationship with the contractee',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
           ElevatedButton(onPressed: sendRequest,style:ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 70),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape:RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          )
           
      ), child: const Text('Send Request')
          )  ],
        ),
      );
  }


Widget _TransactionHistory(){
    return Padding(padding: const EdgeInsets.all(16.0),
    child:Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Transaction History',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),

        Expanded(child:  StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('sales_record')
          .where('uid',isEqualTo: mainAccountId)
          .snapshots(), 
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if(snapshot.hasError){
              return Text('Error: ${snapshot.error}');

            }
            if(!snapshot.hasData){
              return const CircularProgressIndicator();

            }

            final monthlyHistory = snapshot.data!.docs;

           return ListView.builder(
              itemCount: monthlyHistory.length,
              itemBuilder: (context,index){
              
             final history = monthlyHistory[index];

              return Card(
                child: InkWell(
                  onTap: (){

                  },
                  child:ListTile(
                    title: Text('${history['month']}  ${history['year']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('Status: ${history['status']}'),
                       
                         Text('Rental Cost: ${history['rental_cost']}'),
                      ],
                    ) ,
                  ) ,
                ),
              );


            });




          }
          )
          )
      ],
    ),
    );
  }



}
