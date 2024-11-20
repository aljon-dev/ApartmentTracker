
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_app/firebase_options.dart';
import 'package:my_app/loginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( 
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const splashScreen(),
    );
  }
}

class splashScreen  extends StatelessWidget{
  const splashScreen({super.key});

  @override
  Widget build(BuildContext context) {

   return Scaffold(
    body: Stack(
      children: [
        Container(decoration: const BoxDecoration(
          image:DecorationImage(image:AssetImage('assets/img/apartembg.jpg'),
          fit:BoxFit.cover
          )
        ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(padding: EdgeInsets.only(top: 80.0),
            child: Center(
              child:SizedBox(
                width: double.infinity,
                child:Card(
                  color: Colors.black26,
                  child: Center(
                    child: Text('APT TRACKER',style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
                ) ,
                  )
                )
              )
              ),
            ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: ElevatedButton(
                    onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
          ],
        ),


      ],
    ),
   );
  }

  
}