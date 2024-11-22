import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class createSubAccount extends StatefulWidget {
  final String userid; // Changed to explicitly declare as String

  const createSubAccount({super.key, required this.userid});

  @override
  _createSubAccountPage createState() => _createSubAccountPage();
}

class _createSubAccountPage extends State<createSubAccount> {
  File? _imageFile;
  final _picker = ImagePicker();
  String? _imageUrl;

  final _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _remarksController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _addSubAccount() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile image')),
      );
      return;
    }

    if (_nameController.text.isEmpty || 
        _contactController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('Sub-Tenant')
          .where('mainAccountId', isEqualTo: widget.userid)
          .get();

      if (querySnapshot.docs.length >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Limit reached: Cannot add more than 3 sub-accounts.')),
        );
        return;
      }

     
      final String fileName = '${widget.userid}_${DateTime.now().millisecondsSinceEpoch}';
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);
      
      final UploadTask uploadTask = storageRef.putFile(_imageFile!);
      final TaskSnapshot snapshot = await uploadTask;
      _imageUrl = await snapshot.ref.getDownloadURL();

     
      await _firestore.collection('Sub-Tenant').add({
        'mainAccountId': widget.userid,
        'name': _nameController.text.trim(),
        'contact': _contactController.text.trim(),
        'remarks': _remarksController.text.trim(),
        'password': _passwordController.text.trim(),
        'profileImage': _imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

   
      setState(() {
        _imageFile = null;
        _nameController.clear();
        _contactController.clear();
        _remarksController.clear();
        _passwordController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sub-Account Registered Successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Sub Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    _imageFile == null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          )
                        : CircleAvatar(
                            radius: 50,
                            backgroundImage: FileImage(_imageFile!),
                          ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Add Photo'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _remarksController,
                      decoration: const InputDecoration(
                        labelText: 'Remarks',
                        hintText: 'Please specify your relationship with the contractee',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password *',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addSubAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                      ),
                      child: const Text(
                        'Register Account',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _remarksController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}