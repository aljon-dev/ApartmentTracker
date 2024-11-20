



import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class editAccountPage extends StatefulWidget{
    final String userid;
    const editAccountPage ({Key? key, required this.userid}) : super(key: key);


@override  
  editAccountPageState createState() => editAccountPageState();
}


class editAccountPageState extends State<editAccountPage>{

  final _firestore = FirebaseFirestore.instance;

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController middlenameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController  contactcontroller = TextEditingController();
    final TextEditingController  usernamecontroller = TextEditingController();
  final TextEditingController  passController = TextEditingController();

  File? imageFile;
  String? imageUrl;

  bool _isPasswordVisible = false;

  Future<void> fetchuserDetails() async{

      DocumentSnapshot documentSnapshot = await _firestore
      .collection('tenants')
      .doc(widget.userid)
      .get();

    if(documentSnapshot.exists){
      Map<String, dynamic> userData = documentSnapshot.data() as Map<String,dynamic>; 

      setState(() {
        imageUrl = userData['profile'];
        firstnameController.text = userData['firstname'];
        middlenameController.text = userData['middlename'];
        lastnameController.text = userData['lastname'];
        contactcontroller.text = userData['contact'];
        usernamecontroller.text = userData['username'];
     
      });
    
    }else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to Fetch the users')));
    }
  }

  Future <void> updateUser() async {

       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance.ref().child('Images/$fileName');
        UploadTask uploadTask = storageRef.putFile(imageFile!);
          
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

    _firestore.collection('tenant').doc(widget.userid).update({
        'profile': downloadUrl,
        'firstname': firstnameController.text,
        'middlename': middlenameController.text,
        'lastname': lastnameController.text,
        'contactnumber': contactcontroller.text,
        'username': usernamecontroller.text,
        }).then((value){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User Updated Successfully')));
        }).catchError((error){
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error Updating User')));
        });
  }

Future<void> UploadImage() async{
      final picker = ImagePicker();
      final PickedFile = await picker.pickImage(source: ImageSource.gallery);

      if(PickedFile != null){
          setState(() {
            imageFile = File(PickedFile.path);
          });
      }else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Image Selected')));
      }
          
  }





@override 
  void initState(){
    super.initState();
    fetchuserDetails();
  }


  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Account'),
        backgroundColor: Colors.blueAccent,
      ),

      body:Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Center(
          child: SingleChildScrollView(
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

               imageUrl == null  ? Center(child:Text('No Image Profile Found ') ,) : Image.network(imageUrl!),

               SizedBox(height: 20),
         const  Text('Image Preview',style:TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold
     )),
               imageFile == null ? Text('No Image Selected') : Image.file(imageFile!),
              const   SizedBox(height: 10),
           

               SizedBox(height: 40, width:double.infinity,
                child: ElevatedButton(onPressed: UploadImage,style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white

                ),
                child: const Text('uploadImage')),),
              
              const SizedBox(height: 5,),

                customText('Firstname'),
                const SizedBox(height: 5,),
                customTextField('Your First Name', firstnameController),

                const SizedBox(height: 10,),

                customText('Middlename'),
                const SizedBox(height: 5,),
                customTextField('Your Middle Name', middlenameController),

                const SizedBox(height: 10,),

                customText('Lastname'),
                const SizedBox(height: 5,),
                customTextField('Your Last Name', lastnameController),

                const SizedBox(height: 10,),

                customText('Contact Number'),
                const SizedBox(height: 5,),
                customTextField('Your Contact Number', contactcontroller),
                 
                const SizedBox(height: 10,),

                customText('Username'),
                const SizedBox(height: 5,),
                customTextField('Your Username', usernamecontroller),
                
                const SizedBox(height: 20,),

                SizedBox(height: 40, width:double.infinity,
                child: ElevatedButton(onPressed: updateUser,style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white

                ),
                child: const Text('Update Account')),)

            ]
          ),
          )
        ),
      )
    );
  }


  Widget customTextField(String hintText,TextEditingController controller,){

    return TextField(
        controller:controller ,
        decoration:InputDecoration(
          hintText:hintText,
          filled:true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none
          ),
        ) ,
    );

  }

  Widget customText(String text){
      return Text(text,style:const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold
      ),
      );
  }

  
}