



import 'dart:core';

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




  final TextEditingController complainTitleController = TextEditingController();
  final TextEditingController complainTextController = TextEditingController();
  DateTime? selectedDate;

Future<void> _selectDate(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: selectedDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (pickedDate != null) {
    setState(() {
      if (pickedDate.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oops! Cannot set a complain in the future'),
          ),
        );
      } else {
       
        selectedDate = pickedDate;
      }
    });
  }
  }

    Future<void> setcomplaint() async{
      

      
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
      body: Padding(
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
              CustomTextField(complainTitleController, 'Complain Title'),
              const SizedBox(height: 16),
              const Text('Complain Details',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),),
              CustomTextField(complainTextController, 'Complain Details'),

              const SizedBox(height: 10),
              Text(
                selectedDate != null
                    ? 'Selected Date: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}'
                    : 'No Date Selected',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
              ),
              const SizedBox(height: 10),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget CustomTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        border: const OutlineInputBorder(),
        labelText: hintText,
      ),
    );
  }
}