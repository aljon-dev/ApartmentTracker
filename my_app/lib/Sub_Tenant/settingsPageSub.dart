





import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/Sub_Tenant/editAccountSub.dart';
import 'package:my_app/Tenant/notificationPage.dart';
import 'package:my_app/loginPage.dart';

class settingsPageSub extends StatefulWidget{
  final String userid;

  const settingsPageSub ({super.key, required this.userid});

  @override
  _settingsPageSubState createState() => _settingsPageSubState();
  

}

class _settingsPageSubState extends State<settingsPageSub> {

  final _firestore = FirebaseFirestore.instance;
  String username = "";
  String userId = "";
  String imageUser = "";

  bool isPushNotificationEnabled = true;



  Future<void> getUserDetails() async {

    DocumentSnapshot documentSnapshot = await _firestore.collection('Sub-Tenant').doc(widget.userid).get();

    Map<String,dynamic>? userDoc = documentSnapshot.data() as Map<String,dynamic>?;

    if(userDoc != null){
      setState(() {

        username = userDoc['name'] ?? 'No username Found';
        userId = documentSnapshot.id;
        imageUser = userDoc['image'];
        
      });
    } 
  }

  @override
  void initState(){
    super.initState();

        getUserDetails();
  
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
    body:Padding(padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: 
          CircleAvatar(
            backgroundColor: Colors.grey,
            child:Image.network(imageUser)
          ),
          title: Text(username),
          subtitle: const Text('Sub Tenant'),
          trailing: InkWell(
            onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> notificationPage(userid: widget.userid)));
            },
            child: Icon(Icons.notifications_active_outlined),
          ) ,
        ),
        const SizedBox(height: 20),

        const Text('Settings', style:TextStyle(fontSize: 18,fontWeight:  FontWeight.bold)),

        SwitchListTile(
          title:const Text('Push Notification'),
          value: isPushNotificationEnabled,
          onChanged: (bool value){
          setState(() {
            isPushNotificationEnabled = value;
          });
        },
        activeColor: Colors.green,
        ),

      
          ListTile(
          leading:const Icon(Icons.settings,color:Colors.blue),
          title:Text('Edit Account '),
          onTap:(){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> editAccountSubPage(userid: widget.userid)));
          }

        ),

          const Divider(),
        ListTile(
          leading:const Icon(Icons.logout,color:Colors.blue),
          title:Text('Log Out'),

          onTap:(){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginPage()));
          }

        ),

        const Divider()

      ],
    ),
    )
    );
  }
}