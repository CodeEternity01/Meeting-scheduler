import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = "";
  String email = "";
  String userId = "";
  String phoneNumber = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  void _fetchUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Get the UID of the currently logged-in user
      String uid = user.uid;

      try {
        // Fetch the user data from Firestore
        DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

        if (doc.exists) {
          setState(() {
            username = doc['name'] ?? 'No name';
            email = doc['email'] ?? 'No email';
            phoneNumber = doc['phone'] ?? 'No phone number';
            userId = uid;
            isLoading = false;  // Set loading to false after data is fetched
          });
        } else {
          setState(() {
            isLoading = false;  // Set loading to false if document doesn't exist
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User data not found')),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;  // Set loading to false on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())  // Show loader while fetching data
          : ListView(
              children: [
                // User Information
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: Text("Username: $username"),
                  ),
                ),
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: const Icon(Icons.email, color: Colors.blue),
                    title: Text("Email: $email"),
                  ),
                ),
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: const Icon(Icons.badge, color: Colors.blue),
                    title: Text("User ID: $userId"),
                  ),
                ),
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: const Icon(Icons.phone, color: Colors.blue),
                    title: Text("Phone: $phoneNumber"),
                  ),
                ),
              ],
            ),
    );
  }
}
