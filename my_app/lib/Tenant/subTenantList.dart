import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class subTenantlist extends StatefulWidget {
  final userid;
  const subTenantlist({Key? key, required this.userid}) : super(key: key);

  @override
  _subTenantlistState createState() => _subTenantlistState();
}

class _subTenantlistState extends State<subTenantlist> {
  final _firestore = FirebaseFirestore.instance;
  final _firestorage = FirebaseStorage.instance;


  void EditDialog(BuildContext context, String subAccountId) {
  String? imageUrl;
  File? imageFile;
  bool _isPasswordVisible = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final TextEditingController contactController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  // Fetch user details function
  Future<void> fetchUserDetails() async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Sub-Tenant')
          .doc(subAccountId)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> userData = documentSnapshot.data() as Map<String, dynamic>;
        
        imageUrl = userData['image'];
        contactController.text = userData['contact'];
        usernameController.text = userData['name'];
        passController.text = userData['password'];
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch the users'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'))
      );
    }
  }

  // Upload image function
  Future<void> uploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        // Since we're not in a StatefulWidget, we need to rebuild the dialog
        Navigator.of(context).pop();
        EditDialog(context, subAccountId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Image Selected'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: ${e.toString()}'))
      );
    }
  }

  // Update user function
  Future<void> updateUser() async {
    try {
      String? downloadUrl = imageUrl;
      
      if (imageFile != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance.ref().child('Images/$fileName');
        UploadTask uploadTask = storageRef.putFile(imageFile!);
        
        TaskSnapshot snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      await _firestore.collection('Sub-Tenant').doc(subAccountId).update({
        'image': downloadUrl,
        'contact': contactController.text,
        'name': usernameController.text,
        'password': passController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Updated Successfully'))
      );
      Navigator.of(context).pop(); // Close dialog after successful update
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user: ${e.toString()}'))
      );
    }
  }

  // Custom widget functions
  Widget customTextField(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget customText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  fetchUserDetails();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Sub-Tenant'),
        content: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageFile != null)
                  Image.file(imageFile!)
                else if (imageUrl != null)
                  Image.network(imageUrl!),
                
                const SizedBox(height: 20),
                
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: uploadImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Upload Image'),
                  ),
                ),

                const SizedBox(height: 10),
                customText('Contact Number'),
                const SizedBox(height: 5),
                customTextField('Your Contact Number', contactController),
                
                const SizedBox(height: 10),
                customText('Username'),
                const SizedBox(height: 5),
                customTextField('Your Username', usernameController),
                
                const SizedBox(height: 10),
                customText('Password'),
                const SizedBox(height: 5),
                TextField(
                  controller: passController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "Type Your Password",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _isPasswordVisible = !_isPasswordVisible;
                        // Since we're not in a StatefulWidget, we need to rebuild the dialog
                        Navigator.of(context).pop();
                        EditDialog(context, subAccountId);
                      },
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: updateUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Update Account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('List of Sub Tenants')),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('Sub-Tenant')
                            .where('mainAccountId', isEqualTo: widget.userid)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text('Something went wrong'));
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(child: Text('No sub-tenants found'));
                          }

                          final subTenants = snapshot.data!.docs;
                          return ListView.builder(
                              itemCount: subTenants.length,
                              itemBuilder: (context, index) {
                                final subTenant = subTenants[index].data()  as Map<String, dynamic>;

                                return Card(
                                    child: InkWell(
                                        child: Container(
                                            height: 150,
                                            width: double.infinity,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                children: [
                                                Padding(
                                                  padding: EdgeInsets.all(20),
                                                  child: Column(
                                                    children: [
                                                      customText(subTenant['name'],'Name'),
                                                      customText(subTenant['remarks'],'remarks'),
                                                      Center(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            ElevatedButton(onPressed: () async {
                                                              try{
                                                               _firestore.collection('Sub-Tenant').doc(subTenants[index].id).delete();
                                                              
                                                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sub Tenant Deleted')));
                                                              }catch(e){
                                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to Delete')));
                                                              }
                                                      
                                                            }, child: Text('Delete'),
                                                            style:ElevatedButton.styleFrom(
                                                              foregroundColor: Colors.white,
                                                              backgroundColor: Colors.red[500],
                                                              shape:RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12)
                                                              )
                                                            )),
                                                            const SizedBox(width: 20,),
                                                              ElevatedButton(onPressed: (){

                                                                EditDialog(context,subTenants[index].id);

                                                              }, child: Text('Edit User'),
                                                            style:ElevatedButton.styleFrom(
                                                              foregroundColor: Colors.white,
                                                              backgroundColor: Colors.yellow[900],
                                                              shape:RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12)
                                                              )
                                                            ))
                                                          ],
                                                        ),
                                                      )


                                                    ],
                                                  ),
                                                )
                                              ],
                                            ))));
                              });
                        }))
              ]),
        ));
  }

  Widget customText(String title, String Role) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text('${Role}:',style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  
                ),),
                const SizedBox(width: 5,),
                Text('${title}',style: TextStyle(fontSize: 20),)
            ],
    );
  }

 
}
