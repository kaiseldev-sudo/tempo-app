# Firebase Setup Instructions for Tempo App

## Problem
The app shows "configuration not found" because the Android app `com.tempo.tempo` 
is not registered in your Firebase project yet.

## Solution: Add Android App to Firebase Console

### Step 1: Go to Firebase Console
1. Open: https://console.firebase.google.com/
2. Select project: **boardexam-checker**

### Step 2: Add Android App
1. Click the **Settings gear icon** → **Project settings**
2. Scroll down to "Your apps"
3. Click **"Add app"** → Select **Android icon**
4. Fill in the details:
   - **Android package name**: `com.tempo.tempo`
   - **App nickname** (optional): Tempo
   - **Debug signing certificate SHA-1** (optional): Leave blank for now
5. Click **"Register app"**

### Step 3: Download google-services.json
1. Download the `google-services.json` file
2. Replace the file at: `/Users/jaysonreales/Desktop/projects/tempo/android/app/google-services.json`

### Step 4: Enable Authentication
1. In Firebase Console, go to **Authentication** (left sidebar)
2. Click **"Get started"** if not already enabled
3. Go to **"Sign-in method"** tab
4. Click on **"Email/Password"**
5. **Enable** the first toggle (Email/Password)
6. Click **"Save"**

### Step 5: Enable Firestore Database
1. In Firebase Console, go to **Firestore Database** (left sidebar)
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
4. Select a location (choose closest to you)
5. Click **"Enable"**

### Step 6: Update Security Rules (Optional but Recommended)
In Firestore Database → Rules tab, use these rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Step 7: Test the App
1. Stop the current Flutter app (press 'q' in terminal)
2. Run: `flutter clean`
3. Run: `flutter run`
4. Try to register with: `jaysonreales0@gmail.com` / `pass123`

## Alternative: Quick Fix (Temporary)
If you can't access Firebase Console right now, you can use Firebase Emulator Suite for local testing.

## Verification
After completing the steps, you should be able to:
- ✅ Register a new account
- ✅ Login with email/password
- ✅ See data saved to Firestore
- ✅ Unlock badges and earn XP

## Troubleshooting
- If still getting errors, check that the package name matches exactly: `com.tempo.tempo`
- Make sure Authentication and Firestore are both enabled
- Check that google-services.json is in the correct location
