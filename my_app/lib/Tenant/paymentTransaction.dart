import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/Tenant/transactionScreen.dart';

class paymentTransaction extends StatefulWidget {
  final String userid;
  final String salesId;
  const paymentTransaction({Key? key, required this.userid, required this.salesId});

  _paymentTransactionState createState() => _paymentTransactionState();
}

class _paymentTransactionState extends State<paymentTransaction> {

  final _firestore = FirebaseFirestore.instance;
  final picker = ImagePicker();
  File? imagePath;

  String? ImageUrl;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _GcashNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceNumberController =TextEditingController(); 


  Future<void> selectImage() async {
    final ImagePicker = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (ImagePicker != null) {
        imagePath = File(ImagePicker.path);
      }
    });
  }

  Future<void> SubmitDetails () async{ 
    if (_nameController.text.trim().isEmpty || _GcashNumberController.text.trim().isEmpty || _amountController.text.trim().isEmpty || imagePath == null){
         
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fill the Fields')));

    }else{
      try{
        final filename = DateTime.now().millisecondsSinceEpoch.toString();

      final StorageRef = FirebaseStorage.instance.ref();

      final imageRef = StorageRef.child('GcashImages/ filename');

      UploadTask uploadpic  = imageRef.putFile(imagePath!);
      final snapshot = await uploadpic.whenComplete(() {});
      ImageUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('sales_record').doc(widget.salesId).update({
            'imageUrl' : ImageUrl,
            'payer_name':  _nameController.text,
            'GcashNumber': _GcashNumberController.text,
            'Amount':  _amountController.text,
            'ReferenceNumber':_referenceNumberController.text,
            'status':'Under Review'
      });
  
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submitted Successfully',
      style:TextStyle(color:Colors.white), 
      ),
       backgroundColor:Colors.green,
       behavior: SnackBarBehavior.floating,
       duration: Duration(seconds: 2),
      )
      );

      Navigator.push(context, MaterialPageRoute(builder: (context)=> Transactionscreen(userid: widget.userid, salesId: widget.salesId)));

      }catch (e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error to input $e")));
      }
    
    }

  }

  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Transaction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/img/qrcode.jpg',
                width: 300,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Gcash Transaction Receipt ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            imagePath == null ? SizedBox(height: 150 ,width: double.infinity ,
            child: Card(child:InkWell(
              onTap: selectImage,
              child: const Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file_rounded),
                  SizedBox(height: 20,),
                  Text('Click to Upload Image Here')
                ],
              )
              ) ,
            )
            )
            ) 
            
            : Center(child: Image.file(imagePath!, width:300,height: 300, ),),
          const  SizedBox(height: 10),
          const Text("Transaction Form",style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
          const  SizedBox(height: 10),


          const Text('Name',style: TextStyle(fontSize: 20),),
          const  SizedBox(height: 10),
          TextField(
            controller:_nameController ,
            decoration:  InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
            ),
          ),


          SizedBox(height: 10,),
           const Text('Gcash Number',style: TextStyle(fontSize: 20),),
          const  SizedBox(height: 10),
          TextField(
            controller: _GcashNumberController,
            decoration:  InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Gcash Number',
            ),
          ),
          SizedBox(height:10),
          const Text('Reference Number'),
          TextField(
            controller: _referenceNumberController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Reference Number',
          )
          ),


           SizedBox(height: 10,),
           const Text('Exact Amount',style: TextStyle(fontSize: 20),),
          const  SizedBox(height: 10),
          TextField(
            controller: _amountController,
            decoration:  InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Exact Amount',
            ),
          ),



          SizedBox(height: 10),

          SizedBox(width: double.infinity,
          child:  ElevatedButton(onPressed: SubmitDetails,
          style:ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape:RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              )
          ), child: Text('Pay Now ')),
          )

          ]
        ),
      ),
      )
    );
  }
}
