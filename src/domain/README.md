# Domain Model

This directory contains the domain model for the "Paste as Text" extension, following Domain-Driven Design (DDD) principles.

## Responsibilities

- Define the core domain concepts
- Encapsulate business logic
- Provide a ubiquitous language for the project

## Directory Structure

- `/entities`: Entity classes (objects with identity)
- `/value_objects`: Value object classes (immutable objects defined by their attributes)

## Key Domain Concepts

- `ImageContent`: Entity representing an image from the clipboard
- `ExtractedText`: Value object representing the immutable result of OCR
- `AIServiceConfiguration`: Value object for service configuration
- `AIServiceManager`: Aggregate root managing all AI service adapters

## Design Principles

The domain model follows DDD principles:
- Entities have identity and mutable state
- Value objects are immutable and have no identity
- Aggregates define consistency boundaries
- Repositories provide access to aggregates