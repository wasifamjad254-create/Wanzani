# Wanzani 🌐

**Wanzani** is a social media application built with Flutter, designed to bring people together through posts, stories, live streaming, messaging, and content discovery.

The project focuses on providing a modern user interface, a smooth mobile experience, and support for multiple languages.

## ✨ Features

- **User Authentication** — Login, account registration, and password recovery.
- **Home Feed** — Explore posts and discover content from other users.
- **Stories** — View user stories and visual updates.
- **Live Streaming** — Explore live content and streaming channels.
- **Messaging** — Chat interface for user conversations.
- **Comments** — Interact with posts through comments.
- **Search** — Discover content and explore users.
- **Notifications** — View likes, comments, follows, and other activity.
- **Marketplace** — Explore content through the Market section.
- **User Profile** — View and manage personal information.
- **Settings** — Access app preferences and account settings.
- **Multilingual Support** — English and French localization.
- **Payment Interface** — Payment method and subscription-related screens.

*Note: Features requiring backend services or third-party integrations may need additional configuration.*

## 🛠️ Technologies Used

- **Flutter** — Cross-platform application development.
- **Dart** — Application programming language.
- **Firebase Authentication** — User authentication.
- **Cloud Firestore** — Cloud database integration.
- **Firebase Core** — Firebase initialization.
- **Easy Localization** — Multilingual support.
- **Shared Preferences** — Local preference storage.
- **Git and GitHub** — Version control and project hosting.

## 📱 Screens and Modules

The project includes screens and modules for:

- Onboarding
- Login and registration
- Home feed
- Live streaming and channel exploration
- Search and notifications
- Stories and comments
- Chat
- Marketplace
- Personal information and settings
- Payment methods and subscription details
- Verification process

## 🚀 Getting Started

Follow these steps to run Wanzani locally.

### Prerequisites

Install the following tools:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/)
- Git

### 1. Clone the repository

```bash
git clone https://github.com/wasifamjad254-create/Wanzani.git
```

### 2. Open the project

```bash
cd Wanzani
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

If your local version uses Firebase:

1. Create or select a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Register your Android or other supported application.
3. Configure Firebase using the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup).
4. Enable the Firebase services required by the application.
5. Verify that your Firebase configuration matches your local development environment.

Do not commit service-account private keys, payment secret keys, or other confidential credentials to GitHub.

### 5. Run the application

Connect an emulator or a supported device, then run:

```bash
flutter run
```

## 🌍 Localization

Wanzani uses Easy Localization to support multiple languages.

Translation files are stored in:

```text
assets/
└── languages/
    ├── en.json
    └── fr.json
```

Add or update translation keys in the relevant language files when introducing new localized text.

## 📁 Project Structure

```text
Wanzani/
├── android/                 # Android platform files
├── assets/
│   ├── languages/           # Translation files
│   └──                     # Images and other assets
├── ios/                     # iOS platform files
├── lib/
│   ├── api/                 # API and authentication-related code
│   ├── screens/             # Application screens
│   ├── widgets/             # Reusable UI components
│   ├── main.dart            # Application entry point
│   └── firebase_options.dart
├── test/                    # Tests
├── pubspec.yaml             # Dependencies and assets
└── README.md
```

## 🔐 Security

- Never commit Stripe secret keys or other private credentials.
- Perform sensitive payment operations on a secure backend.
- Configure Firebase Authentication and Firestore security rules appropriately.
- Keep development secrets outside the source code and version control.

## 🗺️ Future Improvements

- Complete and test backend integrations.
- Improve real-time messaging and live streaming.
- Add more languages.
- Expand user profile and social interaction features.
- Improve automated testing and application performance.
- Strengthen payment integration and security.

## 👨‍💻 Author

**Wasif Amjad**

GitHub: [@wasifamjad254-create](https://github.com/wasifamjad254-create)

## 📄 License

No license has been specified yet. Please add a license before allowing others to reuse, modify, or distribute this project.

---

If you find this project interesting, feel free to explore the repository and follow its development.
