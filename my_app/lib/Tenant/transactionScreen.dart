



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/Tenant/homePage.dart';

class Transactionscreen extends StatefulWidget{
    final String userid;
    final String salesId;

   const Transactionscreen({Key? key,required this.userid, required this.salesId});

@override   
  _TransactionscreenState createState() =>  _TransactionscreenState();
}

class  _TransactionscreenState  extends State<Transactionscreen> {

  final _firestore = FirebaseFirestore.instance;
  
  String? Date;
  String? PayerName;
  String? Amount;
  String? Status;


  Future <void>  getTransaction() async {

      DocumentSnapshot documentSnapshot = await _firestore.collection('sales_record')
      .doc(widget.salesId)
      .get();


      if(documentSnapshot.exists){
          Map<String,dynamic> transactionData  = documentSnapshot.data() as Map<String,dynamic>;

          setState(() {
            Date = transactionData['month'];
            PayerName = transactionData['payer_name'];
            Amount = transactionData['Amount'];
            Status = transactionData['status'];
          });



      }

  }
@override
  void initState(){
    super.initState();
 getTransaction();

  }

  
  @override
  Widget build(BuildContext context) {

      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                   Text('Transaction Details',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  Text('Month of October',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                   const SizedBox(height: 100),
                    Image.asset('assets/img/200w.gif'),
                    const SizedBox(height: 10),
                    const Text('Transaction Complete',style:TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                    const SizedBox(height: 10),
                    Text('Month: ${Date ?? ''}',style:const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                       const SizedBox(height: 10),
                    Text('Payername: ${PayerName ?? ''}',style:const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                       const SizedBox(height: 10),
                    Text('Amount: ${Amount ?? ''}',style:const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                      Text('Status: ${Status ?? ''}',style:const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                    const SizedBox(height: 20,),
                    
                      ElevatedButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> homePage(userid: widget.userid)));
                      }, child: const Text('Okay'))  















                ]


              ),

        )
      );
      


  }


  





}
