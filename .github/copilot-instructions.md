# GitHub Copilot Instructions for AngryRaphi Flutter

## Code Quality Standards

### Test Coverage Requirements
- **Minimum test coverage**: 80% for all new code
- Always write unit tests for:
  - New use cases
  - New events and states in BLoC
  - New business logic methods
  - Data transformations
  - Validation logic

### Code Duplication
- **Maximum duplication**: 3% for new code
- Exceptions:
  - Clean Architecture use case pattern (simple repository wrappers)
  - Standard boilerplate code
  - Similar test structure for consistency
- Avoid copy-pasting large code blocks
- Extract common logic into reusable functions/classes

## Testing Guidelines

### Unit Test Structure
Follow the existing test patterns in the repository:
- Use `flutter_test` package
- Use `mockito` for mocking dependencies
- Test structure: Arrange-Act-Assert (AAA)
- Group related tests with `group()`
- Test both success and failure scenarios
- Test edge cases and boundary conditions

### Test File Locations
- Feature tests: `test/features/<feature_name>/`
- Mirror the `lib/` directory structure
- Use `_test.dart` suffix for test files

### Example Test Pattern
```dart
void main() {
  late YourClass classUnderTest;
  late MockDependency mockDependency;

  setUp(() {
    mockDependency = MockDependency();
    classUnderTest = YourClass(mockDependency);
  });

  group('MethodName', () {
    test('should return expected result on success', () async {
      // arrange
      when(mockDependency.method(any))
          .thenAnswer((_) async => expectedResult);

      // act
      final result = await classUnderTest.method(input);

      // assert
      expect(result, expectedResult);
      verify(mockDependency.method(input));
      verifyNoMoreInteractions(mockDependency);
    });

    test('should return failure when dependency fails', () async {
      // arrange
      when(mockDependency.method(any))
          .thenThrow(Exception('error'));

      // act & assert
      expect(
        () => classUnderTest.method(input),
        throwsException,
      );
    });
  });
}
```

## Architecture Guidelines

### Clean Architecture Layers
1. **Presentation Layer** (UI, BLoC)
2. **Domain Layer** (Entities, Use Cases, Repository Interfaces)
3. **Data Layer** (Repository Implementations, Data Sources, Models)

### Use Case Pattern
- One use case per operation
- Inject repository via constructor
- Return `Either<Failure, Success>` from dartz
- Keep use cases simple (single responsibility)

### BLoC Pattern
- Events: User actions or system events
- States: UI states (Initial, Loading, Success, Error)
- Always test events and states for equality
- Test BLoC logic with `bloc_test` package when available

## Before Committing

### Checklist
- [ ] All new code has corresponding unit tests
- [ ] Test coverage is ≥ 80% for new code
- [ ] Code duplication is ≤ 3% for new code
- [ ] All tests pass (`flutter test`)
- [ ] Code analysis passes (`flutter analyze`)
- [ ] Code is formatted (`dart format`)
- [ ] No linting errors

### Running Quality Checks Locally
```bash
# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format .

# Check for unused dependencies
dart pub deps
```

## SonarQube Integration

The repository uses SonarQube Cloud for code quality analysis. After pushing, check:
- Test coverage metrics
- Code duplication metrics
- Code smells and bugs
- Security vulnerabilities

Address any quality gate failures before merging.

## Common Mistakes to Avoid

1. **Forgetting to add tests** - Always add tests with new functionality
2. **Not testing failure scenarios** - Test both happy and unhappy paths
3. **Copy-pasting code** - Extract common logic instead
4. **Not following existing patterns** - Match the style of existing code
5. **Skipping edge cases** - Test boundary conditions and null cases

## Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [BLoC Testing Guide](https://bloclibrary.dev/#/testing)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)
