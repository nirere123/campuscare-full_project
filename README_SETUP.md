# CampusCare – Campus Incident Reporting App

This package uses the modular code from the supplied `campusapp_code.zip`, with a `pubspec.yaml` added and the photo storage path/rules aligned. It has not been run against your Firebase project; configure and test it before submission.

## Files
- `pubspec.yaml`: Flutter packages (package name is `campusapp`, matching the test import).
- `lib/main.dart`: app entry point and Firebase initialization.
- `lib/models/incident.dart`: incident model, categories and statuses.
- `lib/services/`: Firebase Authentication and Firestore/Storage operations.
- `lib/providers/`: Provider state management.
- `lib/screens/`: login, email verification, incident list, form and detail screens.
- `lib/widgets/`: reusable incident card and status chip.
- `test/incident_test.dart`: small unit tests for ALU email validation/status values.
- `firestore.rules`, `storage.rules`: rules to paste into Firebase Console.

## Setup
1. Copy the contents of this package into the existing `campusapp` Flutter project. Merge/replace `lib`, `test`, and `pubspec.yaml`. Keep the existing `android`, `ios`, `web`, `windows`, and other generated platform folders.
2. In the terminal, open the Flutter project folder (the one containing `pubspec.yaml`) and run `flutter pub get`.
3. In Firebase Console, create a project. Enable Authentication > Email/Password, create a Firestore database, and enable Storage.
4. Paste `firestore.rules` into Firestore > Rules and publish. Paste `storage.rules` into Storage > Rules and publish.
5. Install Firebase CLI and FlutterFire CLI, sign in, and configure Android:
   - `npm install -g firebase-tools`
   - `firebase login`
   - `dart pub global activate flutterfire_cli`
   - `flutterfire configure`
   Choose the Firebase project and Android platform. This generates `lib/firebase_options.dart`; do not create that file manually.
6. Confirm the email domain in `lib/services/auth_service.dart`. The supplied code currently accepts `@alustudent.com` and `@alueducation.com`; change these only if your real official ALU email uses a different domain.
7. Start an Android emulator or connect an Android phone with USB debugging. Run `flutter devices`, then `flutter run`.
8. Register an account, verify the email from your inbox, then log in.
9. For staff testing, register a second account with an inbox you can access. In Firestore, open `users` and change that account document's `role` from `student` to `staff`. Sign in with that account to test status updates.

## Important
- The assignment requires Android/iOS emulator or a physical phone. Do not submit a browser-only run.
- Do not put `firebase_options.dart` or service-account credentials in public screenshots or documents. Do not commit service-account private keys.
- Staff role is not selectable in the app. Only an authorized administrator should grant it in Firestore.
- Firebase Storage may require enabling billing depending on the Firebase account/project. Check the Firebase Console's current plan and prompt before enabling paid billing.
- The rules are a starter baseline for this assignment. Test them and do not use them as production security rules without review.
