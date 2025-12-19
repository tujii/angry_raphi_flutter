# Code Quality Agent

## Purpose
This agent ensures that all code changes meet the project's quality standards before being merged.

## Quality Gates

### 1. Test Coverage
- **Requirement**: ≥ 80% coverage on new code
- **Tool**: SonarQube Cloud
- **Action**: Block merge if coverage is below threshold

### 2. Code Duplication
- **Requirement**: ≤ 3% duplication on new code
- **Tool**: SonarQube Cloud
- **Exception**: Clean Architecture use case patterns
- **Action**: Block merge if duplication exceeds threshold

### 3. Code Analysis
- **Tool**: Flutter analyze
- **Action**: Block merge if analysis fails
- **Severity**: All errors and warnings must be resolved

### 4. Unit Tests
- **Tool**: Flutter test
- **Action**: Block merge if any test fails
- **Coverage**: All new features must have corresponding tests

## Automated Checks

### On Pull Request
1. Run `flutter analyze` to check code quality
2. Run `flutter test` to execute all tests
3. Generate coverage report
4. Upload coverage to SonarQube
5. Check SonarQube quality gate status
6. Report results in PR comments

### Quality Gate Criteria

#### ✅ Pass Conditions
- Test coverage ≥ 80% on new code
- Code duplication ≤ 3% on new code
- All tests passing
- No critical code smells
- No security vulnerabilities
- No blocker issues

#### ❌ Fail Conditions
- Test coverage < 80% on new code
- Code duplication > 3% on new code
- Any failing tests
- Critical security vulnerabilities
- Blocker issues present

## Developer Workflow

### Before Creating PR
1. Write unit tests for all new code
2. Run tests locally: `flutter test --coverage`
3. Check coverage report in `coverage/lcov.info`
4. Run analysis: `flutter analyze`
5. Fix any issues found
6. Commit and push changes

### After PR Creation
1. Wait for CI/CD pipeline to complete
2. Review SonarQube analysis results
3. Address any quality gate failures:
   - Add missing tests for uncovered code
   - Refactor duplicated code
   - Fix code smells and bugs
4. Push fixes and wait for re-analysis
5. Once quality gate passes, request review

### Addressing Coverage Issues

If test coverage is below 80%:

1. **Identify uncovered code**:
   - Check SonarQube report for specific files/lines
   - Review `coverage/lcov.info` locally

2. **Add missing tests**:
   ```dart
   // Example: Testing a new use case
   test('should return success when operation completes', () async {
     // arrange
     when(mockRepo.method(any)).thenAnswer((_) async => Right(result));
     
     // act
     final result = await useCase(params);
     
     // assert
     expect(result, Right(expectedResult));
     verify(mockRepo.method(params));
   });
   ```

3. **Test both scenarios**:
   - Success cases
   - Failure cases
   - Edge cases
   - Null safety

### Addressing Duplication Issues

If code duplication exceeds 3%:

1. **Identify duplicated code**:
   - Check SonarQube duplication report
   - Look for similar code blocks

2. **Refactor to remove duplication**:
   - Extract common logic to utility functions
   - Create base classes for shared behavior
   - Use composition over inheritance
   - Apply DRY (Don't Repeat Yourself) principle

3. **Acceptable duplication**:
   - Use case pattern in Clean Architecture
   - Test setup/teardown code
   - Similar data models with different purposes

## SonarQube Configuration

### Project Key
`tujii_angry_raphi_flutter`

### Quality Profile
Flutter/Dart standard rules

### Quality Gate
Custom gate with strict requirements:
- Coverage on New Code ≥ 80%
- Duplicated Lines on New Code ≤ 3%
- Maintainability Rating on New Code ≥ A
- Reliability Rating on New Code ≥ A
- Security Rating on New Code ≥ A

## Monitoring

### Metrics to Track
- Test coverage trend
- Code duplication trend
- Technical debt ratio
- Bug count
- Vulnerability count
- Code smell count

### Reports Available
- Coverage report: `coverage/lcov.info`
- Test results: Console output
- SonarQube dashboard: [Link](https://sonarcloud.io/dashboard?id=tujii_angry_raphi_flutter)

## Troubleshooting

### Issue: Tests fail locally but pass in CI
- Ensure local environment matches CI (Flutter version, dependencies)
- Clear build cache: `flutter clean && flutter pub get`
- Check for platform-specific issues

### Issue: Coverage report not generated
- Ensure tests run with `--coverage` flag
- Check that test files follow naming convention `*_test.dart`
- Verify coverage files are not gitignored

### Issue: False positive duplication
- Review the duplicated code in SonarQube
- If it's acceptable pattern duplication, document in PR
- Consider if refactoring would improve maintainability

## Support

For questions or issues with code quality checks:
1. Review this documentation
2. Check SonarQube analysis details
3. Review existing tests for patterns
4. Ask in PR comments for guidance
