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

StudyTrack uses **Supabase** as its backend.

Supabase provides:

* Authentication
* PostgreSQL database
* REST API

The REST API is accessed using **Dio**.

### Courses API

```text
GET    /rest/v1/courses
POST   /rest/v1/courses
PATCH  /rest/v1/courses
DELETE /rest/v1/courses
```

### Work API

Work items are stored in `work_items`:

```text
GET    /rest/v1/work_items
POST   /rest/v1/work_items
PATCH  /rest/v1/work_items
DELETE /rest/v1/work_items
```

### Projects API

```text
GET    /rest/v1/projects
POST   /rest/v1/projects
PATCH  /rest/v1/projects
DELETE /rest/v1/projects
```

### Milestones API

```text
GET    /rest/v1/milestones
POST   /rest/v1/milestones
PATCH  /rest/v1/milestones
DELETE /rest/v1/milestones
```

The REST API base URL is:

```text
SUPABASE_URL/rest/v1/
```

### Authentication

Supabase Auth is used for user registration and login.

Authenticated API requests include the user's JWT access token:

```text
Authorization: Bearer <access_token>
```

A Dio interceptor automatically adds the authorization header to requests.

When an API request returns `401 Unauthorized`, the application attempts to refresh the Supabase session and retry the request using the new access token.

## Local Storage

StudyTrack uses **SQLite (`sqflite`)** for local caching.

The application caches:

* Courses
* Work items
* Projects
* Milestones

When the device is offline, previously cached data can be loaded from SQLite.

Repositories determine whether data should be retrieved from the remote API or local storage.

## Configuration

### Prerequisites

Make sure the following are installed:

* Flutter
* Dart
* A configured Android or iOS development environment

### 1. Install dependencies

```text
flutter pub get
```

### 2. Configure Supabase

Create a Supabase project and obtain:

* Project URL
* Publishable key

### 3. Create the environment file

Create a `.env` file in the project root:

```text
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_PUBLISHABLE_KEY=your-publishable-key
```

Replace the values with the credentials from your Supabase project.

The `.env` file is loaded when the application starts.

### 4. Configure the Supabase database

The application requires:

```text
profiles
courses
work_items
projects
project_courses
milestones
```

Row Level Security (RLS) must be enabled so users can only access their own data and authorized project relationships.

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
| `dio`                | HTTP requests                         |
| `supabase_flutter`   | Supabase authentication and backend   |
| `sqflite`            | SQLite local storage                  |
| `connectivity_plus`  | Network connectivity detection        |
| `flutter_dotenv`     | Environment configuration             |
| `shared_preferences` | Local preferences and session storage |
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
