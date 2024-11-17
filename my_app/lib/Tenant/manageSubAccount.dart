





import 'package:flutter/material.dart';
import 'package:my_app/Tenant/createSubAccount.dart';

class manageSubAccount extends StatefulWidget{
  final userid;
  const manageSubAccount ({super.key,  required this.userid});

  @override
  _manageSubAccountState createState() => _manageSubAccountState();
}

class _manageSubAccountState extends State<manageSubAccount>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
    body:Padding(padding: const EdgeInsets.all(16.0),
    child: Center(
        child: Column(
          children: [

        buildAddUserCard(context,widget.userid),
          const SizedBox(height: 20),

        buildAddUserCard(context,widget.userid),
          const SizedBox(height: 20),

        buildAddUserCard(context,widget.userid),
          const SizedBox(height: 20),
    
          ],
        ),

      
    ),
    )
    );
  }
}

Widget buildAddUserCard(BuildContext context,String userid){
    return SizedBox(width: 200,height: 150,
    child:InkWell(
      onTap:(){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> createSubAccount(userid: userid) ));
      },
    child: Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side:const BorderSide(color:Colors.green, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child:  const Padding(padding: EdgeInsets.all(16),
      child: Column(
        children: [
            Icon(Icons.person_add,size:50,color:Colors.blue),
            SizedBox(height: 10),
            Text('Add User',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
        ],
      ),
      ),
    ) ,
    ),
    );
    

}
