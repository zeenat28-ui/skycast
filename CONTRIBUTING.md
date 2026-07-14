# Contributing to SkyCast Pro

Thanks for contributing. This project follows a conservative, production-quality workflow.

Guidelines
- Follow Effective Dart and SOLID principles.
- Use feature-first structure and avoid placing business logic in UI.
- Write unit tests for new business logic and widget tests for UI.
- Run `flutter analyze` and `flutter test` before opening a PR.

Branching & PRs
- Use feature branches and open pull requests into `main`.
- Use meaningful commit messages and prefer conventional commits.

CI
- The repository runs `flutter analyze` and `flutter test` on PRs via GitHub Actions.
# Contributing to SkyCast Pro

Thank you for your interest in contributing to SkyCast Pro! We welcome contributions from the community.

## Code of Conduct

Be respectful, inclusive, and professional in all interactions.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/skycast-pro.git`
3. Create a branch: `git checkout -b feature/your-feature-name`
4. Set up environment (see README.md)

## Development Workflow

### Setup
```bash
flutter clean
flutter pub get
flutter pub run build_runner build
```

### Running
```bash
flutter run
```

### Testing
```bash
flutter test
flutter test --coverage
```

### Code Quality
```bash
flutter analyze
dart format lib/
```

## Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable names
- Keep functions small and focused
- Add comments for complex logic
- Use const constructors where possible

## Commit Messages

Follow conventional commits:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes
- `test:` Adding or updating tests
- `refactor:` Code refactoring

Example:
```
feat: add weather alerts feature

Add notifications for severe weather warnings
- Implement alert repository
- Add alert notifier
- Create alert UI screen
```

## Pull Request Process

1. Create descriptive PR title
2. Reference related issues (#123)
3. Describe changes made
4. Include testing information
5. Ensure all tests pass
6. Request review from maintainers

## Testing Requirements

- Unit tests for repository and notifier
- Widget tests for important screens
- Integration tests for critical flows
- Minimum 70% code coverage

## Documentation

Update relevant documentation:
- README.md for user-facing changes
- ARCHITECTURE.md for structural changes
- Code comments for complex logic
- API_SETUP.md for API-related changes

## Reporting Issues

Provide:
- Clear description
- Steps to reproduce
- Expected vs actual behavior
- Screenshots/videos if applicable
- Device and Flutter version

## Feature Requests

- Describe the feature
- Explain why it's needed
- Suggest implementation approach
- Reference related issues

## Questions?

- Check existing issues/discussions
- Review ARCHITECTURE.md
- Open a discussion

## License

By contributing, you agree your code will be licensed under MIT License.

---

Thank you for contributing! 🎉
