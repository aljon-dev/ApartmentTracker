



import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class editAccountSubPage extends StatefulWidget{
    final String userid;
    const editAccountSubPage  ({Key? key, required this.userid}) : super(key: key);


@override  
  editAccountPageState createState() => editAccountPageState();
}


class editAccountPageState extends State<editAccountSubPage >{

  final _firestore = FirebaseFirestore.instance;
  String? imageUrl;

  
  final TextEditingController  contactcontroller = TextEditingController();
  final TextEditingController  usernamecontroller = TextEditingController();
  final TextEditingController  passController = TextEditingController();

  File? imageFile;
  

  bool _isPasswordVisible = false;

  Future<void> fetchuserDetails() async{

      DocumentSnapshot documentSnapshot = await _firestore
      .collection('Sub-Tenant')
      .doc(widget.userid)
      .get();

    if(documentSnapshot.exists){
      Map<String, dynamic> userData = documentSnapshot.data() as Map<String,dynamic>; 

      setState(() {
        imageUrl = userData['image'];
        contactcontroller.text = userData['contact'];
        usernamecontroller.text = userData['name'];
        passController.text = userData['password'];

      });
    
    }else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to Fetch the users')));
    }
  }

  Future <void> updateUser() async {

    try{
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance.ref().child('Images/$fileName');
        UploadTask uploadTask = storageRef.putFile(imageFile!);
          
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
    

    _firestore.collection('Sub-Tenant').doc(widget.userid).update({
        'image':downloadUrl,
        'contact': contactcontroller.text,
        'name': usernamecontroller.text,
        'password': passController.text
        }).then((value){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User Updated Successfully')));
        }).catchError((error){
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error Updating User')));
        });
    }catch(e){
      print(e.toString());
    }
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

  Future <void> updateUser() async {

    try{
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance.ref().child('Images/$fileName');
        UploadTask uploadTask = storageRef.putFile(imageFile!);
          
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
    

    _firestore.collection('Sub-Tenant').doc(widget.userid).update({
        'image':downloadUrl,
        'contact': contactcontroller.text,
        'name': usernamecontroller.text,
        'password': passController.text
        }).then((value){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User Updated Successfully')));
        }).catchError((error){
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error Updating User')));
        });
    }catch(e){
      print(e.toString());
    }
  }

 
 Future<void> fetchuserDetails() async{

      DocumentSnapshot documentSnapshot = await _firestore
      .collection('Sub-Tenant')
      .doc(widget.userid)
      .get();

    if(documentSnapshot.exists){
      Map<String, dynamic> userData = documentSnapshot.data() as Map<String,dynamic>; 

      setState(() {
        imageUrl = userData['image'];
        contactcontroller.text = userData['contact'];
        usernamecontroller.text = userData['name'];
        passController.text = userData['password'];

      });
    
    }else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to Fetch the users')));
    }
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

                imageFile == null ? Image.network(imageUrl!) : Image.file(imageFile!),

                
                     const SizedBox(height: 20,),

                SizedBox(height: 40, width:double.infinity,
                child: ElevatedButton(onPressed: UploadImage,style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white

                ),
                child: const Text('Upload Image')),),


                const SizedBox(height: 10,),

                customText('Contact Number'),
                const SizedBox(height: 5,),
                customTextField('Your Contact Number', contactcontroller),
                 
                const SizedBox(height: 10,),

                customText('Username'),
                const SizedBox(height: 5,),
                customTextField('Your Username', usernamecontroller),
                
                customText('Password'),
                const SizedBox(height: 5,),
                TextField(
                  controller:passController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "Type Your Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none
                    ),
                    suffixIcon: IconButton(onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                    }, icon: Icon( _isPasswordVisible ? Icons.visibility : Icons.visibility_off) )
                  ),
                ),
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