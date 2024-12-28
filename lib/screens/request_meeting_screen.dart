import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestMeetingScreen extends StatefulWidget {
  const RequestMeetingScreen({super.key});

  @override
  _RequestMeetingScreenState createState() => _RequestMeetingScreenState();
}

class _RequestMeetingScreenState extends State<RequestMeetingScreen> {
  // Example data for users and available rooms
  final List<String> availableUsers = [
    "User 1",
    "User 2",
    "User 3",
    "User 4",
  ];

  final List<String> availableRooms = [
    "Room A",
    "Room B",
    "Room C",
    "Room D",
  ];

  String? selectedUser;
  String? selectedRoom;
  DateTime? selectedDateTime;
  int? selectedDuration; // Duration in minutes

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Select User
          DropdownButton<String>(
            hint: Text("Select a User"),
            value: selectedUser,
            onChanged: (String? newValue) {
              setState(() {
                selectedUser = newValue;
              });
            },
            items: availableUsers.map<DropdownMenuItem<String>>((String user) {
              return DropdownMenuItem<String>(
                value: user,
                child: Text(user),
              );
            }).toList(),
          ),

          // Select Date and Time
          ListTile(
            title: Text(selectedDateTime == null
                ? "Select Date and Time"
                : "Meeting Date & Time: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime!)}"),
            trailing: Icon(Icons.calendar_today),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2023),
                lastDate: DateTime(2025),
              );
              if (picked != null) {
                final TimeOfDay? timePicked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (timePicked != null) {
                  setState(() {
                    selectedDateTime = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      timePicked.hour,
                      timePicked.minute,
                    );
                  });
                }
              }
            },
          ),

          // Select Duration
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Duration (in minutes)',
              hintText: 'Enter the meeting duration',
            ),
            onChanged: (value) {
              setState(() {
                selectedDuration = int.tryParse(value);
              });
            },
          ),

          // Select Room
          DropdownButton<String>(
            hint: Text("Select a Room"),
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

          // Submit Button
          ElevatedButton(
            onPressed: () async {
              if (selectedUser != null && selectedDateTime != null && selectedRoom != null && selectedDuration != null) {
                bool isRoomAvailable = await _checkRoomAvailability();
                if (isRoomAvailable) {
                  _submitMeetingRequest();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected room is not available at the chosen time')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill in all fields')),
                );
              }
            },
            child: Text("Request Meeting"),
          ),
        ],
      ),
    );
  }

  // Function to check if the selected room is available at the selected time
  Future<bool> _checkRoomAvailability() async {
    if (selectedDateTime == null || selectedRoom == null || selectedDuration == null) return false;

    // Create the end time based on the duration
    DateTime endTime = selectedDateTime!.add(Duration(minutes: selectedDuration!));

    // Query Firestore to check if the room is already booked during the time range
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('meetings')
        .where('room', isEqualTo: selectedRoom)
        .where('startTime', isGreaterThan: selectedDateTime)
        .where('endTime', isLessThan: endTime)
        .get();

    // If there are existing meetings during this time, the room is not available
    return snapshot.docs.isEmpty;
  }

  // Function to handle meeting request submission
  void _submitMeetingRequest() async {
    if (selectedUser != null && selectedDateTime != null && selectedRoom != null && selectedDuration != null) {
      try {
        // Save meeting details in Firestore
        await FirebaseFirestore.instance.collection('meetings').add({
          'user': selectedUser,
          'startTime': selectedDateTime,
          'endTime': selectedDateTime!.add(Duration(minutes: selectedDuration!)),
          'room': selectedRoom,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meeting Request Submitted!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit meeting request: $e')),
        );
      }
    }
  }
}
