# Paste as Text

A macOS extension that adds a "Paste as Text" option to context menus, allowing users to extract text from images in the clipboard using AI services.

![Version](https://img.shields.io/badge/version-1.0-blue)
![Platform](https://img.shields.io/badge/platform-macOS%2012.0%2B-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- Extract text from images in your clipboard with a single click
- Integrates with macOS context menus
- Supports multiple AI services (Google Gemini, OpenAI, Anthropic)
- Configurable through System Preferences
- Secure API key storage in macOS Keychain
- Automatic paste option
- Notification support

## Documentation

- [User Guide](docs/user_guide.md) - How to use the extension
- [Developer Guide](docs/developer_guide.md) - Understanding the codebase
- [Xcode Setup Guide](docs/xcode_setup_guide.md) - Setting up the Xcode project
- [Next Steps](docs/next_steps.md) - Detailed roadmap for implementation
- [Remaining Tasks](docs/remaining_tasks.md) - Prioritized task list with checkboxes

## Project Structure

- `/plans`: Contains project planning documents and architecture designs
- `/src`: Source code for the application
  - `/app`: Main application code
  - `/extension`: Context menu extension code
  - `/settings`: System Preferences integration
  - `/services`: AI service adapters
  - `/utils`: Utility functions and helpers
- `/tests`: Test files following TDD approach
  - `/unit`: Unit tests
  - `/integration`: Integration tests
  - `/ui`: UI tests
- `/resources`: Static resources like icons and assets
- `/docs`: Additional documentation
- `/scripts`: Build and deployment scripts
  - `create_xcode_project.sh` - Automated Xcode project creation
  - `run_tests.sh` - Test runner for TDD workflow
  - `build_dmg.sh` - DMG package creation
  - `generate_placeholder_icons.sh` - Icon generation
- `/memory-bank`: Project memory bank with architecture details, technical decisions, and future plans

## Memory Bank

The memory bank contains markdown files that document various aspects of the project:

- `architecture.md`: Overall system architecture and component interactions
- `technical-details.md`: Technical implementation details and decisions
- `future-plans.md`: Planned enhancements and future development
- `issues.md`: Known issues and challenges
- `decisions.md`: Record of key decisions made during development

## Development Principles

This project follows:
- Domain-Driven Design (DDD) principles
- Test-Driven Development (TDD) approach
- KISS (Keep It Simple, Stupid) principle
- DRY (Don't Repeat Yourself) principle

## Getting Started

### Prerequisites

- macOS 12.0 (Monterey) or later
- Xcode 14 or later (for development)
- API key for at least one supported AI service

### Installation

#### From DMG Package (Coming Soon)

1. Download the latest DMG package from the [Releases](https://github.com/jsbattig/mac-paste-as-text/releases) page
2. Open the DMG file
3. Drag the "Paste as Text" application to your Applications folder
4. Follow the [User Guide](docs/user_guide.md) for setup instructions

#### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/jsbattig/mac-paste-as-text.git
   cd mac-paste-as-text
   ```

2. Create the Xcode project automatically:
   ```bash
   ./scripts/create_xcode_project.sh
   ```

3. Open the generated Xcode project:
   ```bash
   open PasteAsText.xcodeproj
   ```

4. Review the project settings and start implementing the [remaining tasks](docs/remaining_tasks.md)

4. Build and run the application in Xcode

## Contributing

Contributions are welcome! Please read the [Developer Guide](docs/developer_guide.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Thanks to the AI service providers for their OCR capabilities
- Inspired by the need to quickly extract text from images without manual typing