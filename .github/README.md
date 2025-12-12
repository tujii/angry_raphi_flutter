# GitHub Actions CI/CD Pipeline

This repository includes a GitHub Actions pipeline that automatically runs on pull requests and pushes to the main/master branch.

## What does the pipeline do?

### On Pull Requests:
1. **Analyze code** - Runs `flutter analyze` to check for code quality issues
2. **Run tests** - Runs `flutter test` to execute all unit tests

### On Push to main/master:
1. **Analyze and Test** - Same as pull requests
2. **Build** - Builds the Flutter web app in debug mode
3. **Deploy** - Deploys to Firebase Hosting

## Required Setup

To enable the deployment step, you need to configure a Firebase service account secret:

### 1. Create a Firebase Service Account

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project (angryraphi)
3. Go to Project Settings > Service Accounts
4. Click "Generate New Private Key"
5. Save the downloaded JSON file

### 2. Add the Secret to GitHub

1. Go to your repository on GitHub
2. Navigate to Settings > Secrets and variables > Actions
3. Click "New repository secret"
4. Name: `FIREBASE_SERVICE_ACCOUNT`
5. Value: Paste the entire content of the JSON file you downloaded
6. Click "Add secret"

## Pipeline Status

You can view the status of pipeline runs in the "Actions" tab of your GitHub repository.

## Workflow File

The workflow configuration is located at `.github/workflows/ci-cd.yml`

## Notes

- The pipeline runs on both `main` and `master` branches
- Deployment only happens on push to main/master, not on pull requests
- The Flutter version used is 3.27.1 (stable channel)
- The build uses canvaskit renderer for better performance
- Debug builds are deployed to allow for easier debugging in production
