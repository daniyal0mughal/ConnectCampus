# CampusConnect

Flutter campus complaints app connected to Firebase project `campusconnect-9c792`.
Uses **Authentication and Firestore only**. Billing remains disabled. There is no
Hosting, Cloud Functions, or Storage deployment.

## Accounts

- Public signup creates students: full name, email, password, confirmation.
- Students choose CS Department or Medical Department, then submit complaints
  under one of the four categories and view their own complaints/reply history.
- Department administrators see only their department and save status/remarks.
- The super administrator sees system totals, department charts, search/filtering,
  and an **Admins** screen for creating department accounts with assigned credentials.
- Developer-created super administrator: **SuperAdmin1122@gmail.com**. Enter this
  email on the login screen and use **Forgot password?** to choose a password.
  The bootstrap password is randomly generated and never printed or saved.

Credentials belong exclusively to Firebase Authentication. Firestore never stores
passwords or password hashes. Roles cannot be selected during signup.

## Folder structure

```text
lib/models/              Complaint, admin-case and user-profile models
lib/services/            Auth/Firestore repository and user-facing errors
lib/screens/auth/        Real login, student signup and session routing
lib/screens/admin/       Department dashboard, lists and complaint updates
lib/screens/super_admin/ System dashboard and department-account management
lib/screens/             Student screens and explicit offline preview
lib/widgets/             Shared components and live reply history
lib/theme/               Existing compact navy/blue/amber styling
test/                    Flutter widgets and Auth/Firestore emulator tests
tools/project_setup.cjs  Developer-only seed/account bootstrap
firestore.rules          Server-enforced validation and authorization
```

## Firestore mapping and security

Firestore uses string document IDs instead of SQL auto-increment integers. User
IDs are Authentication UIDs. Department IDs are `cs` and `medical`. Each department
has Cafeteria, Library, Laboratories & IT, and Teaching & Academic Affairs.
The eight category IDs combine department and category, for example `cs_library`
and `medical_library`. Category names are unique within a department, rather than
globally unique. The client reads the selected category's `department_id` for
routing; Firestore rules reject any complaint with a different department.

- `users`: `full_name`, `email`, `role`, `department_id`, `created_at`.
- `departments`: `name`.
- `categories`: `name`, `department_id`.
- `complaints`: ERD fields plus `student_name`, `latest_remark`, `last_remark_id`.
- `complaint_remarks`: ERD fields plus `admin_name`. Replies are immutable.
- Attachments are unavailable in this version; attachment writes are denied.

Statuses are `Pending`, `In Progress`, `Resolved`, and `Rejected`. Status and
remark changes use one transaction, validated together by rules. Rejection
requires a reason, taken from the administrator's remark. Request IDs prevent
duplicates on retries. Timestamps come from Firestore.

Department-account creation uses a temporary secondary Auth instance so the
super administrator stays signed in. Only the primary super-admin session can
create the privileged Firestore profile. Failed profile creation attempts to
remove the new Auth account. Auth and Firestore cannot share a transaction: if
the process is terminated between steps, the developer may need to remove an
orphan Auth account before retrying. It has no department privileges.

No client can create or modify a super-admin profile. Developer bootstrap uses
the existing Firebase CLI login, refuses to promote an ordinary account, and
does not overwrite conflicting seed data.

## Development and checks

Normal launches use real authentication. Offline previews require the explicit
`--dart-define=ENABLE_PREVIEW=true` flag. Web and Android Firebase configurations
are included; no website is published by the Firebase configuration.

```sh
flutter pub get
flutter analyze
flutter test
flutter build web
firebase emulators:exec --project demo-campusconnect --only auth,firestore "node --test test/firestore_security.cjs"
```

The emulator test needs Node and Java 21. It uses a demo project, with no live
user data. It checks privilege escalation, scoped reads/queries, routing,
rejection reasons, atomic updates and immutable history. Widget tests cover
dashboard flows and student signup validation.

Verification on 2026-11-19: all 8 Flutter widget tests and the Auth/Firestore
emulator workflow passed, the live rules deployment succeeded, and Dart analysis
reported no issues. This Windows
environment intermittently crashes Dart processes with `0xC0000008`; the release
web build failed inside dart2js with that exit code, so a new release build is
not claimed. A missing generated test shader was rebuilt with Flutter's bundled
shader compiler. Existing build output should not be treated as a new release.

Developer operations:

```sh
firebase deploy --only firestore:rules --project campusconnect-9c792
node tools/project_setup.cjs bootstrap
node tools/project_setup.cjs catalog-update
```

At hackathon scale, the super-admin dashboard streams complaints and computes
totals/filtering locally. Larger deployments need pagination and aggregation.
Auth enforces unique login emails; fixed developer-owned catalog IDs keep the
two departments and eight category records consistent. SQL unique constraints are not automatic
in Firestore.

The catalog migration runs in a Firestore transaction, removes only unchanged
legacy seed entries, and refuses to guess a replacement department for existing
complaints or accounts. Department and category filters are independent, and
department charts aggregate all categories inside CS or Medical.

References: [rules](https://firebase.google.com/docs/firestore/security/rules-conditions),
[transactions](https://firebase.google.com/docs/firestore/manage-data/transactions),
[developer provisioning](https://docs.cloud.google.com/identity-platform/docs/reference/rest/v1/projects/accounts).
