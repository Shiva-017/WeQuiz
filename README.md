# WeQuiz App

**WeQuiz** is a location-based quiz application designed to offer users an engaging and interactive trivia experience based on their geographic location. It allows players to explore interesting facts about their surroundings while enjoying a series of quizzes with varying difficulty levels.

## Features

- **Location-Based Quizzes**: The app offers quizzes tailored to the user’s current location, providing trivia related to nearby places and landmarks.
- **User Authentication**: Sign-in and sign-up functionalities powered by Firebase Authentication, allowing secure login via email and password.
- **Multiple Quiz Categories**: Users can choose quizzes from various categories like general knowledge, history, geography, and more.
- **Real-Time Leaderboard**: Displays users' scores and ranks, enabling friendly competition.
- **Interactive UI**: A clean and modern interface designed using Flutter for an engaging user experience.
- **Location Services**: Uses the Google Maps API to determine the user's location and provide relevant location-based quizzes.
- **Multiple Difficulty Levels**: Offers quizzes with multiple difficulty levels, catering to both beginners and trivia enthusiasts.
- **Quiz Results & Analytics**: After completing a quiz, users get immediate feedback on their performance, along with detailed analytics.

## Technologies Used

- **Flutter**: Flutter is used to build the cross-platform mobile app, ensuring a smooth and consistent experience across Android and iOS.
- **Firebase Authentication**: Firebase Authentication is used to manage user sign-ins and sign-ups securely with email/password authentication.
- **Firestore**: Firebase Firestore is used to store user data, quiz questions, answers, and user scores in real-time.
- **Google Maps API**: Google Maps API is used to detect the user’s location, ensuring that quizzes are geographically relevant.
- **Provider**: State management is handled with the Provider package to manage app state efficiently.
- **Dart**: The app is written in Dart, the programming language for Flutter, ensuring high performance and ease of development.

## Future Work

- **Enhanced Location-Based Quizzes**: Expand the location-based feature to allow quizzes on various other criteria such as landmarks, historical sites, etc.
- **Push Notifications**: Introduce push notifications to alert users about new quizzes, leaderboards, or daily challenges.
- **Multiplayer Support**: Enable multiplayer functionality where users can challenge their friends or compete with others globally.
- **Advanced Analytics**: Add deeper analytics and insights on user performance and quiz trends.
- **Customizable Quizzes**: Let users create and share their own quizzes with others based on location, categories, or interests.
- **Enhanced UI/UX**: Continuous improvements to the UI, ensuring it remains user-friendly, attractive, and interactive.

## How to Set Up & Run the Project

### Prerequisites

Before running the app locally, ensure the following tools and services are set up:

- **Flutter SDK**: Download and install the Flutter SDK by following the [installation guide](https://flutter.dev/docs/get-started/install).
- **Android Studio/VS Code**: Set up your preferred IDE for Flutter development. Android Studio is recommended for Android builds.
- **Firebase Project**: Create a Firebase project on the [Firebase Console](https://console.firebase.google.com/).
- **Google Maps API Key**: Create a project on the [Google Cloud Console](https://console.cloud.google.com/) and enable the Google Maps SDK for both Android and iOS to use location-based features.

### Setup Steps

1. **Clone the Repository**

   Clone the repository to your local machine:
   ```bash
   git clone https://github.com/yourusername/WeQuiz.git
   cd [project]
   flutter pub get 
   flutter run
   flutter build apk --release 
