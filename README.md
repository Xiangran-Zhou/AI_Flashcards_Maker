# AI Flashcards Maker

## Overview
**AI Flashcards Maker** is a mobile iOS application that allows users to create and manage flashcards with the assistance of AI. The project utilizes **Firebase** for authentication, **Firestore** for database management, and **SwiftUI** for building the user interface. The app processes uploaded PDF files, extracts text, and uses AI to generate flashcards.

---

## Features
- **AI Flashcard Generation**: Upload PDF files and generate flashcards automatically using OpenAI's GPT.
- **User Authentication**: Secure login and registration using Firebase Authentication.
- **Cloud Storage**: Save user data and flashcards using Firebase Firestore.

---

## Screenshot of App
![App Demo](https://github.com/user-attachments/assets/fc803584-dd09-408b-8298-ad5208ffa8ee)

---


## Prerequisites
Before setting up the project, ensure you have the following:
- **Xcode**: Version 14.0 or later.
- **Swift Package Manager (SPM)**: Installed by default with Xcode.
- **Firebase Account**: Required for backend services.
- **API Keys**: Required for OpenAI API integration.

---

## Setup Instructions

### 1. Clone the Repository
Clone the project repository to your local machine:
   ```xml
   git clone https://github.com/Xiangran-Zhou/AI_Flashcards_Maker.git
   cd AI_Flashcards_Maker
   ```

---
### 2. Configure Firebase
1. Sign in to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new Firebase project or use an existing one.
3. Add an iOS app to the Firebase project:
   - Provide your app's **Bundle Identifier** (must match your Xcode project).
4. Download the `GoogleService-Info.plist` file.
5. Place the `GoogleService-Info.plist` file into the `AI_Flashcards_Maker` project directory.
### 3. Add API Keys
1. Create a new file named `APIKeys.plist` in the `AI_Flashcards_Maker` project directory.
2. Add your OpenAI API key in the following format:
    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <plist version="1.0">
    <dict>
        <key>OpenAIKey</key>
        <string>your_openai_api_key</string>
    </dict>
    </plist>
    ```

### 4. Open the Project
1. Open `AI_Flashcards_Maker.xcodeproj` in Xcode.
2. Configure the **Signing & Capabilities** section:
   - Select your development team.
   - Ensure the bundle identifier matches your Firebase setup.

### 5. Resolve Dependencies
The project uses **Swift Package Manager** to manage dependencies:
1. Open the project in Xcode.
2. Navigate to `File > Add Packages` if you need to add or update any dependencies.
3. Dependencies are automatically resolved when the project is built. Wait for Xcode to resolve and download all dependencies (you'll see a progress indicator in the top bar if it's fetching).
No additional commands are needed in the terminal for dependencies.

### 6. Build and Run the Project
1. Connect a physical device or select a simulator in Xcode.
2. Build the project (`Cmd + B`) to ensure there are no errors.
3. Run the app (`Cmd + R`).

---

## Dependencies
The project uses the following Swift packages:
- **Firebase**: Authentication, Firestore, and Storage.
- **Swift Package Manager (SPM)**: Built-in dependency manager for resolving all packages.

---

## Troubleshooting

### API Key Issues
- Ensure your `APIKeys.plist` file is correctly configured and placed in the project root.

### Firebase Errors
- Check that the `GoogleService-Info.plist` file is properly linked to the Firebase project.

### Build Errors
- Clean the project and rebuild it:
    ```bash
    Cmd + Shift + K
    ```
- Then rebuild using `Cmd + B`.

---

## License
This project is licensed under the **MIT License**. See the `LICENSE` file for details.
