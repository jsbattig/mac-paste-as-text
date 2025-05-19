# Scripts

This directory contains build and deployment scripts for the "Paste as Text" macOS extension.

## Scripts

- `build_dmg.sh`: Script to create a DMG package for distribution
- `create_icons.sh`: Script to generate icon files in various sizes
- `setup_dev.sh`: Script to set up the development environment

## Usage

Scripts should be run from the project root directory:

```bash
# Example usage
./scripts/build_dmg.sh
```

## Guidelines

- All scripts should be executable (`chmod +x script.sh`)
- Include proper error handling and logging
- Add comments explaining complex operations
- Provide usage instructions at the top of each script