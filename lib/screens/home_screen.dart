import 'package:assignment/screens/pending_request_screen.dart';
import 'package:assignment/screens/profile_screen.dart';
import 'package:assignment/screens/request_meeting_screen.dart';
import 'package:assignment/screens/your_meeting_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> _screens = [
    const YourMeetingsScreen(),
    const RequestMeetingScreen(),
    const PendingRequestsScreen(),
    const ProfileScreen()
  ];

  final List<String> title = [
    'Scheduled Meetings',
    'Request New Meeting',
    'Pending Meeting Request',
    'Profile',
  ];

  void _onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title[currentIndex]),
      ),
      body: _screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'New Meeting',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending),
            label: 'Pending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.room),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
