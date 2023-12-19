import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Profile.dart';
import 'Book.dart';
import 'main.dart';

class RideHistoryPage extends StatelessWidget {

  Stream<List<RideHistory>> rideHistoryStream() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.value([]); // Return an empty stream if the user is not logged in
    }

    return FirebaseFirestore.instance
        .collection('history')
        .doc(currentUser.uid)
        .snapshots()
        .map((documentSnapshot) {
      if (documentSnapshot.exists) {
        var historyData = documentSnapshot.data();
        var history = historyData?['History'];
        if (history is List) {
          // Cast each element in the list to Map<String, dynamic>
          List<Map<String, dynamic>> historyList = history.map((item) {
            return Map<String, dynamic>.from(item);
          }).toList();
          // Now you can map over the List of Maps
          return historyList.map<RideHistory>((historyMap) {
            return RideHistory(
              fromLocation: historyMap['fromLocation'],
              toLocation: historyMap['toLocation'],
              date: historyMap['date'],
              time: historyMap['time'],
              driver: historyMap['driver'],
              price: historyMap['price'],
              status: historyMap['status'],
              username: historyMap['username'],
              id: historyMap['id'],
            );
          }).toList();
        }
      }
      return []; // Return an empty list if the document or 'History' key does not exist
    });
  }





  Future<String> getUserName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return "${userData['firstname']} ${userData['lastname']}";
      }
    }
    return "User";
  }


  void _showRideInfoDialog(BuildContext context, RideHistory ride) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ride Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            // To make the dialog adapt to content size
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Driver: ${ride.driver}"),
              // Replace with actual driver's name
              Text("From: ${ride.fromLocation}"),
              Text("To: ${ride.toLocation}"),
              Text("Date: ${ride.date}"),
              Text("Time: ${ride.time}"),
              Text("Price: \$${ride.price}"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
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
            Text('Your Rides'),
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
            Navigator.pushReplacementNamed(context, '/Home');
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
      body: StreamBuilder<List<RideHistory>>(
        stream: rideHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No ride history found.'));
          } else {
            List<RideHistory> rideHistoryList = snapshot.data!;
            return ListView.builder(
              itemCount: rideHistoryList.length,
              itemBuilder: (context, index) {
                var ride = rideHistoryList[index];
                return Card(
                  margin: EdgeInsets.all(10.0),
                  elevation: 5,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  child: ListTile(
                    leading: Icon(Icons.directions_car, color: Colors.blue),
                    title: Text(
                      '${ride.fromLocation} to ${ride.toLocation}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.attach_money, size: 16,
                                color: Colors.green),
                            Text('\$${ride.price}',
                                style: TextStyle(color: Colors.green)),
                          ],
                        ),
                        Text('Status: ${ride.status}',
                            style: TextStyle(color: Colors.blue)),
                        // Display status
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.info_outline, color: Colors.blue),
                      onPressed: () {
                        _showRideInfoDialog(context, ride);
                      },
                    ),
                    onTap: () {
                      // Implement navigation or another action when tapped
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class RideHistory {
  String fromLocation;
  String toLocation;
  String date;
  String time;
  String driver;
  String price;
  String status; // Add status field
  String username;
  String id;

  RideHistory({
    required this.fromLocation,
    required this.toLocation,
    required this.date,
    required this.time,
    required this.driver,
    required this.price,
    required this.status, // Initialize status
    required this.username,
    required this.id,

  });
}
