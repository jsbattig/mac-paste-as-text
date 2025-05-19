# Contributing to Paste as Text

Thank you for your interest in contributing to the Paste as Text project! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please be respectful and considerate of others when contributing to this project. We aim to foster an inclusive and welcoming community.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR-USERNAME/mac-paste-as-text.git`
3. Create a branch for your changes: `git checkout -b feature/your-feature-name`
4. Make your changes following the development guidelines
5. Commit your changes: `git commit -m "Add your meaningful commit message"`
6. Push to your fork: `git push origin feature/your-feature-name`
7. Create a pull request

## Development Guidelines

### Project Structure

Please follow the existing project structure:

```
/
├── src/                      # Source code
│   ├── app/                  # Main application
│   ├── extension/            # Context menu extension
│   ├── settings/             # Preference pane
│   ├── domain/               # Domain model
│   ├── services/             # AI service adapters
│   └── utils/                # Utility functions
├── tests/                    # Test files
├── resources/                # Static resources
├── scripts/                  # Build and deployment scripts
└── docs/                     # Documentation
```

### Development Principles

This project follows:
- Domain-Driven Design (DDD) principles
- Test-Driven Development (TDD) approach
- KISS (Keep It Simple, Stupid) principle
- DRY (Don't Repeat Yourself) principle

### Coding Standards

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions small and focused
- Use Swift's type system to prevent errors

### Testing

- Write tests for all new functionality
- Follow the TDD approach:
  1. Write a failing test
  2. Implement the minimum code to make the test pass
  3. Refactor while keeping tests passing
- Ensure all tests pass before submitting a pull request

### Documentation

- Update documentation when making significant changes
- Document public APIs with documentation comments
- Keep the README and guides up to date

## Pull Request Process

1. Ensure your code follows the project's coding standards
2. Update documentation as necessary
3. Add tests for new functionality
4. Ensure all tests pass
5. Update the README.md if necessary
6. Submit your pull request with a clear description of the changes

## Adding a New AI Service

To add support for a new AI service:

1. Create a new adapter class that implements the `AIServiceAdapter` protocol
2. Add the new service type to the `AIServiceType` enum
3. Register the adapter in the `AIServiceManager`
4. Update the UI to include the new service option
5. Add tests for the new adapter

See the [Developer Guide](docs/developer_guide.md) for more details.

## Reporting Bugs

When reporting bugs, please include:

- A clear and descriptive title
- Steps to reproduce the bug
- Expected behavior
- Actual behavior
- Screenshots if applicable
- System information (macOS version, etc.)

## Feature Requests

When requesting features, please include:

- A clear and descriptive title
- A detailed description of the feature
- Why the feature would be useful
- Any relevant examples or mockups

## Questions

If you have questions about the project, please:

1. Check the [documentation](docs/)
2. Search for existing issues
3. Open a new issue with your question if it hasn't been addressed

## License

By contributing to this project, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).