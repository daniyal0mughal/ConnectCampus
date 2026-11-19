# CampusConnect

A Flutter application for reporting and managing university complaints. Students submit issues to the correct department, department administrators respond and update their status, and the super administrator monitors activity across campus.

The app uses **Firebase Authentication and Cloud Firestore only**. Firebase Hosting, Cloud Functions, and Cloud Storage are not part of the active implementation.

## Features and user roles

| Role | Main features |
| --- | --- |
| Student | Sign up, submit a complaint, view personal complaints, track status, and read administrator remarks. |
| Department administrator | View complaints assigned to their department, monitor department totals, and update status with remarks. |
| Super administrator | View complaints across all departments, monitor totals by status, compare departments with a bar chart, filter complaints, and create department-admin accounts. |

### Student portal

- Compact Home screen with colored Submitted, Active, and Resolved totals.
- New complaint shortcut and category tiles.
- Complaint entries appear on the **Complaints** page; Home has no Recent complaints list.
- Complaint filters, detail view, status tracking, and remark history.
- Profile screen and sign-out action.

Active totals include complaints with Pending or In Progress status.

### Department administrator portal

- Department dashboard with workload totals.
- Current and past complaints belonging to the assigned department.
- Status updates and remarks visible to the student.
- A rejection requires a reason, supplied through the administrator's remark.

### Super administrator portal

- System-wide dashboard and complaint totals.
- Bar chart comparing CS and Medical department workloads.
- All complaints page with **category, department, and status filters** and a Clear filters action.
- No search text box on the All complaints page.
- Admins screen for creating department administrators with an assigned department, email, and password.

## Departments and categories

| Department | Firestore ID |
| --- | --- |
| CS Department | `cs` |
| Medical Department | `medical` |

Each department has four categories:

1. Cafeteria
2. Library
3. Laboratories & IT — displayed as **Labs & IT**
4. Teaching & Academic Affairs — displayed as **Academic affairs**

There are eight category documents. IDs combine the department and category, such as `cs_library` and `medical_library`.

## Complaint workflow

1. A student signs in and selects a department and category.
2. The student enters a title and description and submits the complaint.
3. The complaint starts as **Pending**. The repository reads its department from the selected category, and Firestore rules validate that assignment.
4. The assigned department administrator reviews it and saves a status with a remark.
5. The student sees the updated status and reply history. Super-admin totals reflect the saved data.

Supported statuses are `Pending`, `In Progress`, `Resolved`, and `Rejected`. The app does not enforce a fixed sequence between these statuses.

## Authentication and account creation

All users use the same email/password login screen. After authentication, the app reads `users/{uid}` from Firestore and opens the dashboard for that account's role. There are no role-selection buttons on the real login screen.

- **Students:** public signup collects full name, email, password, and password confirmation.
- **Department administrators:** accounts are created by a super administrator through the Admins screen.
- **Super administrators:** accounts and their privileged profiles are provisioned by the developer.
- **Password recovery:** use Forgot password on the login screen.
- **Missing profile:** the app displays an account-setup message with Sign out. It does not ask an administrator to complete a student-name form.

Passwords are managed by Firebase Authentication. Firestore does not store passwords or password hashes. Account credentials are supplied privately and are not included in this README.

## Technology

| Component | Implementation |
| --- | --- |
| UI | Flutter / Dart, Material 3 |
| Authentication | Firebase email/password authentication |
| Database | Cloud Firestore with real-time streams |
| Authorization | Firestore security rules and stored user roles |
| Configured platforms | Android and Web |
| Design | Compact layouts with navy, blue, amber, green, and coral accents; no gradients or purple |

The local development environment uses **Flutter 3.35.3**, **Dart 3.9.2**, and **JDK 21**. The project requires Dart `^3.9.2`. Android uses Gradle 8.12, Android Gradle Plugin 8.9.1, and Kotlin 2.3.0. Java and Kotlin compilation target JVM 11; the build runs on JDK 21.

## Project structure

```text
campusConnect/
├── lib/
│   ├── main.dart                      # App startup, Firebase initialization, theme
│   ├── firebase_options.dart          # Android and Web Firebase configuration
│   ├── models/                        # Complaint, admin-case, and user-profile models
│   ├── services/
│   │   └── campus_repository.dart     # Authentication and Firestore operations
│   ├── screens/
│   │   ├── auth/                      # Shared login, signup, and role-based routing
│   │   ├── admin/                     # Department dashboard and complaint management
│   │   ├── super_admin/               # System dashboard, filters, admin accounts
│   │   ├── student_shell.dart         # Student navigation
│   │   ├── dashboard_screen.dart      # Student Home
│   │   ├── complaints_screen.dart     # Student complaint list and filters
│   │   ├── new_complaint_screen.dart   # Submission form
│   │   ├── detail_screen.dart         # Complaint details
│   │   ├── profile_screen.dart        # Student profile
│   │   └── auth_screen.dart           # Explicit offline-preview entry screen
│   ├── widgets/
│   │   ├── student/                   # Compact student dashboard components
│   │   ├── student_widgets.dart       # Shared student UI components
│   │   └── remark_history.dart        # Complaint reply history
│   └── theme/                         # Shared colors
├── android/                           # Android application and Gradle configuration
├── web/                               # Flutter Web entry files
├── test/                              # Flutter tests and Firebase emulator checks
├── tools/                             # Developer-only Firebase/catalog utilities
├── firestore.rules                    # Validation and access rules
├── firestore.indexes.json             # Firestore index configuration
├── firebase.json                      # Firestore and emulator configuration
├── pubspec.yaml                       # Flutter dependencies
└── README.md
```

The `functions/` directory contains earlier backend work. It is not configured in `firebase.json` and is not used by the active app.

## Run locally

Prerequisites: the Flutter SDK, Android SDK and a device/emulator for Android, or Chrome for Web. Use JDK 21 for the tested Android build setup.

From the project directory:

```sh
flutter pub get
flutter doctor
flutter devices
flutter run -d <device-id>
```

Run the Web client locally:

```sh
flutter run -d chrome
```

Normal launches connect to the configured Firebase project, `campusconnect-9c792`.

### Offline UI preview

```sh
flutter run -d chrome --dart-define=ENABLE_PREVIEW=true
```

Preview mode skips Firebase initialization and uses in-memory sample data. Its role-selection controls are for screen previews only. They do not grant access to real accounts, and preview changes are not saved to Firestore.

## Firebase configuration

The existing project configuration is in `lib/firebase_options.dart`, `android/app/google-services.json`, and `.firebaserc`.

For a separate Firebase project:

1. Register Android and Web applications. The current Android application ID is `com.example.campus_connect`.
2. Enable email/password sign-in and create the Firestore database.
3. Replace the client configuration and project ID in the files above. Keep the `campusFirebaseOptions` getter used by `main.dart`.
4. Update the project constant in `tools/project_setup.cjs` before using its developer operations.
5. Deploy the Firestore rules and indexes, seed the department/category catalog, and provision a super administrator.

With the Firebase CLI signed in as an authorized project developer:

```sh
firebase deploy --only firestore:rules,firestore:indexes --project <project-id>
node tools/project_setup.cjs catalog-update
```

The catalog utility currently expects a globally installed Firebase CLI on Windows and uses its existing login. It verifies fixed catalog IDs and refuses conflicting entries or guessed reassignment of existing records.

### Developer provisioning of a super administrator

Create an email/password account through a trusted Firebase administrative interface. Then create `users/{uid}` using that account's exact Authentication UID, with:

| Field | Value |
| --- | --- |
| `full_name` | Administrator's name |
| `email` | The Authentication account's email |
| `role` | `super_admin` |
| `department_id` | `null` |
| `created_at` | Firestore timestamp |

Complete both records before handing over the account. The client cannot create or promote a super administrator. The `bootstrap` branch in `tools/project_setup.cjs` targets a legacy account and is not the provisioning flow for the current super administrator; review it before use.

## Firestore data model

Firestore uses string document IDs rather than SQL auto-increment integers. A user document's ID equals its Firebase Authentication UID.

| Collection | Key fields |
| --- | --- |
| `departments` | `name` |
| `categories` | `name`, `department_id` |
| `users` | `full_name`, `email`, `role`, `department_id`, `created_at` |
| `complaints` | `student_id`, `student_name`, `category_id`, `department_id`, `title`, `description`, `status`, `rejection_reason`, `latest_remark`, `last_remark_id`, `created_at`, `updated_at` |
| `complaint_remarks` | `complaint_id`, `admin_id`, `admin_name`, `remark`, `status_set`, `created_at` |

User roles are `student`, `dept_admin`, and `super_admin`. Students and super administrators have a null `department_id`; department administrators have `cs` or `medical`.

### Access and consistency

- Students can read their own complaints and submit new ones as themselves.
- Department administrators can read and update complaints only in their assigned department.
- Super administrators can read all complaints and create department-admin profiles.
- The current rules do not allow super administrators to update complaint statuses.
- Status changes and new remarks are committed together in a transaction. Remark history cannot be edited or deleted by clients.
- Request IDs help prevent duplicate submissions and replies on retries. Write timestamps come from Firestore.
- The department selected for a complaint must match its category document.

Department-admin creation uses a secondary Firebase Auth instance, preserving the super administrator's session. Auth and Firestore cannot share one transaction; an interrupted provisioning operation can leave an Auth account without a profile and require developer cleanup.

## Testing

```sh
flutter analyze
flutter test
```

The Flutter suite covers student signup, account routing, missing profiles, student complaint navigation, department actions, and super-admin filters.

Firebase security and catalog tests run against isolated local emulators:

```sh
firebase emulators:exec --project demo-campusconnect --only auth,firestore "node --test test/firestore_security.cjs"
```

These checks require Node.js with built-in `fetch`, the Firebase CLI, and Java. They use synthetic data in `demo-campusconnect`, not the live project. The emulator suite is separate from the Flutter client; normal app launches still use the configured live Firebase project.

Latest recorded app checks on **19 November 2026**: 12 Flutter tests passed, analysis of changed Dart files reported no issues, the ARM64 debug APK built and installed successfully, and the student dashboard was visually checked at 320, 390, and 1280-pixel widths.

## Build

Android debug APK for an ARM64 device:

```sh
flutter build apk --debug --target-platform android-arm64
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`.

Web build:

```sh
flutter build web
```

Output: `build/web/`. A Web release build has not been verified for the latest changes, and no website is deployed by this repository's Firebase configuration.

The Android release configuration currently uses debug signing and an example application ID. Configure release signing and your final application ID before distributing through an app store. Run one Android build at a time to avoid competing Gradle tasks writing the same outputs.

## Current scope and limitations

- Photo attachments are not implemented; the form states this and Firestore attachment writes are denied.
- No push notifications, automated escalation, or complaint editing/deletion by students.
- Super-admin totals and filters are calculated from streamed complaint records. Larger datasets will need pagination and aggregation.
- iOS and native desktop Firebase configurations are not included.
- The current build is intended for development and hackathon demonstration.
