import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Maintenancerequestpage extends StatefulWidget {
  final userid;
  const Maintenancerequestpage({super.key, required this.userid});

  @override
  _MaintenancerequestpageState createState() => _MaintenancerequestpageState();
}

class _MaintenancerequestpageState extends State<Maintenancerequestpage> {
  final TextEditingController _messageController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final picker = ImagePicker();

    
  List<String> priority = ['Low', 'Medium', 'High'];
  String? selectedPriority;

  String username = "";

  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("no Image Selected")));
      }
    });
  }

  Future<void> _sendRequest() async {
    try {
      String? imageUrl;
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('maintenance_images/${DateTime.now().toIso8601String()}');

        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }
      
      await _firestore.collection('maintenance_request').add({
        'Image': imageUrl,
        'Message': _messageController.text,
        'Status': "pending",
        'Priority': selectedPriority,
        'Userid': widget.userid,
      });

          final notifications  =  {
          'isRead':false,
          'title':'Maintenance Request',
          'message':_messageController.text,
          'type': 'Maintenance',
          'timestamp':Timestamp.now(),
          'userId':'userAdmin'
         };

    await  _firestore.collection('Notifications').add(notifications);


      _messageController.text = "";
      _imageFile = null;

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Send Request Successfully'),backgroundColor: Colors.green,));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'),backgroundColor: Colors.red,));
    }
  }

/*
  Future<void> getUserDetails() async {
    DocumentSnapshot getuser =
        await _firestore.collection('tenant').doc(widget.userid).get();
    if (getuser.exists) {
      setState(() {
        username = getuser['username'];
      });
    } else {}
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }
 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
             const Text('Priority Level',style:TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(
                width: double.infinity,
                child: DropdownButton<String>(
                  value: selectedPriority,
                  isExpanded: true,
                  hint: const Text('Select Priority'),
                  items: priority.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPriority = newValue;
                    });
                  },
                ),
              ),


                const Text('Maintenance Request',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Message:', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 10),

              
                TextField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                        hintText: 'Enter an Maintenance Request Here',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ))),
                const SizedBox(height: 20),
                const Text('Image',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[200],
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: _pickImage,
                                child: const Text('Upload an Image',
                                    style: TextStyle(fontSize: 20)))
                          ],
                        )
                      : Image.file(_imageFile!, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                Center(
                    child: SizedBox(
                  width: 250,
                  child: ElevatedButton(
                      onPressed: _sendRequest,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text('Send Request')),
                ))
              ],
            ),
          ),
        ));
  }
}
