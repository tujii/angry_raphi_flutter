# Contributing to AngryRaphi Flutter

Thank you for your interest in contributing to AngryRaphi! This document provides guidelines and standards for contributing to the project.

## Code Quality Standards

This project maintains high code quality standards enforced through automated checks. All contributions must meet these standards:

### Required Quality Metrics
- ✅ **Test Coverage**: ≥ 80% on new code
- ✅ **Code Duplication**: ≤ 3% on new code
- ✅ **All Tests Passing**: 100% pass rate
- ✅ **Code Analysis**: No errors or warnings
- ✅ **Security**: No vulnerabilities

## Getting Started

### Prerequisites
- Flutter SDK 3.27.x or higher
- Dart SDK 3.6.x or higher
- Git
- A code editor (VS Code, Android Studio, or IntelliJ IDEA recommended)

### Setup
1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/angry_raphi_flutter.git
   cd angry_raphi_flutter
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app to verify setup:
   ```bash
   flutter run -d chrome  # For web
   ```

## Development Workflow

### 1. Create a Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes
- Follow the [Copilot Instructions](.github/copilot-instructions.md)
- Write clean, readable code
- Follow existing code patterns and architecture
- Add documentation for public APIs

### 3. Write Tests
**This is mandatory!** All new code must have tests.

```bash
# Create test file mirroring the source file structure
# Example: lib/features/auth/domain/usecases/login.dart
#          test/features/auth/domain/usecases/login_test.dart

# Run tests
flutter test

# Check coverage
flutter test --coverage
```

### 4. Run Quality Checks
```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run all tests
flutter test
```

### 5. Commit Your Changes
```bash
git add .
git commit -m "feat: add user profile feature"
```

**Commit Message Format:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `test:` Adding or updating tests
- `refactor:` Code refactoring
- `style:` Code style changes (formatting)
- `chore:` Build process or auxiliary tool changes

### 6. Push and Create Pull Request
```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## Pull Request Process

### Before Creating PR
- [ ] All tests pass locally
- [ ] Code is formatted
- [ ] No analysis errors
- [ ] Test coverage ≥ 80% for new code
- [ ] Code duplication ≤ 3% for new code
- [ ] Documentation updated if needed

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Test coverage ≥ 80%
- [ ] All tests passing

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings introduced
```

### Review Process
1. Automated checks run on your PR
2. SonarQube analyzes code quality
3. If quality gates fail:
   - Review SonarQube report
   - Add missing tests
   - Refactor duplicated code
   - Fix issues and push updates
4. Once checks pass, request review from maintainers
5. Address review feedback
6. PR will be merged when approved

## Architecture

This project follows Clean Architecture principles:

```
lib/
├── core/              # Shared utilities and base classes
├── features/          # Feature modules
│   └── feature_name/
│       ├── data/      # Data sources, models, repositories
│       ├── domain/    # Entities, use cases, repository interfaces
│       └── presentation/ # UI, BLoC, widgets
```

### Key Patterns
- **BLoC**: State management pattern
- **Repository Pattern**: Data access abstraction
- **Use Cases**: Single responsibility business logic
- **Dependency Injection**: Injectable/GetIt

## Testing Guidelines

### Test Structure
```dart
void main() {
  late ClassUnderTest sut;
  late MockDependency mockDependency;

  setUp(() {
    mockDependency = MockDependency();
    sut = ClassUnderTest(mockDependency);
  });

  group('method_name', () {
    test('should succeed when conditions are met', () async {
      // arrange
      when(mockDependency.call(any))
          .thenAnswer((_) async => expected);

      // act
      final result = await sut.method();

      // assert
      expect(result, expected);
      verify(mockDependency.call(any));
    });

    test('should fail when conditions are not met', () async {
      // arrange
      when(mockDependency.call(any))
          .thenThrow(Exception());

      // act & assert
      expect(() => sut.method(), throwsException);
    });
  });
}
```

### What to Test
- ✅ Use cases (business logic)
- ✅ BLoC events and states
- ✅ Data transformations (models)
- ✅ Validation logic
- ✅ Error handling
- ✅ Edge cases and boundary conditions

### What Not to Test
- ❌ Third-party packages
- ❌ Flutter framework code
- ❌ UI widgets (unless complex logic)
- ❌ Simple getters/setters

## Code Review Guidelines

### For Contributors
- Keep PRs focused and small
- Respond to feedback promptly
- Be open to suggestions
- Test your changes thoroughly

### For Reviewers
- Be constructive and respectful
- Explain the reasoning behind suggestions
- Approve when quality standards are met
- Consider blocking if critical issues exist

## Quality Gate Failures

If your PR fails quality gates:

### Low Test Coverage
1. Check SonarQube report for uncovered lines
2. Add tests for uncovered code paths
3. Ensure both success and failure scenarios are tested
4. Push updates and wait for re-analysis

### High Code Duplication
1. Identify duplicated code blocks in SonarQube
2. Extract common logic to utility functions
3. Create reusable components
4. Document if duplication is intentional (e.g., use case pattern)

### Failed Tests
1. Review test failure output
2. Fix the issue or update tests if behavior changed
3. Run tests locally before pushing
4. Ensure tests are deterministic

## Resources

- [Copilot Instructions](.github/copilot-instructions.md)
- [Code Quality Agent](.github/agents/code-quality-agent.md)
- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Documentation](https://bloclibrary.dev/)
- [SonarQube Dashboard](https://sonarcloud.io/dashboard?id=tujii_angry_raphi_flutter)

## Questions?

If you have questions:
1. Check existing documentation
2. Review similar code in the project
3. Ask in PR comments
4. Open a discussion on GitHub

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.
