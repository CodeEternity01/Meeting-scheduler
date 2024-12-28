import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PendingRequestsScreen extends StatelessWidget {
  const PendingRequestsScreen({super.key});

  Future<void> _acceptRequest(String requestId, BuildContext context) async {
    try {
      // Update the request status to 'accepted' in Firestore
      await FirebaseFirestore.instance
          .collection('meetings')
          .doc(requestId)
          .update({'accepted': true});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request accepted successfully!")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to accept request: $e")),
        );
      }
    }
  }

  Future<void> _deleteRequest(String requestId, BuildContext context) async {
    try {
      // Delete the request document from Firestore
      await FirebaseFirestore.instance
          .collection('meetings')
          .doc(requestId)
          .delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request deleted successfully!")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete request: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      // Fetch requests where current user is the invitee and request is not accepted
      stream: FirebaseFirestore.instance
          .collection('meetings')
          .where('accepted',
              isEqualTo: false) // Only fetch non-accepted requests
          .where('inviteeId',
              isEqualTo:
                  currentUserId) // Only fetch requests where the current user is the invitee
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching requests'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No pending requests found'));
        }

        final requests = snapshot.data!.docs;

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final requestData = request.data() as Map<String, dynamic>;

            return Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User: ${requestData['name'] ?? 'Unknown'}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "Meeting Date: ${DateFormat('dd/MM/yyyy').format((requestData['date'] as Timestamp).toDate())}",
                    ),
                    Text("Meeting Start: ${requestData['startTime']}"),
                    Text("Meeting End: ${requestData['endTime']}"),
                    Text("Room No: ${requestData['roomId']}"),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _acceptRequest(request.id, context);
                          },
                          child: const Text('Accept'),
                        ),
                        const SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            _deleteRequest(request.id, context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
