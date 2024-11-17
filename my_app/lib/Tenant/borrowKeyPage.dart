




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class borrowKeyPage extends StatefulWidget{
  final String userid;
  final String username;
 const borrowKeyPage({super.key,  required this.userid, required this.username});


  @override 
  _borrowKeyPageState createState() => _borrowKeyPageState();

}

class  _borrowKeyPageState extends State<borrowKeyPage>{
  final TextEditingController  _RemarksController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  String RequestType = 'My Unit';
  String unitnumber = '';
  String buildingnumber = '';
 


  Future<void> sendRequest () async { 

      try{
          if(_RemarksController.text.isEmpty || RequestType.isEmpty){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
          }else{
            _firestore.collection('borrow_keys').add({
              'buildingnumber':  buildingnumber,
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
  
  Future <void> _tenantDetails () async{ 
      try{
         DocumentSnapshot tenantDetails =  await _firestore.collection('tenant').doc(widget.userid).get();
         if(tenantDetails.exists){
          setState(() {
            unitnumber = tenantDetails['unitnumber'];
            buildingnumber = tenantDetails['buildingnumber'];
            
          });
        
         }else{
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tenant Details doesnt Exist')));
         }

 


      }catch (e){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:  Text('$e')));
      }

  }
  
  @override
  initState()  {
    super.initState();
    _tenantDetails();


  }
 
 
 
  @override
  Widget build(BuildContext context) {
   return Scaffold(
        appBar: AppBar(
          title: const Text('Borrow Key'),
        ),
        body: Padding(padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

              Card(
          child: ListTile(
              tileColor: RequestType == 'My Unit' ? const Color.fromARGB(255, 221, 124, 12) : const Color.fromARGB(185, 248, 248, 248),
              title: const Text('My Unit ',style:TextStyle(fontWeight: FontWeight.bold)),
              leading: const Icon(Icons.person_2 , color:Colors.blue),
              onTap: (){
                setState(() {
                  RequestType = 'My Unit';
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Set to $RequestType')));
                
              },
          ),    
        ),

            Card(
          child: ListTile(
              tileColor: RequestType == 'Relatives' ? const Color.fromARGB(255, 221, 124, 12) : const Color.fromARGB(185, 248, 248, 248),
              title: const Text('Relatives ',style:TextStyle(fontWeight: FontWeight.bold)),
              leading: const Icon(Icons.person_2 , color:Colors.blue),
              onTap: (){
                setState(() {
                  RequestType = 'Relatives';
                 
                });
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Set to $RequestType')));
                
              },
          ),    
        ),

             Card(
          child: ListTile(
              tileColor: RequestType == 'Friends' ? const Color.fromARGB(255, 221, 124, 12) : const Color.fromARGB(185, 248, 248, 248) ,
              title: const Text('Friends ',style:TextStyle(fontWeight: FontWeight.bold)),
              leading: const Icon(Icons.person_2 , color:Colors.blue),
              onTap: (){
                setState(() {
                  RequestType = 'Friends';
                });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Set to $RequestType')));
                
              },
          ),    
        ),
        const SizedBox(height: 10,),
      const Text('Remarks:',style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
      Card(
        
        child: Padding(padding: const EdgeInsets.all(16),
        child: TextField(
          maxLines: 4,
          controller: _RemarksController,
          
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),),
      ),
      const SizedBox(height: 10),
      Center(
        child:  ElevatedButton(onPressed: sendRequest,style:ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 70),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape:RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          )
      ), child: const Text('Send Request')) ,
      )

    

           
           
        

          ],
        ),
        
        ),
   );
  }

  


}