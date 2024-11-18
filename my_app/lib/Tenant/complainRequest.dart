



import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class complainRequest extends StatefulWidget{
    const complainRequest ({Key? key});


@override   
    complainRequestState createState() => complainRequestState();

}


class complainRequestState extends State<complainRequest> {
  
  List<String> priority = ['Low', 'Medium', 'High'];
  String? selectedPriority;

  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _fireAuth = FirebaseAuth.instance;



  final TextEditingController complainTitleController = TextEditingController();
  final TextEditingController complainTextController = TextEditingController();
  DateTime? selectedDate;

Future<void> _selectDate(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: selectedDate ,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (pickedDate != null) {


      final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );


      final DateTime dateOnly = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
    );


    setState(() {
      if ( dateOnly.isAfter(today)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oops! Cannot set a complain in the future'),
          ),
        );
      } else {
       
        selectedDate =  dateOnly;
      }
    });
  }
  }

    Future<void> setcomplaint() async{
        if(_formKey.currentState!.validate()){

       try{

        final String FormattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      
        if(selectedPriority != null  &&  selectedDate  != null){
            final complainData = {
              'Title':complainTitleController.text,
              'Details':complainTextController.text,
              'Priority':selectedPriority,
              'Date':FormattedDate,
              'Status':'Pending',
              'userid':_fireAuth.currentUser!.uid
        };

            final notifications  =  {
                'Title':'Complain Request',
                'Message':complainTextController.text,
                'Types': 'Complaint',
                'DateTime':Timestamp.now(),
                'userid':'userAdmin'
                
            };

      _firestore.collection('Notifications').add(notifications);
      _firestore.collection('Complaints').add(complainData);

          ScaffoldMessenger.of(context)
         .showSnackBar(
          SnackBar(content: Text('Successfully sent the complaint')
          ,backgroundColor: Colors.green,));

    
        }else{
         ScaffoldMessenger.of(context)
         .showSnackBar(
          SnackBar(content: Text('Failed to Add the data')
          ,backgroundColor: Colors.red,));
        }
        }catch(e){
          ScaffoldMessenger.of(context)
         .showSnackBar(
          SnackBar(content: Text(e.toString())
          ,backgroundColor: Colors.red,));
  
      }
     }
    }

   void showEditDialog(BuildContext context, String complainId, Map<String, dynamic> complaintData) {
  TextEditingController editTitleController =
      TextEditingController(text: complaintData['Title']);
  TextEditingController editDetailsController =
      TextEditingController(text: complaintData['Details']);
  String? editSelectedPriority = complaintData['Priority'];
  DateTime? editSelectedDate = DateFormat('yyyy-MM-dd').parse(complaintData['Date']);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Complaint'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Priority',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: editSelectedPriority,
                isExpanded: true,
                hint: const Text('Select Priority'),
                items: priority.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  editSelectedPriority = newValue;
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Complain Title',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: editTitleController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              const Text(
                'Complain Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: editDetailsController,
                maxLines: 3,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: editSelectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    editSelectedDate = pickedDate;
                  }
                },
                child: const Text('Select Date'),
              ),
              Text(
                editSelectedDate != null
                    ? 'Date: ${DateFormat('dd/MM/yyyy').format(editSelectedDate!)}'
                    : 'No Date Selected',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('Complaints').doc(complainId).update({
                  'Title': editTitleController.text,
                  'Details': editDetailsController.text,
                  'Priority': editSelectedPriority,
                  'Date': DateFormat('yyyy-MM-dd').format(editSelectedDate!),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complaint updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating complaint: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}


  @override
  void dispose() {
    // Dispose controllers to free resources
    complainTitleController.dispose();
    complainTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complain Request'),
      ),
      body: Form(
      key: _formKey,
      child:Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Priority',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
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
              
              const SizedBox(height: 16),
              const  Text('Complain Title',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),),
              CustomTextField(complainTitleController, 'Complain Title',1),
              const SizedBox(height: 16),
              const Text('Complain Details',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),),
              CustomTextField(complainTextController, 'Complain Details',3),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              ElevatedButton(
                onPressed: () => _selectDate(context),style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape:RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                  )
                ),
                child: const Text('Select A Date'),
              ),
                    Text(
                selectedDate != null
                    ? ' Date: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}'
                    : 'No Date Selected',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
              ),
                ],
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10,),
              SizedBox(width: double.infinity, 
              child: ElevatedButton(
                onPressed: () => setcomplaint() ,
                style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                  shape:RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                  )
                ),
                child: const Text('Send Complaint'),
              ),
              ),
              const SizedBox(height: 10,),
              Container(
                height: 200,
                child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Complaints')
              .where('userid',isEqualTo: _fireAuth.currentUser!.uid)
              .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots){

                    if(snapshots.hasError){
                      return Text('Error: ${snapshots.error}');
                    }
                    if(!snapshots.hasData){
                      return const Center(child: CircularProgressIndicator());
                    }

                final complaint = snapshots.data!.docs;

              return ListView.builder(
             
                itemCount: complaint.length,
              
                itemBuilder: (context,index){
                  final complaints = complaint[index];

                  String complainId = complaint[index].id;


                  return Card(
                    color:Colors.blue[200],
                    child: Padding(padding: EdgeInsets.all(16),
                    child: Container(

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${complaints['Title']}',style: 
                          const TextStyle(fontSize: 20,
                          fontWeight:FontWeight.bold),
                          ),
                          const SizedBox(height:5,),

                          Text('${complaints['Details']}',style: 
                          const TextStyle(fontSize: 14,
                          ),
                          ),

                           const SizedBox(height:5,),
                          Text('${complaints['Date']}',style: 
                          const TextStyle(fontSize: 14,
                          ),
                          ),

                          Row(
                           mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                                
                                IconButton(
                               icon: const Icon(Icons.edit, color: Colors.yellowAccent),
                               onPressed: () {

                                    showEditDialog(context, complainId, complaints.data() as Map<String,dynamic>);
            
                              },
                              ),
                             IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              try{
                              _firestore.collection('Complaints').doc(complainId).delete();
                             ScaffoldMessenger.of(context)
                             .showSnackBar(
                             SnackBar(content: Text('Successfully Deleted')
                             ,backgroundColor: Colors.green,));

                              }catch(e){

                              ScaffoldMessenger.of(context)
                             .showSnackBar(
                             SnackBar(content: Text('Failed to Delete A Complaint')
                             ,backgroundColor: Colors.red,));

                              }
                                } ,
                              ),                       
                            ],
                          )

                        
                          
                        ],
                      )

                    ),
                    )
                    
                  );
                 
                });
              }) ,
              )
             
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget CustomTextField(TextEditingController controller, String hintText,int maxLines) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        border: const OutlineInputBorder(),
        labelText: hintText,
      ),
      maxLines: maxLines,
      validator:(value){
        if(value!.isEmpty){
          return 'Please Fill The Fields';
        }
        return null;
      }
    );
    
  }
}