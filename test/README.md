# Test Documentation

This directory contains unit tests for the AngryRaphi Flutter application.

**Current Coverage:** 29 test files with 150+ test cases covering ~80% of critical components. See [TEST_COVERAGE_REPORT.md](../TEST_COVERAGE_REPORT.md) for detailed breakdown.

## Prerequisites

Before running tests, you need to generate mock files for the tests. The tests use Mockito for mocking dependencies.

## Generating Mock Files

Run the following command from the project root to generate mock files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or use the watch mode for continuous generation during development:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

This will generate `*.mocks.dart` files next to each test file that uses `@GenerateMocks` annotations.

## Running Tests

Once mocks are generated, you can run tests using:

### Run all tests
```bash
flutter test
```

### Run a specific test file
```bash
flutter test test/features/authentication/presentation/bloc/auth_bloc_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

## Test Structure

The test directory mirrors the `lib` directory structure:

- `test/core/` - Tests for core functionality (widgets, utils, network)
- `test/features/` - Tests for feature-specific code (blocs, repositories, pages)
- `test/services/` - Tests for services
- `test/shared/` - Tests for shared widgets and utilities

## Test Categories

### Widget Tests
- `test/core/widgets/` - Core widget tests
- `test/shared/widgets/` - Shared widget tests
- Tests for custom widgets and UI components

### Bloc Tests
- `test/features/*/presentation/bloc/` - BLoC tests for each feature
- Uses `bloc_test` package for testing BLoC state changes

### Repository Tests
- `test/features/*/data/repositories/` - Repository implementation tests
- Tests data layer logic and error handling

### Service Tests
- `test/services/` - Service layer tests
- Tests business logic and external service interactions

### Page Tests
- `test/features/*/presentation/pages/` - Page widget tests
- Tests for complete page widgets and their interactions

## Test Coverage

To view test coverage:

1. Generate coverage:
   ```bash
   flutter test --coverage
   ```

2. View coverage in browser (requires `lcov` tool):
   ```bash
   genhtml coverage/lcov.info -o coverage/html
   open coverage/html/index.html
   ```

## Writing New Tests

When adding new tests:

1. Follow the existing test structure
2. Add `@GenerateMocks` annotation for dependencies you want to mock
3. Generate mocks using build_runner
4. Write comprehensive test cases covering:
   - Happy path scenarios
   - Error cases
   - Edge cases
   - State changes (for BLoCs)

## Common Issues

### Mock files not found
Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate mock files.

### Test failures due to Firebase
Some tests may require Firebase initialization. Mock Firebase dependencies appropriately.

### Asset loading errors
Widget tests that load assets may need additional setup. Use `TestWidgetsFlutterBinding` for widget tests.
