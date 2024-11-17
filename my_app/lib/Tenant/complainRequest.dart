



import 'dart:core';

import 'package:flutter/material.dart';

class complainRequest extends StatefulWidget{
    const complainRequest ({Key? key});


@override   
    complainRequestState createState() => complainRequestState();

}


class complainRequestState extends State<complainRequest> {
  
    List<String> priority = ['Low','Medium','High'];
    String? selectedPriority;

    final TextEditingController complainTitleController = TextEditingController();
    final TextEditingController complainTextController = TextEditingController();
    DateTime? selectedDate;


  Future<void> _selectDate(BuildContext context) async{
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(), 
        firstDate: DateTime(2000), 
        lastDate: DateTime(2100)
        );
  }

  
  @override
  Widget build(Object context) {
      return Scaffold(
        appBar: AppBar(),
        body: Padding(padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text('Select Priorities',style:  TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),),
              const SizedBox(height: 10,),
              DropdownButton<String>(
                value:selectedPriority,
                hint: const Text('Select Priority'),
                items: priority.map((String value){
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue){
                  setState(() {
                    selectedPriority = newValue;
                  });
                }),

                const SizedBox(height: 10,),
                Text(
                    selectedDate != null ? 'Selected Date: ${selectedDate!.toLocal()}'.split('')[0]
                    : 'No Date Selected',
                ),
                SizedBox(height: 16,),
                ElevatedButton(onPressed: () => _selectDate, child:const Text('Select A Date'))
             


              

            ],
          ),
        ),),
      );
  }

  Widget CustomTextField(TextEditingController controller, String hintText )
  {

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(), 
        labelText: hintText,

      ),
    );
  }
}