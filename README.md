
# Meeting Scheduler Application

## Overview
This is a Flutter-based Meeting Scheduler application that allows users to:

- Request meetings with other users.
- Specify details like invitee, date, time, duration, and conference room.
- View and manage meeting requests.
- Accept or decline meeting invitations.
- Automatically book conference rooms upon acceptance of a request.

The application uses Firebase Authentication for user management and Firestore for real-time storage of meeting details and room availability.

## Features

### Authentication
- Users log in or sign up using Firebase Authentication.
- Each user is authenticated before performing any operations.

### Request Meeting
- Users can send meeting requests by specifying:
  - Invitee (another user).
  - Date and time of the meeting.
  - Duration of the meeting.
  - Conference room (selected from available options).

### View Scheduled Meetings
- Users can view all scheduled meetings in a dedicated "Meetings" page.

### Manage Requests
- Users can:
  - View incoming meeting requests from other users.
  - Accept or decline a meeting request.
  - Automatically book a conference room upon accepting a request.

### Room Availability
- Real-time conflict checking for room bookings.
- Users are notified if a selected room is unavailable at the requested time.

## Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase Firestore
- **Authentication:** Firebase Authentication
- **Notifications (optional):** Firebase Cloud Messaging

## Screens

### Login/Sign-Up Screen
- Allows users to authenticate via Firebase.

### Profile Screen
- Displays user details.
- Includes navigation to meeting request and schedule pages.

### Request Meeting Screen
- Allows users to send meeting requests.
- Includes dropdowns for selecting invitees and rooms, and date-time pickers.

### Meeting Requests Screen
- Displays incoming meeting requests.
- Options to accept or decline requests.

### Scheduled Meetings Screen
- Shows all confirmed meetings for the logged-in user.

## Database Structure

### Firestore Collections

#### Users
- `uid`: Unique identifier.
- `name`: User's name.
- `email`: User's email.
- `profilePicture`: URL of the user's profile picture (optional).

#### Meetings
- `meetingId`: Unique identifier.
- `createdBy`: User ID of the meeting requester.
- `invitee`: User ID of the invited user.
- `startTime`: Meeting start time.
- `endTime`: Meeting end time.
- `room`: Selected conference room.
- `status`: Pending, Accepted, or Declined.

#### Rooms
- `roomId`: Room name or ID.
- `availability`: Array of booked time slots.

## Setup Instructions

### Clone the repository
```bash
git clone https://github.com/your-repo/meeting-scheduler.git
cd meeting-scheduler
```

### Install dependencies
```bash
flutter pub get
```

### Set up Firebase
1. Create a Firebase project.
2. Enable Authentication with the desired sign-in methods.
3. Enable Cloud Firestore for database operations.
4. Add your app's `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) files to the appropriate directories.

### Run the application
```bash
flutter run
```

## Future Enhancements
- Push notifications using Firebase Cloud Messaging for meeting requests and updates.
- Calendar integration to sync meetings with Google/Apple calendars.
- Enhanced room booking conflict resolution with detailed error messages.

