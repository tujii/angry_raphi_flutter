# Windows Development Guide for AngryRaphi

This guide provides instructions for building and running the AngryRaphi Flutter app on Windows.

## Prerequisites

### Required Software

1. **Flutter SDK 3.27.4+**
   - Download from [flutter.dev](https://flutter.dev)
   - Add Flutter to your PATH
   - Run `flutter doctor` to verify installation

2. **Visual Studio 2022 (Community Edition or higher)**
   - Download from [visualstudio.microsoft.com](https://visualstudio.microsoft.com/)
   - During installation, select **"Desktop development with C++"** workload
   - Required components:
     - MSVC v142 or later
     - Windows 10 SDK (10.0.19041.0 or later)
     - Windows 11 SDK (recommended)
     - C++ CMake tools for Windows

3. **Git for Windows**
   - Download from [git-scm.com](https://git-scm.com/)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/tujii/angry_raphi_flutter.git
cd angry_raphi_flutter
```

### 2. Enable Windows Desktop Support

Flutter's Windows support should be enabled by default, but verify:

```bash
flutter config --enable-windows-desktop
flutter doctor
```

Expected output should include:
```
[✓] Windows
    • Windows Version: Windows 10 or later
    • Windows IDE: Visual Studio 2022
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

Make sure you have the Firebase configuration file:
- `lib/firebase_options.dart` should exist
- It contains the Windows platform configuration

### 5. Add Gemini API Key (Optional)

For AI features:
1. Get your API key from [Google AI Studio](https://aistudio.google.com/app/api-keys)
2. Create a file named `gemini_api_key` in the project root
3. Add your API key to this file

## Building and Running

### Development Build

To run the app in development mode:

```bash
flutter run -d windows
```

This will:
- Compile the app in debug mode
- Launch the Windows application
- Enable hot reload for development

### Release Build

To create a release build:

```bash
flutter build windows --release
```

The executable will be located at:
```
build/windows/x64/runner/Release/angry_raphi.exe
```

### Release Build with Verbose Output

For debugging build issues:

```bash
flutter build windows --release -v
```

## Windows-Specific Features

### Window Configuration

The default window configuration is set in `windows/runner/main.cpp`:
- Initial size: 1280x720
- Title: "angry_raphi"
- Position: (10, 10)

To modify these settings, edit the `main.cpp` file:

```cpp
Win32Window::Size size(1280, 720);  // Width x Height
```

### Application Icon

The application icon is located at:
```
windows/runner/resources/app_icon.ico
```

To customize:
1. Create a new ICO file (256x256 or multiple sizes)
2. Replace `app_icon.ico`
3. Rebuild the application

### Version Information

Version information is configured in `windows/runner/Runner.rc`:
- Company Name: "tujii"
- Product Name: "angry_raphi"
- File Description: "AngryRaphi - Person rating app with raphcons"

## Debugging

### Running with Visual Studio

1. Build the project first:
   ```bash
   flutter build windows --debug
   ```

2. Open Visual Studio 2022

3. Open the solution file:
   ```
   build/windows/angry_raphi.sln
   ```

4. Set breakpoints as needed

5. Press F5 to debug

### Common Debug Commands

Check Flutter logs:
```bash
flutter run -d windows -v
```

Clear build cache:
```bash
flutter clean
flutter pub get
```

## Troubleshooting

### Visual Studio Not Found

**Problem**: `flutter doctor` shows Visual Studio is missing or incomplete

**Solution**:
1. Open Visual Studio Installer
2. Modify your VS 2022 installation
3. Ensure "Desktop development with C++" is selected
4. Include Windows 10/11 SDK
5. Apply changes and restart

### CMake Errors

**Problem**: Build fails with CMake-related errors

**Solution**:
1. Verify CMake is installed with Visual Studio
2. Check PATH includes CMake
3. Try rebuilding:
   ```bash
   flutter clean
   flutter pub get
   flutter build windows
   ```

### Missing DLLs

**Problem**: App crashes on launch with missing DLL errors

**Solution**:
- All required DLLs should be in the `Release` folder
- If missing, ensure you're running from the correct location
- The build process copies all dependencies automatically

### Firebase Connection Issues

**Problem**: App can't connect to Firebase on Windows

**Solution**:
1. Check Windows Firewall settings
2. Ensure `firebase_options.dart` includes Windows configuration
3. Verify internet connection
4. Check Firebase project settings

### Build Performance

**Problem**: Builds are slow

**Solution**:
1. Exclude `build/` directory from Windows Defender
2. Exclude `windows/` directory from antivirus
3. Use an SSD for development
4. Close unnecessary applications during build

## Distribution

### Creating a Distributable Package

After building for release, you need to package the application:

1. The executable and all dependencies are in:
   ```
   build/windows/x64/runner/Release/
   ```

2. This folder contains:
   - `angry_raphi.exe` (main executable)
   - `flutter_windows.dll`
   - `data/` folder with assets and ICU data
   - Other required DLLs

3. To distribute, create an installer using:
   - **Inno Setup**: Free installer creator
   - **MSIX**: Microsoft app package format
   - **ZIP archive**: Simple distribution method

### MSIX Package (Microsoft Store)

To create an MSIX package for Microsoft Store distribution:

1. Add MSIX configuration to `pubspec.yaml`:
   ```yaml
   msix_config:
     display_name: AngryRaphi
     publisher_display_name: tujii
     identity_name: com.tujii.angryraphi
     logo_path: assets/images/logo.png
   ```

2. Build MSIX:
   ```bash
   flutter pub run msix:create
   ```

## Testing

Run tests specifically for Windows:

```bash
flutter test --platform=windows
```

Run all tests:

```bash
flutter test
```

## Continuous Integration

The project includes a GitHub Actions workflow for Windows builds:
- Located at: `.github/workflows/windows-build.yml`
- Automatically builds on push and PR
- Uploads build artifacts
- Runs tests on Windows runner

## Performance Considerations

### Startup Performance

- First launch may be slower due to JIT compilation
- Release builds use AOT compilation for better performance
- Consider adding a splash screen for better UX

### Memory Usage

- The app uses Firebase which maintains persistent connections
- Monitor memory usage during development
- Profile using Visual Studio tools if needed

### Network Performance

- Firebase operations are asynchronous
- Use connection state monitoring
- Handle offline scenarios gracefully

## Additional Resources

- [Flutter Desktop Documentation](https://docs.flutter.dev/platform-integration/windows/building)
- [Windows Plugin Development](https://docs.flutter.dev/development/platform-integration/platform-channels)
- [Flutter Performance](https://docs.flutter.dev/perf)
- [Visual Studio Documentation](https://docs.microsoft.com/visualstudio/)

## Support

For Windows-specific issues:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review the main [README.md](../README.md)
3. Open an issue on GitHub with:
   - Windows version
   - Visual Studio version
   - Flutter doctor output
   - Error messages or logs
