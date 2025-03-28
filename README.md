🎓 University Management App (Flutter & Firebase)

📌 Overview

This project consists of a Flutter-based mobile application designed for university use, with two separate applications:

Admin App: Allows university administrators to manage categories and events.

Student App: Enables students to subscribe to different categories (e.g., clubs, courses) and receive notifications whenever an event is created.

The app is built using Flutter for cross-platform development and Firebase for backend services.

✨ Features

🏫 Admin App

🔹 Manage Categories: Create, update, and delete different categories (e.g., Clubs, Courses).

🔹 Manage Events: Add, edit, and delete university events.

🔹 Push Notifications: Notify subscribed students when new events are added.

🎓 Student App

🔹 Browse Categories: View available clubs, courses, and other categories.

🔹 Subscribe to Categories: Stay updated by subscribing to preferred categories.

🔹 Receive Notifications: Get real-time alerts when events are announced.

🛠 Technologies Used

📱 Flutter: Cross-platform mobile app development.

🔥 Firebase:

Firestore: Database for storing categories and events.

Firebase Authentication: Secure login for admins and students.

Firebase Cloud Messaging (FCM): Sends push notifications.

🔧 Installation

Clone the repository:

git clone <repository-url>
cd <repository-name>

Install dependencies:

flutter pub get

Configure Firebase:

Set up Firebase for both Android and iOS.

Add google-services.json (Android) and GoogleService-Info.plist (iOS) in respective directories.

Run the application:

flutter run

🚀 Usage

Admins can log in and manage categories and events.

Students can explore categories, subscribe, and receive event notifications.

🔮 Future Enhancements

🛠 Implement role-based access control.

📅 Add event calendar for better scheduling.

💬 Integrate chat feature for students and admins.

