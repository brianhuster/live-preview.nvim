# Testing Dependencies for live-preview.nvim

This document lists the dependencies needed for testing live-preview.nvim.

## Runtime Dependencies 

- **Neovim** >= 0.10.1 - Required for all functionality

## Testing Dependencies

- **[plenary.nvim](https://github.com/nvim-lua/plenary.nvim)** - Primary testing framework
  - Provides `describe`, `it`, `before_each`, `after_each` functions
  - Enables spawning child Neovim instances for functional testing
  - Command: `PlenaryBustedDirectory` to run tests

## Development Dependencies (Optional)

- **luacheck** - Static analysis and linting
- **stylua** - Code formatting
- **lua** >= 5.1 - For running basic tests without Neovim (fallback)

## Installation

### Via Plugin Manager

Most plugin managers will automatically install plenary.nvim if listed as a dependency.

#### Lazy.nvim
```lua
{
  'brianhuster/live-preview.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
}
```

#### Packer.nvim
```lua
use {
  'brianhuster/live-preview.nvim',
  requires = { 'nvim-lua/plenary.nvim' }
}
```

### Manual Installation

```bash
# Clone plenary.nvim
git clone https://github.com/nvim-lua/plenary.nvim.git ~/.local/share/nvim/lazy/plenary.nvim

# Or to a different location and update your runtimepath
```

### CI/Automated Testing

The GitHub Actions workflow installs plenary.nvim automatically:

```yaml
- name: Install plenary.nvim
  run: |
    mkdir -p ~/.local/share/nvim/lazy
    git clone https://github.com/nvim-lua/plenary.nvim.git ~/.local/share/nvim/lazy/plenary.nvim
```

## Running Tests

```bash
# With plenary.nvim installed
make test

# Fallback without plenary (limited functionality) 
make test_basic
```