# How to Create Admin User

## Method 1: Firebase Console (Recommended)

1. **Go to Firebase Console**
   - Open: https://console.firebase.google.com
   - Select your project: `ashhabgymweb`
   - Go to: Firestore Database

2. **Create Admin User Document**
   - Click on "Start collection" 
   - Collection name: `admin_users`
   - Click "Next"

3. **Add Admin User Data**
   Copy and paste this JSON:

   ```json
   {
     "email": "admin@gym.com",
     "display_name": "Gym Administrator",
     "role": "admin", 
     "is_active": true,
     "created_by": "system"
   }
   ```

4. **Save the Document**
   - Click "Save"
   - Document ID will be auto-generated

## Method 2: Update Existing User Management Page

If the User Management page shows empty, it might be due to:

### **Check Firebase Rules**
Make sure your Firestore rules allow reading `admin_users` collection:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /admin_users/{userId} {
      allow read, write: if request.auth != null;
    }
    match /members/{memberId} {
      allow read, write: if request.auth != null;
    }
    match /pending_device_registrations/{registrationId} {
      allow read, write: if request.auth != null;
    }
    match /user_deletion_requests/{requestId} {
      allow read, write: if request.auth != null;
    }
    match /checkins/{checkinId} {
      allow read, write: if request.auth != null;
    }
    match /expired_checkin_attempts/{attemptId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Login Credentials

Once created, use these credentials to login:

- **Email**: `admin@gym.com`
- **Password**: `admin123`

## After Login

1. You'll see the admin dashboard
2. Go to "User Management" to create regular users
3. Regular users can manage gym members
4. Only admins can approve user deletion requests

## Troubleshooting

If User Management still shows empty:

1. **Check Firebase Console** - Verify document exists in `admin_users`
2. **Check Network** - Ensure app can connect to Firebase
3. **Check Browser Console** - Look for JavaScript errors
4. **Refresh App** - Try `flutter run -d chrome` again
