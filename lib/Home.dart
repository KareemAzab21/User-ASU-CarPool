import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Profile.dart';
import 'Book.dart';
import 'main.dart';
import 'History.dart';
import 'sqlflite.dart';


void main() => runApp(Home());

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASU CarPool Service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      routes: {
        '/Profile':(context)=>EditProfilePage(),
        '/Book':(context)=>Book(),
        '/Signout':(context)=>MyApp(),
        '/History':(context)=>RideHistoryPage(),
        '/Home':(context)=>Home(),
      },
    );
  }
}

class HomePage extends StatelessWidget {

  User? user = FirebaseAuth.instance.currentUser;
  LocalDatabase mydb = LocalDatabase();
  Future<String> getUserName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      String query = "SELECT * FROM USERS WHERE ID = '$uid'";
      var response = await mydb.read(query);

      if (response.isNotEmpty) {
        // Assuming 'response' is a list of maps
        Map<String, dynamic> userRow = response[0];
        return "${userRow['firstname'].toString()} ${userRow['lastname'].toString()}";
      }
    }
    return "User";
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
            Text('ASU CarPool Service'),
          ],
        ),
      ),
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Image
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0), // Adjust the radius here
                child: Image.asset(
                  'Assets/Home.png',
                  width: 400, // Adjust width and height to make the image larger
                  height: 400,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Find a Ride Button
            Padding(
              padding: EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.search, color: Colors.white),
                label: Text('Find a Ride'),
                onPressed: () => Navigator.pushReplacementNamed(context, '/Book'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  shadowColor: Colors.blueAccent,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Styled Manage Account Button
            Padding(
              padding: EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.person, color: Colors.white),
                label: Text('Manage Account'),
                onPressed: () => Navigator.pushReplacementNamed(context, '/Profile'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  shadowColor: Colors.blueAccent,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<String>(
              future: getUserName(), // the function to get user data
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  );
                } else {
                  return DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text(
                      'Welcome ${snapshot.data}', // display the user name
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Handle 'Home' navigation
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text('Find a Ride'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/Book');

              },
            ),
            ListTile(
              leading: Icon(Icons.watch_later),
              title: Text('Your Rides'),
              onTap: () {
                Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/History');
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Manage Account'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context,'/Profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sign Out'),
              onTap: () async{
                await FirebaseAuth.instance.signOut();
                // Handle 'Sign Out' action
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacementNamed(context, '/Signout');
                // Implement sign out functionality
              },
            ),
            // ... Add other ListTile widgets if needed
          ],
        ),
      ),
    );
  }
}
