import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

class YourMeetingsScreen extends StatelessWidget {
  const YourMeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('meetings')
          .where('accepted', isEqualTo: true)
          .where('inviterId',
              isEqualTo:
                  currentUserId) 
          .where('inviteeId',
              isEqualTo:
                  currentUserId) 
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching meetings'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No accepted meetings found'));
        }

        final meetings = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final meeting = meetings[index];
              final meetingData = meeting.data() as Map<String, dynamic>;

              final date = (meetingData['date'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd/MM/yyyy').format(date);

             
              final startTime =
                  (meetingData['startTime'] as Timestamp).toDate();
              final formattedStartTime =
                  DateFormat('hh:mm a').format(startTime);

              final endTime = (meetingData['endTime'] as Timestamp).toDate();
              final formattedEndTime = DateFormat('hh:mm a').format(endTime);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            meetingData['title'] ?? 'Meeting Title',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.meeting_room,
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text("Date: $formattedDate"),
                      Text("Time: $formattedStartTime - $formattedEndTime"),
                      Text("Room: ${meetingData['roomId']}"),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
