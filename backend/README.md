# Qorvexa Backend

Backend infrastructure and database setup for Qorvexa using Supabase.

## Structure

```
backend/
├── migrations/          # Database schema migrations
├── policies/            # Row Level Security (RLS) policies
├── functions/           # Edge Functions (serverless)
├── seeds/               # Sample data for development
└── README.md           # This file
```

## Database Setup

### Initial Setup

1. **Create Supabase Project**
   - Go to [supabase.com](https://supabase.com)
   - Create new project
   - Save connection string

2. **Link Local Project**
   ```bash
   supabase link --project-ref your_project_ref
   ```

3. **Apply Migrations**
   ```bash
   supabase migration up
   ```

4. **Apply RLS Policies**
   ```bash
   supabase db push
   ```

### Database Schema

#### Core Tables

- **users**: Extended user profiles with seller/buyer info
- **categories**: Product categories
- **products**: Seller products with inventory
- **cart_items**: Shopping cart items
- **orders**: Order records linking buyers and sellers
- **order_items**: Individual items in orders
- **reviews**: Product reviews with ratings
- **messages**: Direct messaging between users
- **transactions**: Payment transaction records
- **notifications**: User notifications

### Row Level Security (RLS)

All tables have RLS enabled with fine-grained policies:

- **Users**: Can only read own profile and public seller profiles
- **Products**: Anyone reads active products; sellers manage own
- **Orders**: Buyers and sellers see their respective orders
- **Messages**: Users see messages they sent/received
- **Notifications**: Users see their own notifications

## Edge Functions

### M-Pesa Payment (`mpesa-payment`)

Initiates STK push for M-Pesa payments.

**Request:**
```json
{
  "phone": "254707273543",
  "amount": 1000,
  "orderId": "order_123"
}
```

**Deploy:**
```bash
supabase functions deploy mpesa-payment
```

### M-Pesa Callback (`mpesa-callback`)

Handles M-Pesa payment confirmation callbacks.

**Deploy:**
```bash
supabase functions deploy mpesa-callback
```

### Notifications (`send-notification`)

Sends push notifications to users via Firebase.

**Deploy:**
```bash
supabase functions deploy send-notification
```

## Environment Variables

### Supabase Connection

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

### M-Pesa Configuration

```bash
MPESA_CONSUMER_KEY=your_consumer_key
MPESA_CONSUMER_SECRET=your_consumer_secret
MPESA_BUSINESS_SHORTCODE=174379
MPESA_PASSKEY=your_passkey
MPESA_CALLBACK_URL=https://yourdomain.com/api/mpesa/callback
MPESA_ENVIRONMENT=sandbox
```

### Firebase Configuration

```bash
FIREBASE_PROJECT_ID=your_project
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_client_email
```

## Development

### Local Development

```bash
# Start Supabase locally
supabase start

# Run migrations
supabase migration up

# View database
supabase studio

# Stop services
supabase stop
```

### Seeding Sample Data

```bash
# Load seed data
supabase db push
```

Edit `seeds/seed.sql` to add sample data:
- Categories
- Sample products
- Test users

## API Operations

### Authentication

Supabase handles auth automatically. JWT tokens are managed via:

```bash
# Sign up
POST /auth/v1/signup

# Sign in
POST /auth/v1/token

# Refresh
POST /auth/v1/token?grant_type=refresh_token
```

### REST API

Automatically generated from schema:

```bash
# Get products
GET /rest/v1/products?select=*

# Create order
POST /rest/v1/orders

# Get user orders
GET /rest/v1/orders?buyer_id=eq.{user_id}
```

### Real-time Subscriptions

Subscribe to changes:

```dart
final subscription = supabase
  .from('orders')
  .on(SupabaseEventTypes.all, (payload) {
    print('Order updated: ${payload.newRecord}');
  })
  .subscribe();
```

## Security

### Data Encryption

- **In Transit**: HTTPS/TLS for all connections
- **At Rest**: PostgreSQL encryption (AES-256)
- **Sensitive Fields**: M-Pesa numbers, payment receipts

### Authentication

- JWT-based with Supabase Auth
- Automatic token refresh
- Secure session storage on client

### Authorization

- Row Level Security (RLS) on all tables
- User context-based access control
- Admin role verification

### API Security

- Rate limiting via Supabase
- Input validation and sanitization
- CORS configured for allowed origins

## Monitoring

### Supabase Console

- View query performance
- Monitor database size
- Check API usage
- Review Edge Function logs

### Logs

Access via Supabase dashboard:
- Database logs
- Function invocation logs
- Authentication logs

## Backup & Recovery

### Automatic Backups

Supabase provides:
- Daily backups (free tier)
- Point-in-time recovery (Pro tier)
- 30-day retention

### Manual Backup

```bash
# Export database
pg_dump postgresql://... > backup.sql

# Import backup
psql postgresql://... < backup.sql
```

## Troubleshooting

### Connection Issues

1. Check `SUPABASE_URL` and keys
2. Verify project is active
3. Check firewall/network

### RLS Errors

1. Verify user is authenticated
2. Check RLS policies applied
3. Review user roles

### Performance

1. Check query indexes
2. Monitor connection pool
3. Review slow queries in console

## Resources

- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Supabase Vector](https://supabase.com/docs/guides/database/vector)
- [Row Level Security Guide](https://supabase.com/docs/guides/database/postgres/row-level-security)

## Support

For backend issues:
1. Check Supabase status page
2. Review function logs
3. Contact Supabase support
4. Check GitHub issues
