import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/Home.dart';

import 'signup.dart';


// final FirebaseAuth _auth = FirebaseAuth.instance;

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asu CarPool',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Login Page'),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        'signin':(context)=>MyHomePage(title:'Login Page'),
        '/signup': (BuildContext context) => new SignupPage(),
        '/Home':(context)=> Home(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _success = 1;
  String _userEmail = "";

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          children:[ Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
                      child: Row(
                        children: <Widget>[
                          ClipOval(
                            child: Image.asset(
                              'Assets/asu.png', // Path to your image
                              width: 80.0, // Set the width of the image
                              height: 80.0, // Set the height of the image
                              fit: BoxFit.cover, // Cover ensures the image fills the space, might crop if not a square
                            ),
                          ),
                          SizedBox(width: 10.0), // Provide some horizontal spacing
                          Text(
                            "ASU CarPool Service",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 35, left: 20, right: 30),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelText: 'EMAIL',
                          labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          )
                      ),
                    ),
                    SizedBox(height: 20,),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          labelText: 'PASSWORD',
                          labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          )
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 5.0,),
                    Container(
                      alignment: Alignment(1,0),
                      padding: EdgeInsets.only(top: 15, left: 20),
                      child: InkWell(
                        child: Text(
                          'Forgot Password',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              decoration: TextDecoration.underline
                          ),
                        ),
                      ),
                    ),
                    Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _success == 1
                              ? ''
                              : (
                              _success == 2
                                  ? 'Successfully signed in ' + _userEmail
                                  : 'Sign in failed'),
                          style: TextStyle(color: Colors.red),
                        )
                    ),
                    SizedBox(height: 40,),
                    Container(
                      height: 40,
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        shadowColor: Colors.greenAccent,
                        color: Colors.blueAccent,
                        elevation: 7,
                        child: GestureDetector(
                            onTap: () {
                              FirebaseAuth.instance.signInWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text
                              ).then((userCredential) async {
                                // Check if a document exists for the user in the 'users' collection
                                DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('drivers').doc(userCredential.user!.uid).get();

                                if (!userDoc.exists) {
                                  // If the document exists, navigate to the Home screen
                                  Navigator.pushReplacementNamed(context, '/Home');
                                } else {
                                  // If the document does not exist, show an error dialog
                                  FirebaseAuth.instance.signOut(); // Sign out the user
                                  _showAlertDialog('Error', 'This account does not have access to the user app.');
                                }
                              }).onError((error, stackTrace) {
                                if (error is FirebaseAuthException) {
                                  _showAlertDialog('Error', 'User not found or incorrect password.');
                                } else {
                                  _showAlertDialog('Error', 'An unexpected error occurred. Please try again.');
                                }
                              });

                            },
                            child: Center(
                                child: Text(
                                    'LOGIN',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat'
                                    )
                                )
                            )
                        ),
                      ),
                    ),
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed('/signup');
                          },
                          child: Text(
                              'Register',
                              style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline
                              )
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
      ]
        )
    );
  }

}