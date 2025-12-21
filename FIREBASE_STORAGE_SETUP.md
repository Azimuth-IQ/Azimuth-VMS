# Firebase Storage Setup

## Storage Bucket URL
Your Firebase Storage bucket URL is:
```
gs://volunteer-management-sys-1fedf.firebasestorage.app/
```

## Storage Structure
Images are uploaded to the following path:
```
ihs/
  volunteerForms/
    {phoneNumber}/
      photo.jpg
      id_front.jpg
      id_back.jpg
      residence_front.jpg
      residence_back.jpg
```

## Required Firebase Console Configuration

### Step 1: Enable Firebase Storage
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `volunteer-management-sys-1fedf`
3. Click on "Storage" in the left sidebar
4. If not already enabled, click "Get Started"
5. Choose a location (should match your Firebase Database location)
6. Click "Done"

### Step 2: Configure Storage Rules
Firebase Storage needs proper security rules. Go to the "Rules" tab in Storage and replace the rules with:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload to their own folder
    match /ihs/volunteerForms/{phoneNumber}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Deny all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

**Important:** These rules require users to be authenticated. If you want to allow unauthenticated uploads (not recommended for production), use:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    match /ihs/volunteerForms/{phoneNumber}/{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

### Step 3: Verify Storage Bucket in Firebase Options (Optional)
The storage bucket should already be configured in your Firebase project. To verify:

1. Check [firebase_options.dart](lib/firebase_options.dart)
2. Ensure `storageBucket` is set in the FirebaseOptions

If it's missing, you may need to regenerate the file using:
```bash
flutterfire configure
```

## How It Works

### Upload Process
1. User fills the volunteer form with personal data
2. User selects images for:
   - Personal photo
   - National ID (front & back)
   - Residence card (front & back)
3. When clicking "Save", images are uploaded to Firebase Storage
4. Download URLs are generated and saved to Firebase Realtime Database
5. Form data with image URLs is saved to database

### Implementation Details
- **Method:** `_uploadImage(Uint8List imageData, String phoneNumber, String imageName)`
- **Storage Path:** `ihs/volunteerForms/{phoneNumber}/{imageName}`
- **Metadata:** Images are uploaded with `contentType: 'image/jpeg'`
- **Return Value:** Download URL or null on error

### Error Handling
- Upload errors are caught and displayed via SnackBar
- Failed uploads don't prevent form saving
- Console logs show upload progress

## Testing

1. Run the app: `flutter run -d chrome`
2. Navigate to FormFillPage
3. Fill in the phone number (required)
4. Upload at least one image
5. Click Save
6. Check Firebase Console > Storage to verify uploads
7. Check Console > Realtime Database to verify URLs are saved

## Security Notes

⚠️ **Production Recommendations:**
1. Implement proper authentication before allowing uploads
2. Add file size limits in Storage Rules (e.g., max 5MB per image)
3. Add file type validation
4. Implement virus scanning for uploaded files
5. Enable Firebase App Check to prevent abuse

### Enhanced Storage Rules with Size Limit
```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    match /ihs/volunteerForms/{phoneNumber}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
                   && request.resource.size < 5 * 1024 * 1024  // 5MB limit
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Troubleshooting

### Error: "Firebase Storage: User does not have permission to access..."
- **Solution:** Update Storage Rules to allow write access (see Step 2)

### Error: "Firebase Storage is not configured"
- **Solution:** Run `flutterfire configure` to regenerate Firebase options

### Images not appearing in Storage
- **Solution:** Check browser console for upload errors
- Verify phone number is not null
- Ensure Firebase Storage is enabled in console

### Download URLs not saving to database
- **Solution:** Check Realtime Database rules allow write access
- Verify VolunteerForm model includes image path fields

## Additional Resources
- [Firebase Storage Documentation](https://firebase.google.com/docs/storage)
- [FlutterFire Storage Plugin](https://firebase.flutter.dev/docs/storage/overview)
- [Firebase Security Rules](https://firebase.google.com/docs/storage/security)
