# Deployment Guide

## Production Build & Deployment

### Android Deployment

#### 1. Generate Signing Key

```bash
cd android
keytool -genkey -v -keystore ~/qorvexa-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias qorvexa
cd ..
```

#### 2. Configure Gradle

Create `android/key.properties`:

```properties
storeFile=/path/to/qorvexa-keystore.jks
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=qorvexa
```

#### 3. Build Release APK

```bash
flutter build apk --release
```

#### 4. Build App Bundle (Recommended)

```bash
flutter build appbundle --release
```

#### 5. Upload to Play Store

1. Go to [Google Play Console](https://play.google.com/console)
2. Create app entry
3. Configure store listing
4. Upload signed app bundle
5. Configure pricing and distribution
6. Submit for review

### iOS Deployment

#### 1. Generate Certificates

1. Go to [Apple Developer](https://developer.apple.com)
2. Create Distribution Certificate
3. Create App ID
4. Create Provisioning Profile

#### 2. Configure Xcode

```bash
cd ios
open Runner.xcworkspace
```

In Xcode:
- Set Bundle ID
- Configure signing
- Set version number

#### 3. Build Release IPA

```bash
flutter build ios --release
```

#### 4. Upload to App Store

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create app entry
3. Configure metadata
4. Upload IPA via Xcode or Transporter
5. Submit for review

### Web Deployment

#### 1. Build Web Release

```bash
cd web
flutter build web --release
```

#### 2. Deploy to Firebase Hosting

```bash
npm install -g firebase-tools
firebase login
firebase init hosting
firebase deploy
```

#### 3. Or Deploy to Traditional Server

```bash
cd build/web
# Copy to your server
scp -r . user@server:/var/www/qorvexa
```

### Backend (Supabase) Deployment

#### 1. Environment Configuration

```bash
supabase link
supabase db pull  # Get latest schema
```

#### 2. Deploy Migrations

```bash
supabase migration up
```

#### 3. Deploy Edge Functions

```bash
supabase functions deploy mpesa-payment
supabase functions deploy mpesa-callback
supabase functions deploy notifications
```

#### 4. Configure Secrets

```bash
supabase secrets set MPESA_CONSUMER_KEY="your_key"
supabase secrets set MPESA_CONSUMER_SECRET="your_secret"
```

## CI/CD Pipeline

### GitHub Actions Workflow

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: cd mobile && flutter pub get
      - run: flutter analyze
      - run: flutter test

  build_android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: cd mobile && flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v2
        with:
          name: app-release.apk
          path: mobile/build/app/outputs/flutter-apk/app-release.apk

  build_ios:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: cd mobile && flutter pub get
      - run: flutter build ios --release --no-codesign
```

## Monitoring & Analytics

### Firebase Console

- Monitor app crashes
- Track user analytics
- Check messaging delivery

### Supabase Dashboard

- Monitor database performance
- View API logs
- Check Edge Function executions

### M-Pesa Monitoring

- Track transaction success rates
- Monitor payment volumes
- Review failed transactions

## Post-Deployment

1. **Monitor crashes** - Check Firebase for any immediate issues
2. **Review analytics** - Track user adoption and key metrics
3. **Respond to feedback** - Monitor app reviews and ratings
4. **Plan updates** - Gather feedback for next release

## Rollback Procedure

### Play Store/App Store

1. Upload previous stable version
2. Set as default version
3. Users with problematic version will automatically update

### Web

```bash
firebase deploy --only hosting --version <previous-version-id>
```

## Performance Optimization

### Before Release

- [ ] Run performance profiler
- [ ] Optimize image sizes
- [ ] Enable release mode optimizations
- [ ] Test on low-end devices
- [ ] Verify offline functionality

### Post-Release

- [ ] Monitor crash rates
- [ ] Track frame rates (target: 60 FPS)
- [ ] Monitor memory usage
- [ ] Check battery impact

## Environment Setup for Deployment

### Production Environment Variables

```env
# Supabase Production
SUPABASE_URL=https://your-prod-project.supabase.co
SUPABASE_ANON_KEY=prod_anon_key

# Firebase Production
FIREBASE_PROJECT_ID=your-prod-firebase-project

# M-Pesa Production
MPESA_ENVIRONMENT=production
MPESA_CONSUMER_KEY=prod_consumer_key
MPESA_CONSUMER_SECRET=prod_consumer_secret
MPESA_BUSINESS_SHORTCODE=prod_shortcode
```

## Release Checklist

- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] Version number updated
- [ ] Release notes prepared
- [ ] Dependencies updated
- [ ] Security audit completed
- [ ] Performance tested
- [ ] Backup created
- [ ] Deployment plan documented
- [ ] Team notified
- [ ] Monitoring configured

## Support & Rollback

In case of critical issues:

1. **Immediate Rollback**: Deploy previous stable version
2. **Bug Fix**: Create hotfix branch, test, and redeploy
3. **Communication**: Notify users of issue and status
4. **Post-Mortem**: Review what went wrong and prevent recurrence
