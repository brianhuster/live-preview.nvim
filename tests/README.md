# Tests

This directory contains functional tests for live-preview.nvim using plenary.test.

## Requirements

- Neovim >= 0.10.1
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - For testing framework

## Running Tests

```bash
# Run all tests
make test

# Run specific test file
nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}" -c "qa!"
```

## Test Structure

- `minimal_init.lua` - Minimal Neovim configuration for testing
- `test_*.lua` - Test files following plenary.test conventions
- Test files spawn child Neovim instances to test actual plugin functionality

## Test Coverage

The tests cover:
- Plugin loading and initialization  
- Command functionality (:LivePreview start/stop/pick)
- Server management and port handling
- File type detection and support
- Configuration management
- Error handling and edge cases