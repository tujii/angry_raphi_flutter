# Security Verification Checklist

Use this checklist to verify security practices before deploying or committing code.

## 📋 Pre-Commit Security Checklist

### Secret Management
- [ ] No API keys hardcoded in source files
- [ ] No passwords or credentials in source files
- [ ] `.gitignore` properly excludes sensitive files
- [ ] Environment variables used for secrets in production
- [ ] `gemini_api_key` file (if exists) is not staged for commit

### Firebase Security
- [ ] Firestore security rules are up to date
- [ ] Security rules tested (manually or with emulator)
- [ ] Firebase Console API restrictions configured
- [ ] Only necessary Firebase services enabled
- [ ] Admin access limited to specific emails

### Code Review
- [ ] No sensitive data in logs or error messages
- [ ] Input validation implemented where needed
- [ ] Authentication checks in place for protected features
- [ ] No TODO comments about security issues

## 🔍 Quick Security Audit Commands

### Check for potential secrets in staged files:
```bash
git diff --cached | grep -i "api[_-]key\|secret\|password\|token"
```

### Verify .gitignore is working:
```bash
git status --ignored
```

### Check for hardcoded keys in codebase:
```bash
grep -r "AIza" --include="*.dart" lib/ | grep -v "firebase_options.dart"
grep -r "sk-" --include="*.dart" lib/
```

### Find TODO security comments:
```bash
grep -rn "TODO.*security\|FIXME.*security" --include="*.dart" lib/
```

## 🚀 Pre-Deployment Checklist

### Firebase Configuration
- [ ] Firestore rules deployed: `firebase deploy --only firestore:rules`
- [ ] Firebase Console API restrictions set for production domains
- [ ] Firebase Authentication providers configured
- [ ] Firebase App Check enabled (recommended)

### Environment Variables
- [ ] Production API keys rotated from development keys
- [ ] GitHub Actions secrets up to date
- [ ] Service account has minimal required permissions

### Testing
- [ ] All tests passing
- [ ] Security rules tested with Firebase Emulator
- [ ] Manual testing of authentication flows
- [ ] Manual testing of authorization rules

### Documentation
- [ ] SECURITY.md updated with any new practices
- [ ] README.md reflects current setup process
- [ ] API key setup instructions accurate

## 🔐 Post-Deployment Verification

### Monitoring
- [ ] Check Firebase Console for unusual activity
- [ ] Monitor API key usage in Google Cloud Console
- [ ] Review authentication logs for anomalies

### Testing in Production
- [ ] Verify unauthenticated users cannot access protected data
- [ ] Verify users cannot modify other users' data
- [ ] Verify admin features require admin privileges
- [ ] Test rate limiting and quotas

## 🚨 Security Incident Response

If a security issue is discovered:

1. **Immediate Actions**
   - [ ] Assess severity and impact
   - [ ] Rotate compromised credentials immediately
   - [ ] Review Firebase Console for unauthorized access
   - [ ] Check git history for when issue was introduced

2. **Communication**
   - [ ] Notify repository owner/maintainers
   - [ ] Document incident details
   - [ ] Create private security advisory if needed

3. **Remediation**
   - [ ] Fix the vulnerability
   - [ ] Remove secrets from git history if committed
   - [ ] Update security documentation
   - [ ] Review similar code for same issue

4. **Prevention**
   - [ ] Update this checklist with lessons learned
   - [ ] Add automated checks if possible
   - [ ] Review and update security policies

## 📚 Resources

- [SECURITY.md](../SECURITY.md) - Main security documentation
- [Firebase Security Rules Documentation](https://firebase.google.com/docs/rules)
- [Firebase Security Checklist](https://firebase.google.com/support/guides/security-checklist)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)

## ✅ Sign-Off

**Last Security Review Date**: _________________

**Reviewed By**: _________________

**Next Review Date**: _________________

**Notes**:
_______________________________________________
_______________________________________________
_______________________________________________
