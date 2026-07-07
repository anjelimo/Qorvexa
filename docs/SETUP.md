# Qorvexa Setup Guide

## Prerequisites

- Flutter SDK (3.0.0 or later)
- Dart SDK (3.0.0 or later)
- Git
- Supabase Account
- Firebase Account
- M-Pesa Developer Account

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/anjelimo/Qorvexa.git
cd Qorvexa
```

### 2. Environment Setup

Copy the environment file and update with your credentials:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```
SUPABASE_URL=your_url
SUPABASE_ANON_KEY=your_key
FIREBASE_PROJECT_ID=your_project_id
MPESA_CONSUMER_KEY=your_key
MPESA_CONSUMER_SECRET=your_secret
```

### 3. Supabase Configuration

#### 3.1 Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Copy your project URL and anon key

#### 3.2 Run Database Migrations

1. Open Supabase SQL Editor
2. Run the SQL from `backend/migrations/001_initial_schema.sql`
3. Run RLS policies from `backend/policies/rls_policies.sql`

### 4. Firebase Setup

#### 4.1 Create Firebase Project

1. Go to [firebase.google.com](https://firebase.google.com)
2. Create a new project
3. Add Android and iOS apps

#### 4.2 Download Configuration Files

**Android:**
- Download `google-services.json`
- Place in `mobile/android/app/`

**iOS:**
- Download `GoogleService-Info.plist`
- Place in `mobile/ios/Runner/`

#### 4.3 Enable Services

- Enable Authentication (Email/Password, Google Sign-In)
- Enable Cloud Messaging
- Enable Analytics

### 5. M-Pesa Integration

See [M-PESA_INTEGRATION.md](M-PESA_INTEGRATION.md) for detailed setup.

### 6. Mobile App Setup

```bash
cd mobile
flutter pub get
flutter pub run build_runner build
```

#### Run on Android

```bash
flutter run
```

#### Run on iOS

```bash
cd ios
pod repo update
pod install
cd ..
flutter run
```

### 7. Web Admin Dashboard Setup

```bash
cd web
flutter pub get
flutter pub run build_runner build
flutter run -d chrome
```

## Database Seeding

To add sample data for testing:

1. Run seeds from Supabase SQL Editor
2. Files in `backend/seeds/` directory

## Troubleshooting

### Flutter issues

```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Build issues

```bash
flutter clean
flutter pub cache repair
```

### iOS issues

```bash
cd ios
rm -rf Pods Pod.lock
pod install
cd ..
```

## Next Steps

1. Review [ARCHITECTURE.md](ARCHITECTURE.md) for project structure
2. Check [API.md](API.md) for API documentation
3. Read [DEPLOYMENT.md](DEPLOYMENT.md) for deployment guidelines
