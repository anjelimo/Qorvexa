# Qorvexa Architecture

## Overview

Qorvexa follows a modular, scalable architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                   Client Layer                          │
│  ┌──────────────────┐         ┌──────────────────┐    │
│  │  Flutter Mobile  │         │   Flutter Web    │    │
│  │  (iOS/Android)   │         │  (Admin Panel)   │    │
│  └─────────┬────────┘         └────────┬─────────┘    │
└────────────┼─────────────────────────────┼──────────────┘
             │                             │
             ▼                             ▼
    ┌────────────────────────────────────────────┐
    │      Supabase Backend (PostgreSQL)         │
    ├────────────────────────────────────────────┤
    │ • Authentication                           │
    │ • Database (Tables & RLS)                 │
    │ • Real-time Subscriptions                 │
    │ • Storage (Images & Files)                │
    │ • Edge Functions                          │
    └────────────────────────────────────────────┘
             │
    ┌────────┴────────┬──────────────┬────────────┐
    ▼                 ▼              ▼            ▼
┌──────────┐  ┌────────────┐  ┌──────────┐  ┌──────────┐
│ Firebase │  │  M-Pesa    │  │ Daraja  │  │Analytics │
│Messaging │  │  Safaricom │  │   API   │  │          │
└──────────┘  └────────────┘  └──────────┘  └──────────┘
```

## Directory Structure

### Mobile App (`mobile/`)

```
mobile/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── config/
│   │   ├── theme/               # Theme configuration
│   │   ├── routes/              # Route definitions
│   │   └── constants/           # App constants
│   ├── models/                  # Data models (Product, Order, etc.)
│   ├── services/
│   │   ├── auth_service.dart    # Authentication logic
│   │   ├── product_service.dart # Product operations
│   │   ├── order_service.dart   # Order management
│   │   ├── payment_service.dart # M-Pesa integration
│   │   └── notification_service.dart
│   ├── providers/               # Riverpod state management
│   ├── screens/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── products/
│   │   ├── cart/
│   │   ├── checkout/
│   │   ├── orders/
│   │   ├── profile/
│   │   ├── chat/
│   │   └── admin/
│   ├── widgets/                 # Reusable UI components
│   └── utils/                   # Helper functions
├── assets/
│   ├── images/
│   ├── icons/
│   ├── animations/
│   └── fonts/
├── android/                     # Android-specific config
├── ios/                         # iOS-specific config
└── pubspec.yaml                 # Dependencies
```

### Web Admin Dashboard (`web/`)

```
web/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── dashboard/
│   │   ├── users/
│   │   ├── products/
│   │   ├── orders/
│   │   ├── payments/
│   │   ├── analytics/
│   │   └── settings/
│   ├── widgets/
│   ├── providers/
│   └── services/
└── pubspec.yaml
```

### Backend (`backend/`)

```
backend/
├── migrations/          # Database schema
├── policies/            # RLS policies
├── functions/           # Edge Functions
├── seeds/               # Sample data
└── README.md
```

## State Management

Using **Riverpod** for predictable, testable state management:

```dart
// Provider example
final authProvider = FutureProvider<User?>((ref) async {
  return await authService.getCurrentUser();
});

// Usage in widgets
final user = ref.watch(authProvider);
```

## Data Flow

### Authentication Flow

1. User enters email/password
2. Supabase Auth validates credentials
3. JWT token returned and stored locally
4. Token used for subsequent API calls
5. Refresh token automatically handles expiration

### Product Browsing Flow

1. App fetches categories from Supabase
2. User selects category
3. Products fetched with pagination
4. Images cached locally
5. Offline support via Hive cache

### Order & Payment Flow

1. User adds products to cart
2. Reviews order summary
3. Initiates M-Pesa payment
4. Daraja API prompts M-Pesa prompt on user's phone
5. User enters M-Pesa PIN
6. Payment confirmed, order created
7. Seller notified via push notification
8. Order tracking begins

## API Endpoints

Managed through Supabase:

- `POST /auth/v1/signup` - User registration
- `POST /auth/v1/token` - Login
- `GET /rest/v1/products` - Fetch products
- `POST /rest/v1/orders` - Create order
- `GET /rest/v1/orders/{id}` - Order details

## Security

### Database Security
- RLS (Row Level Security) on all tables
- JWT-based authentication
- Encrypted sensitive data

### API Security
- HTTPS only
- Rate limiting on Edge Functions
- Input validation and sanitization
- CORS configured

### M-Pesa Security
- SSL/TLS encryption
- Timestamp validation
- Signature verification
- PCI DSS compliance

## Performance Optimization

1. **Image Optimization**: Resize and compress on upload
2. **Pagination**: Load 20 items per page
3. **Caching**: Cache products locally with Hive
4. **Lazy Loading**: Load screens on demand
5. **Network Optimization**: Compress API responses
6. **Database**: Indexed frequently queried columns

## Scalability

- Supabase auto-scales databases
- Firebase handles push notifications
- M-Pesa API manages payment throughput
- CDN for image delivery
- Horizontal scaling through load balancing

## Monitoring & Analytics

- Firebase Analytics tracks user events
- Supabase logging for backend operations
- Error tracking via Sentry (optional)
- Performance monitoring

## Testing

- Unit tests for services
- Widget tests for UI
- Integration tests for flows
- E2E tests for critical paths

## CI/CD

- GitHub Actions for automated builds
- Tests run on every PR
- Automated deployment to stores
- Version management
