# AI Service Adapters

This directory contains the adapters for different AI services used by the "Paste as Text" extension.

## Responsibilities

- Provide a common interface for different AI services
- Handle API communication with each service
- Process responses and extract text from images

## Key Files

- `AIServiceAdapter.swift`: Protocol defining the common interface
- `GeminiAdapter.swift`: Adapter for Google Gemini API
- `OpenAIAdapter.swift`: Adapter for OpenAI API
- `AnthropicAdapter.swift`: Adapter for Anthropic Claude API

## Design Pattern

We're using the Adapter pattern to provide a consistent interface to different AI services, allowing the application to switch between them seamlessly.