# Qorvexa - East Africa Marketplace Platform

Qorvexa is a modern, scalable marketplace platform similar to Kilimall, Jumia, and Amazon. It provides a seamless shopping experience with buyer and seller functionality, secure payments via M-Pesa, real-time notifications, and comprehensive admin management.

## Features

### User Features
- **Authentication**: Secure registration and login for buyers and sellers
- **Product Browsing**: Search, filter, and discover products
- **Shopping Cart**: Add/remove items, manage quantities
- **M-Pesa Integration**: Secure mobile money payments
- **Order Tracking**: Real-time order status updates
- **In-App Chat**: Direct messaging with sellers
- **Push Notifications**: Order updates and promotions
- **Ratings & Reviews**: Community feedback system
- **Dark & Light Mode**: Theme customization
- **Offline Support**: Browse products without internet

### Admin Features
- **User Management**: Manage buyers and sellers
- **Product Management**: Add, edit, delete products and categories
- **Order Management**: Monitor all orders and fulfillment
- **Payment Management**: Track transactions and settlements
- **Analytics Dashboard**: Sales, traffic, and user insights

## Tech Stack

### Frontend
- **Mobile**: Flutter (Dart) for iOS and Android
- **Web Admin**: Flutter Web
- **State Management**: Riverpod
- **UI Framework**: Flutter Material 3

### Backend
- **Database**: Supabase PostgreSQL
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage
- **Real-time**: Supabase Realtime
- **Edge Functions**: Supabase Edge Functions

### Payment & Services
- **Mobile Money**: M-Pesa via Daraja API
- **Push Notifications**: Firebase Cloud Messaging
- **Analytics**: Firebase Analytics

## Project Structure

```
Qorvexa/
├── mobile/                    # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/           # App configuration
│   │   ├── models/           # Data models
│   │   ├── services/         # API and business logic
│   │   ├── providers/        # Riverpod state management
│   │   ├── screens/          # UI screens
│   │   ├── widgets/          # Reusable components
│   │   └── utils/            # Utilities
│   ├── pubspec.yaml
│   ├── android/              # Android-specific config
│   └── ios/                  # iOS-specific config
│
├── web/                       # Flutter Web admin dashboard
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   └── pubspec.yaml
│
├── backend/                   # Supabase configuration
│   ├── functions/            # Edge Functions
│   ├── migrations/           # Database migrations
│   ├── policies/             # RLS policies
│   └── seeds/                # Sample data
│
└── docs/                      # Documentation
    ├── ARCHITECTURE.md
    ├── SETUP.md
    ├── DEPLOYMENT.md
    └── M-PESA_INTEGRATION.md
```

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- Supabase account
- Firebase account
- M-Pesa Daraja developer account

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/anjelimo/Qorvexa.git
   cd Qorvexa
   ```

2. **Setup Environment**
   ```bash
   cp .env.example .env
   # Fill in your credentials
   ```

3. **Mobile App**
   ```bash
   cd mobile
   flutter pub get
   flutter run
   ```

4. **Web Admin**
   ```bash
   cd web
   flutter pub get
   flutter run -d chrome
   ```

## Documentation

- [Setup Guide](docs/SETUP.md) - Complete setup instructions
- [Architecture Overview](docs/ARCHITECTURE.md) - System design
- [M-Pesa Integration](docs/M-PESA_INTEGRATION.md) - Payment setup
- [Deployment Guide](docs/DEPLOYMENT.md) - Production deployment

## Development

### Code Style
- Follow Dart style guide
- Use meaningful variable names
- Comment complex logic
- Run `flutter analyze` before commits

### Testing
```bash
flutter test
```

### Build

**Android**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS**
```bash
flutter build ios --release
```

**Web**
```bash
flutter build web --release
```

## Security

- All API calls use HTTPS encryption
- Sensitive data stored securely with Supabase
- M-Pesa integration follows best practices
- RLS (Row Level Security) on all database tables
- Regular security audits recommended

## Contributing

1. Create a feature branch: `git checkout -b feature/feature-name`
2. Commit changes: `git commit -m 'Add feature'`
3. Push to branch: `git push origin feature/feature-name`
4. Submit a pull request

## License

MIT License

## Roadmap

- [ ] Phase 1: Core MVP (Buyer, Seller, Payments)
- [ ] Phase 2: Kenya Launch
- [ ] Phase 3: East Africa Expansion
- [ ] Phase 4: Advanced Features (AI recommendations)
- [ ] Phase 5: International Markets

## Support

For issues or questions, open an issue on GitHub.
