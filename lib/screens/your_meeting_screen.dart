import 'package:flutter/material.dart';

class YourMeetingsScreen extends StatelessWidget {
  const YourMeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return const Card(
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
                        "Project Update",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.meeting_room,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text("Date: 2024-12-30"),
                  Text("Time: 2:00 PM"),
                  Text("Duration: 45 minutes"),
                  Text("Room: 303"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
