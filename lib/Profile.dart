import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sqlflite.dart';
import 'package:connectivity/connectivity.dart';
import 'Home.dart';


class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  LocalDatabase mydb=LocalDatabase();
  User? currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

void Reading()async{

  if (currentUser != null) {
    String uid = currentUser!.uid;
    String query = "SELECT * FROM USERS WHERE ID = '$uid'";
    var response = await mydb.read(query);

    if (response.isNotEmpty) {
      // Assuming 'response' is a list of maps
      Map<String, dynamic> userRow = response[0];
      _firstNameController.text=userRow['firstname'].toString();
      _lastNameController.text=userRow['lastname'].toString();
      _passwordController.text='';
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {

        await firestore.collection("users").doc(currentUser!.uid)
            .update({
          'firstname': _firstNameController.text,
          'lastname': _lastNameController.text
        });
      }


      setState(() {
        _firstNameController.text=userRow['firstname'].toString();
        _lastNameController.text=userRow['lastname'].toString();
        _passwordController.text='';
      });
    }
  }

}
  @override
  void initState() {
        Reading();
      // TODO: implement initState
      super.initState();
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ClipOval(
                child: Image.asset(
                  'Assets/asu.png',
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                ),
              ),
              SizedBox(width: 8), // For spacing between the logo and title
              Text('Edit Your Profile'),
            ],
          ),
        ),
        body:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    _buildTextField(_firstNameController, "First Name"),
                    SizedBox(height: 20),
                    _buildTextField(_lastNameController, "Last Name"),
                    SizedBox(height: 20),
                    _buildTextField(_passwordController, "Password", isPassword: true),
                    SizedBox(height: 40),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.blue,
                      child: MaterialButton(
                        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                        onPressed: () async{
                          var connectivityResult = await (Connectivity().checkConnectivity());

                          if(_passwordController.text=='')
                            {
                              String query = "UPDATE USERS SET firstname = '${_firstNameController.text}', lastname = '${_lastNameController.text}' WHERE ID = '${currentUser!.uid}'";

                            if (connectivityResult == ConnectivityResult.none) {
                              await mydb.update(query);

                              Navigator.pushReplacementNamed(context, '/Home');
                            } else {
                              await mydb.update(query);
                              await firestore.collection("users").doc(currentUser!.uid)
                                  .update({
                                'firstname':_firstNameController.text,
                                'lastname':_lastNameController.text
                              });
                              Navigator.pushReplacementNamed(context, '/Home');

                            }

                            }
                          else{
                                String query = "UPDATE USERS SET firstname = '${_firstNameController.text}', lastname = '${_lastNameController.text}' WHERE ID = '${currentUser!.uid}'";


                              if (connectivityResult == ConnectivityResult.none) {
                              // No internet connection
                              _showAlertDialog('Error', 'No internet connection. Please try again later.');
                              } else {
                                await mydb.update(query);
                                await firestore.collection("users").doc(currentUser!.uid)
                                    .update({
                                  'firstname':_firstNameController.text,
                                  'lastname':_lastNameController.text
                                });
                                currentUser!.updatePassword(_passwordController.text);
                                Navigator.pushReplacementNamed(context, '/Home');

                              }

                          }

                        },
                        child: Text(
                          "Save",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ])

    );
  }
  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.grey),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }
}
