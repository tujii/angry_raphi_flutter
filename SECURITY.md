# Security Policy

## 🔒 Security Overview

This document outlines the security practices and policies for the AngryRaphi Flutter application.

## 📋 Security Audit Summary

**Last Audit Date**: December 2025  
**Status**: ✅ No critical security vulnerabilities found

### Audit Findings

#### ✅ Firebase Client Credentials (Not a Security Risk)

**Files Containing Firebase Credentials:**
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

**Why This Is Safe:**

Firebase client API keys are **designed to be public** and are not sensitive credentials. According to [Firebase documentation](https://firebase.google.com/docs/projects/api-keys):

1. **Client API keys are safe to embed** in mobile and web applications
2. They identify your Firebase project, not authenticate it
3. **Security is enforced through Firestore Security Rules** (see `firestore.rules`)
4. Rate limiting and app restrictions are configured in Firebase Console

**What Protects Your Data:**
- ✅ Firestore Security Rules validate all database access
- ✅ Firebase Authentication ensures user identity
- ✅ Admin privileges controlled via email whitelist (`adminEmails` collection)
- ✅ API restrictions configured in Firebase Console

#### ✅ Gemini API Key Management (Secure)

**Current Implementation:**
- API key is **NOT** hardcoded in the codebase
- `ai_config.dart` has `_hardcodedApiKey = null` by default
- `.gitignore` excludes `gemini_api_key` file
- Environment variable support via `String.fromEnvironment('GEMINI_API_KEY')`

**Best Practices Followed:**
- ✅ No hardcoded API keys in version control
- ✅ Environment variable support for CI/CD
- ✅ Local development uses separate file (ignored by git)
- ✅ Graceful fallback when API key is unavailable

#### ✅ GitHub Actions Secrets (Secure)

**Secrets Used:**
- `GITHUB_TOKEN` (automatically provided by GitHub)
- `FIREBASE_SERVICE_ACCOUNT` (stored as GitHub secret)

**Verification:**
- ✅ No secrets hardcoded in workflow files
- ✅ Proper use of GitHub Secrets for sensitive credentials
- ✅ Service account has minimal required permissions

#### ✅ Firestore Security Rules (Properly Configured)

**Security Measures:**
- ✅ Authentication required for write operations
- ✅ Admin-only access for sensitive operations
- ✅ Public read access for appropriate data only
- ✅ Data validation on all write operations
- ✅ User isolation (users can only modify their own data)

## 🔐 Secret Management Best Practices

### For Developers

#### 1. **Never Commit Real Secrets**

Do **NOT** commit these to version control:
- ❌ Private API keys (e.g., Gemini API keys for personal use)
- ❌ Service account JSON files
- ❌ Database passwords
- ❌ OAuth client secrets
- ❌ Personal access tokens

Do commit these (they're safe):
- ✅ Firebase client API keys (public by design)
- ✅ Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`)
- ✅ Firebase project IDs and app IDs
- ✅ Public configuration files

#### 2. **Gemini API Key Setup**

**Option A: Local File (Development)**
```bash
# Create a file in project root (already in .gitignore)
echo "YOUR_API_KEY_HERE" > gemini_api_key
```

**Option B: Environment Variable (Production/CI)**
```bash
export GEMINI_API_KEY='YOUR_API_KEY_HERE'
flutter run --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
```

**Option C: GitHub Codespaces**
1. Go to Repository Settings → Secrets and variables → Codespaces
2. Add secret: `GEMINI_API_KEY`
3. Restart Codespace

#### 3. **Firebase Security**

**Required Security Measures:**

1. **Configure Firestore Security Rules** (`firestore.rules`)
   - Already implemented and deployed
   - Review rules when adding new features

2. **Set Firebase Console Restrictions**
   - Navigate to Firebase Console → Project Settings → API Keys
   - Add application restrictions:
     - For Web: HTTP referrers (your domain)
     - For Android: Package name and SHA-1
     - For iOS: Bundle ID

3. **Enable App Check** (Recommended for Production)
   - Protects against abuse from unauthorized clients
   - See [Firebase App Check Documentation](https://firebase.google.com/docs/app-check)

#### 4. **Admin Access Control**

Admin privileges are managed through:
- `adminEmails` collection in Firestore
- Email-based verification in security rules
- Cannot be bypassed through client-side code

To add/remove admins:
1. Access Firebase Console
2. Navigate to Firestore Database
3. Modify `adminEmails` collection
4. Only current admins can make changes

## 🚨 Reporting Security Vulnerabilities

If you discover a security vulnerability, please follow responsible disclosure:

### How to Report

1. **Do NOT** open a public issue
2. Email the security concern to: [Your Contact Email]
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Depends on severity
  - Critical: Within 24-48 hours
  - High: Within 7 days
  - Medium: Within 30 days
  - Low: Next release cycle

## 🔍 Regular Security Practices

### Code Review Checklist

Before merging code, verify:
- [ ] No hardcoded secrets or API keys
- [ ] Proper input validation
- [ ] Authentication/authorization checks
- [ ] No sensitive data in logs
- [ ] Dependencies are up to date
- [ ] Firestore rules updated if data model changed

### Dependency Security

Run security checks regularly:
```bash
# Check for known vulnerabilities in Dart packages
flutter pub outdated
dart pub audit
```

Update dependencies:
```bash
flutter pub upgrade
```

### Security Testing

1. **Authentication Testing**
   - Verify users cannot access others' data
   - Test admin-only features require proper privileges

2. **Authorization Testing**
   - Test Firestore rules with Firebase Emulator
   - Verify API restrictions work as expected

3. **Input Validation**
   - Test all user inputs for injection attacks
   - Verify data validation in Firestore rules

## 📚 Additional Resources

### Firebase Security
- [Firebase Security Documentation](https://firebase.google.com/docs/rules)
- [Firebase App Check](https://firebase.google.com/docs/app-check)
- [Firebase Security Best Practices](https://firebase.google.com/support/guides/security-checklist)

### Flutter Security
- [Flutter Security Best Practices](https://flutter.dev/security)
- [Dart Security](https://dart.dev/guides/security)

### General
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)

## 🔄 Security Policy Updates

This security policy is reviewed and updated:
- After each security audit
- When new features are added
- When security best practices evolve
- At least annually

**Last Updated**: December 2025
