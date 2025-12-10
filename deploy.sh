#!/bin/bash

# AngryRaphi Deployment Script
# Builds Flutter web app and deploys to Firebase Hosting

set -e # Exit on any error

echo "🚀 Starting AngryRaphi deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Please run this script from the Flutter project root."
    exit 1
fi

# Step 1: Clean previous build
print_status "Cleaning previous build..."
flutter clean

# Step 2: Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get

# Step 3: Analyze code for errors
print_status "Analyzing code..."
if flutter analyze --no-fatal-infos; then
    print_success "Code analysis passed"
else
    print_warning "Code analysis found issues, but continuing..."
fi

# Step 4: Build web app
print_status "Building Flutter web app..."
flutter build web --base-href /

if [ $? -eq 0 ]; then
    print_success "Flutter build completed successfully"
else
    print_error "Flutter build failed"
    exit 1
fi

# Step 5: Deploy to Firebase
print_status "Deploying to Firebase Hosting..."
firebase deploy --only hosting

if [ $? -eq 0 ]; then
    print_success "🎉 Deployment completed successfully!"
    print_success "App is live at: https://angryraphi.web.app"
else
    print_error "Firebase deployment failed"
    exit 1
fi

echo ""
print_success "✅ All done! AngryRaphi is deployed and ready to use."