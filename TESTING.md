# Testing Documentation for live-preview.nvim

This document describes the testing setup and approach for the live-preview.nvim plugin.

## Overview

The plugin uses **pytest with Python** for functional testing instead of plenary.nvim. This approach provides better compatibility across different Neovim versions and more reliable CI/CD integration.

## Test Architecture

### Why Python/pytest instead of plenary?

1. **Compatibility**: Avoids Neovim version compatibility issues with the main plugin code
2. **Reliability**: Uses subprocess calls to Neovim which are more stable than RPC connections
3. **CI/CD Friendly**: Python testing ecosystem has excellent GitHub Actions support
4. **Maintainability**: Easier to debug and maintain compared to complex plenary setups

### Test Structure

- **`test_livepreview.py`**: Main test suite containing all functional tests
- **`requirements.txt`**: Python dependencies (pytest, pynvim, requests)
- **`pytest.ini`**: Pytest configuration
- **Test files**: Sample markdown, HTML, and AsciiDoc files for testing

## Running Tests

### Local Development

```bash
# Install Python test dependencies
make test_install_deps

# Run all tests
make test

# Run tests directly with pytest (more verbose)
cd tests && python -m pytest test_livepreview.py -v
```

### Test Types

#### 1. Structure Tests
- Plugin directory structure validation
- Package.json structure verification
- Essential files existence checks

#### 2. Basic Functionality Tests
- Neovim startup and responsiveness
- Plugin command registration
- File type detection

#### 3. File Operation Tests
- File creation and reading
- Buffer manipulation
- Temporary file management

#### 4. Integration Tests
- Makefile target validation
- GitHub Actions workflow structure
- Configuration testing

### Test Environment

Tests run in isolated environments with:
- Temporary files for test content
- Minimal Neovim configuration
- No plugin conflicts
- Automatic cleanup

## Continuous Integration

### GitHub Actions Workflow

The `.github/workflows/tests.yml` workflow:
1. Sets up Python environment
2. Installs test dependencies
3. Sets up Neovim (multiple versions)
4. Runs pytest test suite
5. Runs luacheck and stylua (on one version only)

### Supported Neovim Versions

- v0.10.1 (LTS)
- nightly (latest)

## Test Features

### What's Tested

✅ Plugin directory structure  
✅ Essential file existence  
✅ Command registration  
✅ File type detection  
✅ Basic Lua syntax validation  
✅ Port utilities  
✅ File operations  
✅ Configuration structure  

### What's NOT Tested (Limitations)

❌ Full plugin loading (due to compatibility issues)  
❌ Live server functionality (requires complex setup)  
❌ WebSocket communication (needs running servers)  
❌ Browser integration (requires external tools)  

## Troubleshooting

### Common Issues

1. **Python Dependencies Missing**
   ```bash
   make test_install_deps
   ```

2. **Neovim Not Found**
   ```bash
   # On Ubuntu/Debian
   sudo apt-get install neovim
   
   # On macOS
   brew install neovim
   ```

3. **Tests Timing Out**
   - Usually indicates Neovim startup issues
   - Check Neovim version compatibility
   - Verify plugin structure

### Adding New Tests

To add new tests:

1. Add test methods to `TestLivePreviewStructure` class
2. Follow naming convention: `test_*`
3. Use descriptive docstrings
4. Clean up any temporary files
5. Test both success and failure cases

Example:
```python
def test_new_functionality(self):
    """Test description"""
    # Setup
    temp_file = self.create_temp_file("content", "md")
    
    try:
        # Test logic
        result = run_nvim_lua(f'vim.cmd("edit {temp_file}")')
        assert result.returncode == 0
        
    finally:
        # Cleanup
        os.unlink(temp_file)
```

## Migration from Plenary

This testing system replaces the previous plenary.nvim-based approach because:

1. **Compatibility Issues**: The plugin code had compatibility issues with older Neovim versions
2. **Setup Complexity**: Plenary required complex minimal_init.lua configuration
3. **Debugging Difficulty**: RPC-based tests were harder to debug than subprocess-based tests
4. **CI/CD Issues**: Plenary setup was unreliable in automated environments

The new approach provides better coverage of what can be reliably tested while avoiding the compatibility pitfalls of the previous system.