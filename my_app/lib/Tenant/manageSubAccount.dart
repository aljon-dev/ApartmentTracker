





import 'package:flutter/material.dart';
import 'package:my_app/Tenant/createSubAccount.dart';
import 'package:my_app/Tenant/subTenantList.dart';

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

        buildAddUserCard(context,widget.userid,"AddSub"),
          const SizedBox(height: 20),

        buildAddUserCard(context,widget.userid,"SubTenant List"),
          const SizedBox(height: 20),

          ],
        ),

      
    ),
    )
    );
  }
}

Widget buildAddUserCard(BuildContext context,String userid,String title){
    return SizedBox(width: 200,height: 150,
    child:InkWell(
      onTap:(){
        switch(title){
          case "AddSub":  Navigator.push(context, MaterialPageRoute(builder: (context)=> createSubAccount(userid: userid) ));
          break;
          case "SubTenant List":  Navigator.push(context, MaterialPageRoute(builder: (context)=> subTenantlist(userid: userid) ));
         
       
        }
      },
    child: Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side:const BorderSide(color:Colors.green, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child:   Padding(padding: EdgeInsets.all(16),
      child: Column(
        children: [
         const  Icon(Icons.person_add,size:50,color:Colors.blue),
           const SizedBox(height: 10),
            Text(title,style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
        ],
      ),
      ),
    ) ,
    ),
    );
    

}
