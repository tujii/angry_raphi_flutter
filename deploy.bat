@echo off
REM AngryRaphi Deployment Script for Windows
REM Builds Flutter web app and deploys to Firebase Hosting

echo 🚀 Starting AngryRaphi deployment...

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo [ERROR] pubspec.yaml not found. Please run this script from the Flutter project root.
    exit /b 1
)

REM Step 1: Clean previous build
echo [INFO] Cleaning previous build...
call flutter clean

REM Step 2: Get dependencies
echo [INFO] Getting Flutter dependencies...
call flutter pub get

REM Step 3: Analyze code for errors
echo [INFO] Analyzing code...
call flutter analyze --no-fatal-infos
if errorlevel 1 (
    echo [WARNING] Code analysis found issues, but continuing...
)

REM Step 4: Build web app
echo [INFO] Building Flutter web app...
call flutter build web --base-href /

if errorlevel 1 (
    echo [ERROR] Flutter build failed
    exit /b 1
)

echo [SUCCESS] Flutter build completed successfully

REM Step 5: Deploy to Firebase (Hosting + Firestore Rules and Indexes)
echo [INFO] Deploying to Firebase (Hosting + Firestore)...
call firebase deploy --only hosting,firestore

if errorlevel 1 (
    echo [ERROR] Firebase deployment failed
    exit /b 1
)

echo [SUCCESS] 🎉 Deployment completed successfully!
echo [SUCCESS] App is live at: https://angryraphi.web.app
echo.
echo [SUCCESS] ✅ All done! AngryRaphi is deployed and ready to use.

pause