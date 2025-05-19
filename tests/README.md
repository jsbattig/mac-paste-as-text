# Tests

This directory contains all the test files for the "Paste as Text" macOS extension, following the Test-Driven Development (TDD) approach.

## Directory Structure

- `/unit`: Unit tests for individual components
- `/integration`: Integration tests for component interactions
- `/ui`: UI tests for user interface and workflows

## Testing Approach

We use XCTest for unit and integration tests, and XCUITest for UI testing. Tests are written before implementation following the TDD cycle:

1. Write a failing test
2. Implement the minimum code to make the test pass
3. Refactor while keeping tests passing