





import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/Tenant/manageSubAccount.dart';
import 'package:my_app/loginPage.dart';

class settingsPage extends StatefulWidget{
  final String userid;

  const settingsPage ({super.key, required this.userid});

  @override
  _settingsPageState createState() => _settingsPageState();
  

}

class _settingsPageState extends State<settingsPage> {

  final _firestore = FirebaseFirestore.instance;
  String username = "";
  String userId = "";

  bool isPushNotificationEnabled = true;



  Future<void> getUserDetails() async {

    DocumentSnapshot documentSnapshot = await _firestore.collection('tenant').doc(widget.userid).get();

    Map<String,dynamic>? userDoc = documentSnapshot.data() as Map<String,dynamic>?;

    if(userDoc != null){
      setState(() {

        username = userDoc['username'] ?? 'No username Found';
        userId = documentSnapshot.id;
        
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
          const CircleAvatar(
            backgroundColor: Colors.grey,
            child:Icon(Icons.person,color: Colors.white)
          ),
          title: Text(username),
          subtitle: const Text('Tenant'),
          trailing: const Icon(Icons.notifications_active_outlined),
        ),
        const SizedBox(height: 20),

        const Text('Settings', style:TextStyle(fontSize: 18,fontWeight:  FontWeight.bold)),

        

        ListTile(
         leading: const Icon(Icons.person_2_outlined,color:Colors.blue),
         title:const Text('Manage Sub Account'),
  
         onTap: (){
              
              Navigator.push(context, MaterialPageRoute(builder: (context)=> manageSubAccount(userid: userId)));

         },
        ),

        ListTile(
          leading:const Icon(Icons.logout,color:Colors.blue),
          title:Text('Log Out'),

          onTap:(){
              
          }

        ),

        const Divider(),
        
      


      ],
    ),
    )


    );
  }

}