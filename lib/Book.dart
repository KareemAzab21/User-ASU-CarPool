import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Home.dart';
import 'Profile.dart';
import 'main.dart';

import 'History.dart';
void main() => runApp(Book());

class Book extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Booking',
      home: RideBookingPage(),
      routes: {
        '/Home':(context)=>Home(),
        '/Profile':(context)=>EditProfilePage(),
        '/Signout':(context)=>MyApp(),
        '/History':(context)=>RideHistoryPage(),

      },
    );
  }
}

class RideBookingPage extends StatelessWidget {
  String name='';

  Stream<List<Ride>> rideStream() {
    return FirebaseFirestore.instance
        .collection('rides')
        .snapshots()
        .map((QuerySnapshot query) {
      List<Ride> rideList = [];
      for (var doc in query.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('Rides')) {
          List<dynamic> ridesData = data['Rides'];
          for (var rideData in ridesData) {
            // Ensure that rideData is a Map<String, dynamic>
            if (rideData is Map<String, dynamic>) {
              // Check if the Users is actually a List
              var users = rideData['Users'];
              if (users is! List || !users.contains(FirebaseAuth.instance.currentUser?.uid)) {
                rideList.add(Ride(
                  fromLocation: rideData['from'],
                  toLocation: rideData['to'],
                  time: rideData['time'],
                  date: rideData['date'],
                  stops: List<String>.from(rideData['stops']),
                  driver: rideData['driver'],
                  price: rideData['price'],
                  id: rideData['id'],
                  // Assuming you have a Users field in your Ride model
                  Users: users is List ? List<String>.from(users) : [],
                ));
              }
            }
          }
        }
      }
      return rideList;
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
        name="${userData['firstname']} ${userData['lastname']}";
        return "${userData['firstname']} ${userData['lastname']}";
      }
    }
    return "User";
  }
  Future<String> getDriverName(String uid) async {
    var usersCollection = FirebaseFirestore.instance.collection('drivers');
    var docSnapshot = await usersCollection.doc(uid).get();

    if (docSnapshot.exists) {
      Map<String, dynamic> userRow = docSnapshot.data()!;
      return "${userRow['firstname']} ${userRow['lastname']}";
    } else {
      return "Unknown User"; // Return a default string if the user does not exist.
    }
  }

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.credit_card),
                  title: Text('Visa'),
                  onTap: () {
                    Navigator.pop(context); // Close the modal bottom sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ride has been Requested! Track the ride status in YOUR RIDE'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    Future.delayed(Duration(seconds: 3), () {
                      Navigator.pushReplacementNamed(context, '/Home');
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.money),
                  title: Text('Cash'),
                  onTap: () {
                    Navigator.pop(context); // Close the modal bottom sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ride has been Requested! Track the ride status in YOUR RIDE'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    Future.delayed(Duration(seconds: 3), () {
                      Navigator.pushReplacementNamed(context, '/Home');
                    });
                  },
                ),
              ],
            ),
          );
        }
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
            Text('Rides Available'),
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
                Navigator.pushNamed(context, '/Home'); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text('Find a Ride'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.watch_later),
              title: Text('Your Rides'),
              onTap: () {

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
                Navigator.pushNamed(context,'/Profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sign Out'),
              onTap: () {
                // Handle 'Sign Out' action
                Navigator.pop(context);//Close the drawer
                Navigator.pushReplacementNamed(context, '/Signout');
                // Implement sign out functionality
              },
            ),
            // ... Add other ListTile widgets if needed
          ],
        ),
      ),
      body: StreamBuilder<List<Ride>>(
        stream: rideStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No rides available.'));
          } else {
            List<Ride> rides = snapshot.data!;
            return ListView.builder(
              itemCount: rides.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text('${rides[index].fromLocation} to ${rides[index].toLocation}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${rides[index].date} - Time: ${rides[index].time}'),
// Display stops
                              Text(
                                'Stops: ${rides[index].stops.join(", ")}',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.event_seat),
                            onPressed: () async{
                              String dateTimeString = rides[index].date; // Example date-time from screenshot
                              String timeString = rides[index].time; // Example time in 12-hour format

// Extract the date part from the dateTimeString
                              String dateString = dateTimeString.split("T")[0]; // "2023-12-13"

// Convert 12-hour format time to 24-hour format
                              int hour = int.parse(timeString.split(":")[0]);
                              int minute = int.parse(timeString.split(":")[1].split(" ")[0]);
                              String amPm = timeString.split(" ")[1];
                              if (amPm == "PM" && hour != 12) {
                                hour = hour + 12;
                              } else if (amPm == "AM" && hour == 12) {
                                hour = 0;
                              }

// Combine date and time into a single DateTime object
                              DateTime rideDateTime = DateTime(
                                  int.parse(dateString.split("-")[0]), // Year
                                  int.parse(dateString.split("-")[1]), // Month
                                  int.parse(dateString.split("-")[2]), // Day
                                  hour,
                                  minute
                              );

                              print(rideDateTime);

// Determine cutoff DateTime
                              DateTime cutoff=DateTime.now();
                              if (rideDateTime.hour == 7 && rideDateTime.minute == 30) { // Morning ride
                                cutoff = DateTime(rideDateTime.year, rideDateTime.month, rideDateTime.day, 22, 0).subtract(Duration(days: 1));
                              } else if (rideDateTime.hour == 17 && rideDateTime.minute == 30) { // Evening ride
                                cutoff = DateTime(rideDateTime.year, rideDateTime.month, rideDateTime.day, 13, 0);
                              } else {
                                // Handle other cases or set a default cutoff
                              }

                              // Check if current time is after the cutoff
                              if (DateTime.now().isAfter(cutoff)) {
                                // Show message that the cutoff time has passed
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Cutoff Time Passed"),
                                      content: Text("The cutoff time for this ride has passed."),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text("ByPass"),
                                          onPressed: () async{

                                            String driver_name=await getDriverName(rides[index].driver);
                                            User? currentUser = FirebaseAuth.instance.currentUser;
                                            String id=currentUser!.uid;
                                            DocumentReference requestDoc = FirebaseFirestore.instance.collection('requests').doc(rides[index].driver);
                                            DocumentReference historyDoc = FirebaseFirestore.instance.collection('history').doc(id);

                                            Map<String, dynamic> updateData = {
                                              'fromLocation': rides[index].fromLocation,
                                              'toLocation': rides[index].toLocation,
                                              'date': rides[index].date, // Firestore can handle DateTime objects directly
                                              'driver': driver_name,
                                              'time':rides[index].time,
                                              'price': rides[index].price,
                                              'status': 'pending',
                                              'user':id,
                                              'username':name,
                                              'id':rides[index].id,
                                            };

                                            await requestDoc
                                                .update({
                                              'Requests': FieldValue.arrayUnion([updateData]) // Appends the new ride data to the ridesList array
                                            });
                                            await historyDoc
                                                .update({
                                              'History': FieldValue.arrayUnion([updateData]) // Appends the new ride data to the ridesList array
                                            });
                                            Navigator.of(context).pop();



                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                                _showPaymentOptions(context);
                                return;
                              }


                              String driver_name=await getDriverName(rides[index].driver);
                              User? currentUser = FirebaseAuth.instance.currentUser;
                              String id=currentUser!.uid;
                              DocumentReference requestDoc = FirebaseFirestore.instance.collection('requests').doc(rides[index].driver);
                              DocumentReference historyDoc = FirebaseFirestore.instance.collection('history').doc(id);

                              Map<String, dynamic> updateData = {
                                'fromLocation': rides[index].fromLocation,
                                'toLocation': rides[index].toLocation,
                                'date': rides[index].date, // Firestore can handle DateTime objects directly
                                'driver': driver_name,
                                'time':rides[index].time,
                                'price': rides[index].price,
                                'status': 'pending',
                                'user':id,
                                'username':name,
                                'id':rides[index].id,
                              };

                              await requestDoc
                                  .update({
                                'Requests': FieldValue.arrayUnion([updateData]) // Appends the new ride data to the ridesList array
                              });
                              await historyDoc
                                  .update({
                                'History': FieldValue.arrayUnion([updateData]) // Appends the new ride data to the ridesList array
                              });
                              _showPaymentOptions(context);
                            },
                          ),
                        ),
                      ],
                    ),
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

class Ride {
  String fromLocation;
  String toLocation;
  String time;
  String date;
  List<String> stops; // List of stops
  String price;
  String driver;
  String id;
  List<String> Users;

  Ride({
    required this.fromLocation,
    required this.toLocation,
    required this.time,
    required this.date,
    required this.stops,
    required this.price,
    required this.driver,
    required this.id,
    required this.Users,
  });
}


// Card(

// ),
