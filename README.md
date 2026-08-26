# Rantau

Rantau is a Flutter-based mobile application designed as a digital platform to help users plan, manage, and execute their travel trips effectively. The application provides an integrated system for discovering destinations, organizing itineraries, managing trip members, and scheduling with Google Calendar. 

The main features of Rantau include Destination discovery, Trip Management, and Google Calendar Integration. Users can browse various destinations, create detailed trips with start and end dates, invite other members to join their trip, and synchronize their travel itinerary directly to their Google Calendar. The application also provides user profile management and is built with a modular architecture integrated with Supabase for robust backend services.

## 📱 Features

### 🔐 Authentication
- User registration and login
- Email and password authentication
- Google Sign-In integration
- Secure session management with Supabase

### 🗺️ Destination (Explore)
- Discover travel destinations
- View detailed information about specific locations
- Destination data fetched dynamically

### 🧳 Trip Management
- Create new trips (Start Date, End Date, Name)
- Manage active and past trips
- Add destinations to trips
- **Trip Members**: Invite other users to join a trip using an invitation code
- Role-based trip management (Leader & Member)
- Track trip progress with a dynamic UI progress bar

### 📅 Google Calendar Integration
- Sync trips and itineraries directly to user's Google Calendar
- Request necessary OAuth scopes for Calendar access
- Schedule management using Google APIs

### 👤 Profile Management
- View user profile
- Manage account details and avatar

## 🗃️ Project Structure

```text
lib/
├── core/
│   ├── constants/         # App Colors, Typography, etc.
│   ├── router/            # go_router configuration
│   ├── widgets/           # Reusable global widgets
│   └── ...
│
├── features/
│   ├── auth/              # Authentication feature (Login/Register, Supabase Auth)
│   ├── beranda/           # Home Dashboard feature
│   ├── destination/       # Destination browsing & details
│   ├── google_calendar/   # Google Calendar sync integration
│   └── trip/              # Trip management (Create, My Trips, Members)
│
├── app.dart
└── main.dart
```

## ⚙️ Tech Stack

### 🧩 Framework & Language
- **Flutter**
- **Dart**

### 📦 State Management
- **Provider** (`provider`)

### 🧭 Navigation
- **go_router**

### 🎨 UI & Utilities
- **intl** (Date & string formatting)
- **equatable** (Value equality for models)
- **image_picker** (Camera & Gallery access)
- **cupertino_icons**

### ☁️ Backend as a Service
- **Supabase** (Database, Authentication, Storage via `supabase_flutter`)

### 🌐 Networking & APIs
- **http** (REST API integration)
- **googleapis** & **extension_google_sign_in_as_googleapis_auth** (Google Calendar API)

### 🔐 Authentication
- **Supabase Auth** (Email & Password)
- **Google Sign-In** (OAuth 2.0 via `google_sign_in`)

### ⚙️ Infrastructure & Configuration
- **flutter_dotenv** (Environment variable management)
- **flutter_native_splash** (Splash screen generation)
- **flutter_launcher_icons** (App icon generation)
