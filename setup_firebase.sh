#!/bin/bash

echo "🔥 Tempo Firebase Setup Script"
echo "================================"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found"
    echo "📥 Installing Firebase CLI..."
    curl -sL https://firebase.tools | bash
    echo "✅ Firebase CLI installed"
else
    echo "✅ Firebase CLI already installed"
fi

echo ""
echo "🔐 Logging into Firebase..."
firebase login

echo ""
echo "📱 Configuring Flutter app with Firebase..."
flutterfire configure \
  --project=boardexam-checker \
  --platforms=android,ios \
  --android-package-name=com.tempo.tempo \
  --ios-bundle-id=com.tempo.tempo \
  --yes

echo ""
echo "✅ Firebase configuration complete!"
echo ""
echo "📋 Next steps:"
echo "1. Enable Authentication (Email/Password) in Firebase Console"
echo "2. Enable Firestore Database in Firebase Console"
echo "3. Run: flutter clean && flutter run"
echo ""
echo "🌐 Open Firebase Console: https://console.firebase.google.com/project/boardexam-checker"
