import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestMeetingScreen extends StatefulWidget {
  const RequestMeetingScreen({super.key});

  @override
  _RequestMeetingScreenState createState() => _RequestMeetingScreenState();
}

class _RequestMeetingScreenState extends State<RequestMeetingScreen> {
  String? selectedInviteeId;
  String? selectedRoom;
  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  List<Map<String, dynamic>> availableUsers = [];
  final List<String> availableRooms = ["Room A", "Room B", "Room C", "Room D"];

  @override
  void initState() {
    super.initState();
    _fetchAvailableUsers();
  }

  Future<void> _fetchAvailableUsers() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      setState(() {
        availableUsers = snapshot.docs
            .where((doc) => doc.id != currentUserId) 
            .map((doc) {
          return {
            "uid": doc.id,
            "name": doc.data().containsKey('name') ? doc['name'] : 'Unknown',
          };
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch users: $e')),
        );
      }
    }
  }

  Future<String> getCurrentUserName() async {
    try {
   
      String userId = FirebaseAuth.instance.currentUser!.uid;

    
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc['name'] ??
            'Unknown'; 
      } else {
        return 'Unknown'; 
      }
    } catch (e) {
      return 'Error';
    }
  }


  String _formatTime(TimeOfDay time) {
    final DateFormat formatter = DateFormat('hh:mm a');
    final timeString = DateTime(0, 0, 0, time.hour, time.minute);
    return formatter.format(timeString);
  }

  void _submitMeetingRequest() async {
    String inviterId =
        FirebaseAuth.instance.currentUser!.uid; 
    String name = await getCurrentUserName();
  
    String formattedStartTime = _formatTime(selectedStartTime!);
    String formattedEndTime = _formatTime(selectedEndTime!);

    try {
      await FirebaseFirestore.instance.collection('meetings').add({
        'name': name,
        'inviterId': inviterId,
        'inviteeId': selectedInviteeId,
        'roomId': selectedRoom,
        'date': selectedDate, 
        'startTime': formattedStartTime, 
        'endTime': formattedEndTime, 
        'accepted': false,
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meeting Request Submitted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit meeting request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          DropdownButton<String>(
            hint: const Text("Select an Invitee"),
            value: selectedInviteeId,
            onChanged: (String? newValue) {
              setState(() {
                selectedInviteeId = newValue;
              });
            },
            items: availableUsers
                .map<DropdownMenuItem<String>>((Map<String, dynamic> user) {
              return DropdownMenuItem<String>(
                value: user['uid'],
                child: Text(user['name']),
              );
            }).toList(),
          ),
          ListTile(
            title: Text(selectedDate == null
                ? "Select Date"
                : "Date: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}"),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2023),
                lastDate: DateTime(2025),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
          ),
          ListTile(
            title: Text(selectedStartTime == null
                ? "Select Start Time"
                : "Start Time: ${selectedStartTime!.format(context)}"),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                setState(() {
                  selectedStartTime = picked;
                });
              }
            },
          ),
          ListTile(
            title: Text(selectedEndTime == null
                ? "Select End Time"
                : "End Time: ${selectedEndTime!.format(context)}"),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                setState(() {
                  selectedEndTime = picked;
                });
              }
            },
          ),
          DropdownButton<String>(
            hint: const Text("Select a Room"),
            value: selectedRoom,
            onChanged: (String? newValue) {
              setState(() {
                selectedRoom = newValue;
              });
            },
            items: availableRooms.map<DropdownMenuItem<String>>((String room) {
              return DropdownMenuItem<String>(
                value: room,
                child: Text(room),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedInviteeId != null &&
                  selectedDate != null &&
                  selectedStartTime != null &&
                  selectedEndTime != null &&
                  selectedRoom != null) {
                _submitMeetingRequest();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
              }
            },
            child: const Text("Request Meeting"),
          ),
        ],
      ),
    );
  }
}
