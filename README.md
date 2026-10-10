# StudyTrack

[![Flutter CI](https://github.com/josiaskiesse17-commits/Study-Tracker/actions/workflows/flutter.yml/badge.svg)](https://github.com/josiaskiesse17-commits/Study-Tracker/actions/workflows/flutter.yml)

StudyTrack is a Flutter application for organizing learning through **courses, academic work, and projects**.

## Architecture

StudyTrack follows a **Feature-First Clean Architecture** approach.

The application is organized into three main layers:

```text
Presentation
     ↓
Domain
     ↓
Data
     ↓
Remote / Local Data Sources
```

### Presentation

Contains the user interface and application state.

* Pages
* Controllers
* Providers
* UI widgets

Riverpod is used for state management.

### Domain

Contains the application's core business logic.

* Entities
* Repository interfaces
* Use cases

The domain layer does not depend directly on Supabase, Dio, or SQLite.

### Data

Contains the implementation of the domain layer.

* Data models
* Repository implementations
* Remote data sources
* Local data sources

Repositories coordinate access to the remote API and local SQLite cache.

## Project Structure

```text
lib/
├── core/
│   ├── network/
│   ├── router/
│   ├── storage/
│   └── theme/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── courses/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── dashboard/
│   │   └── presentation/
│   │
│   ├── projects/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── work/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── l10n/
│   ├── app_en.arb
│   └── app_fr.arb
│
├── app.dart
└── main.dart
```

## APIs

StudyTrack uses **Firebase** as its backend.

Firebase provides:

* Authentication (Email/Password)
* Cloud Firestore database
* Built-in offline persistence

### Courses API

Courses are stored in a Firestore subcollection: `users/{uid}/courses/{courseId}`

```text
GET    users/{uid}/courses
POST   users/{uid}/courses
PATCH  users/{uid}/courses/{courseId}
DELETE users/{uid}/courses/{courseId}
```

### Work API

Work items are stored in a Firestore subcollection: `users/{uid}/workItems/{itemId}`

```text
GET    users/{uid}/workItems
POST   users/{uid}/workItems
PATCH  users/{uid}/workItems/{itemId}
DELETE users/{uid}/workItems/{itemId}
```

### Projects API

```text
GET    users/{uid}/projects
POST   users/{uid}/projects
PATCH  users/{uid}/projects/{projectId}
DELETE users/{uid}/projects/{projectId}
```

### Milestones API

Milestones are stored in a nested subcollection: `users/{uid}/projects/{projectId}/milestones/{milestoneId}`

```text
GET    users/{uid}/projects/{projectId}/milestones
POST   users/{uid}/projects/{projectId}/milestones
PATCH  users/{uid}/projects/{projectId}/milestones/{milestoneId}
DELETE users/{uid}/projects/{projectId}/milestones/{milestoneId}
```

### Authentication

Firebase Auth is used for user registration and login.

### Project Courses (links)

Course-project links are stored in: `users/{uid}/projects/{projectId}/linkedCourses/{courseId}`

## Local Storage

StudyTrack uses **Cloud Firestore's built-in offline persistence** for local caching.

The application caches all user data (courses, work items, projects, milestones, project-course links) locally. When the device is offline, reads are served from the local cache, and writes are queued and synced automatically when connectivity is restored.

No manual SQLite caching or connectivity checks are needed — Firestore handles this transparently.

## Configuration

### Prerequisites

Make sure the following are installed:

* Flutter
* Dart
* A configured Android or iOS development environment
* Firebase CLI (`npm install -g firebase-tools`)

### 1. Install dependencies

```text
flutter pub get
```

### 2. Configure Firebase

Create a Firebase project and enable:

* **Authentication** → Email/Password sign-in method
* **Cloud Firestore** → Start in production mode

### 3. Configure the app with FlutterFire

```text
flutterfire configure
```

This generates `lib/firebase_options.dart` with your project configuration.

### 4. Deploy Firestore security rules

```text
firebase deploy --only firestore:rules
```

The rules in `firestore.rules` ensure users can only access their own data under `users/{uid}/...`.

### 5. Generate localization

StudyTrack supports **English and French**.

```text
flutter gen-l10n
```

### 6. Run the application

```text
flutter run
```

## Main Dependencies

| Package              | Purpose                               |
| -------------------- | ------------------------------------- |
| `flutter_riverpod`   | State management                      |
| `go_router`          | Navigation                            |
| `firebase_core`      | Firebase initialization               |
| `firebase_auth`      | Firebase Authentication               |
| `cloud_firestore`    | Cloud Firestore database              |
| `mocktail`           | Testing                               |

## Testing

StudyTrack includes:

* **13 unit tests**
* **5 widget tests**
* **2 integration tests**

Run all tests:

```text
flutter test
```

Run analysis:

```text
flutter analyze
```

Integration tests:

```text
flutter test integration_test/app_test.dart
```

## CI/CD

GitHub Actions automatically runs:

* `flutter pub get`
* `flutter gen-l10n`
* `flutter analyze`
* `flutter test`

Workflow:

```text
.github/workflows/flutter.yml
```

The CI workflow runs on pushes and pull requests.
