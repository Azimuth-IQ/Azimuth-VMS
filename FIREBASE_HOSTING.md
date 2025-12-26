# Firebase Hosting Setup

## Configuration

Firebase Hosting is configured to deploy the Flutter web build to:

- **URL**: https://volunteer-management-sys-1fedf.web.app
- **Project**: volunteer-management-sys-1fedf

## Files

- **firebase.json**: Hosting configuration (points to `build/web` directory)
- **.firebaserc**: Project configuration
- **deploy.sh**: Automated deployment script

## Deployment Instructions

### Prerequisites

1. Install Firebase CLI:

   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

### Deploy to Firebase Hosting

#### Option 1: Using the deployment script (Recommended)

```bash
./deploy.sh
```

#### Option 2: Manual deployment

```bash
# Build the Flutter web app
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### Deploy Specific Features

Deploy only hosting:

```bash
firebase deploy --only hosting
```

Deploy specific Firebase features:

```bash
firebase deploy --only firestore
firebase deploy --only database
firebase deploy --only storage
```

## Build Output

The Flutter web build is generated in: `build/web/`

This directory contains:

- `index.html` - Main HTML file
- `main.dart.js` - Compiled Dart code
- `flutter.js` - Flutter web engine
- `assets/` - Images, fonts, and other assets
- `icons/` - App icons

## Firebase Hosting Features

### URL Rewrites

All routes are rewritten to `/index.html` to support Flutter's client-side routing.

### Custom Domain (Optional)

To add a custom domain:

1. Go to Firebase Console → Hosting
2. Click "Add custom domain"
3. Follow the instructions to verify and configure DNS

### Preview Channels (Optional)

Create preview deployments for testing:

```bash
firebase hosting:channel:deploy preview-name
```

## Troubleshooting

### Build Errors

If you encounter build errors:

```bash
flutter clean
flutter pub get
flutter build web --release
```

### Deployment Errors

Check Firebase CLI version:

```bash
firebase --version
```

Update if needed:

```bash
npm install -g firebase-tools@latest
```

### CORS Issues

If you encounter CORS issues with Firebase Storage, update `cors.json` and apply:

```bash
gsutil cors set cors.json gs://volunteer-management-sys-1fedf.firebasestorage.app
```

## Monitoring

View hosting activity and analytics:

- Firebase Console: https://console.firebase.google.com/project/volunteer-management-sys-1fedf/hosting
- Analytics: Available after deployment (measurementId: G-XM1CDER018)

## Notes

- The app uses Firebase Authentication, Realtime Database, Storage, and Cloud Messaging
- All Firebase services are configured in `lib/firebase_options.dart`
- The web build is optimized for production with `--release` flag
