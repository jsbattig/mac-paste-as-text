# Utilities

This directory contains utility functions and helper classes for the "Paste as Text" extension.

## Responsibilities

- Provide common functionality used across the application
- Implement reusable components
- Handle cross-cutting concerns

## Key Files

- `ClipboardManager.swift`: Utilities for clipboard operations
- `ErrorHandler.swift`: Common error handling utilities
- `Logger.swift`: Logging utilities
- `ImageProcessor.swift`: Image processing utilities

## Design Principles

Utilities follow the DRY (Don't Repeat Yourself) principle:
- Extract common functionality into shared utilities
- Keep utilities focused and single-purpose
- Avoid stateful utilities when possible
- Use extension methods on existing types when appropriate