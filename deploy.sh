#!/bin/bash

# Firebase Hosting Deployment Script for Flutter Web
# This script builds the Flutter web app and deploys it to Firebase Hosting

echo "🚀 Starting Firebase Hosting deployment..."

# Build the Flutter web app
echo "📦 Building Flutter web app..."
flutter build web --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Deploy to Firebase Hosting
    echo "🔥 Deploying to Firebase Hosting..."
    firebase deploy --only hosting
    
    if [ $? -eq 0 ]; then
        echo "✅ Deployment successful!"
        echo "🌐 Your app is now live at: https://volunteer-management-sys-1fedf.web.app"
    else
        echo "❌ Deployment failed!"
        exit 1
    fi
else
    echo "❌ Build failed!"
    exit 1
fi
