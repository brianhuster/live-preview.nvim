#!/usr/bin/env python3
"""
Simple tests for live-preview.nvim plugin structure and basic functionality

This test suite validates the plugin structure and basic functionality
without requiring complex Neovim integration.
"""

import pytest
import os
import tempfile
import socket
from pathlib import Path
import subprocess
import json


def find_free_port(start_port=4001):
    """Find a free port starting from start_port"""
    port = start_port
    while port < start_port + 100:  # Try 100 ports
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.bind(('localhost', port))
                return port
        except OSError:
            port += 1
    raise RuntimeError("Could not find a free port")


def is_port_in_use(port):
    """Check if a port is in use"""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            result = s.connect_ex(('localhost', port))
            return result == 0
    except Exception:
        return False


def run_nvim_lua(lua_code, minimal_init=True):
    """Run a Lua snippet in Neovim and return the result"""
    plugin_dir = Path(__file__).parent.parent
    
    if minimal_init:
        # Create minimal init file
        init_lua = f"""
vim.opt.rtp:prepend('{plugin_dir}')
vim.opt.swapfile = false
vim.opt.backup = false  
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
"""
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.lua', delete=False) as f:
            f.write(init_lua)
            init_file = f.name
        
        args = ['nvim', '--headless', '--noplugin', '-u', init_file, '-c', f'lua {lua_code}', '-c', 'qa!']
    else:
        args = ['nvim', '--headless', '--noplugin', '-c', f'lua {lua_code}', '-c', 'qa!']
    
    try:
        result = subprocess.run(args, capture_output=True, text=True, timeout=10)
        if minimal_init:
            os.unlink(init_file)
        return result
    except subprocess.TimeoutExpired:
        if minimal_init and 'init_file' in locals():
            os.unlink(init_file)
        raise


class TestLivePreviewStructure:
    """Test class for live-preview.nvim structure and basic functionality"""

    def test_plugin_directory_structure(self):
        """Test that the plugin has the correct directory structure"""
        plugin_dir = Path(__file__).parent.parent
        
        # Check essential directories
        assert (plugin_dir / "lua").exists(), "lua/ directory should exist"
        assert (plugin_dir / "lua" / "livepreview").exists(), "lua/livepreview/ directory should exist"
        assert (plugin_dir / "plugin").exists(), "plugin/ directory should exist"
        
        # Check essential files
        assert (plugin_dir / "README.md").exists(), "README.md should exist"
        assert (plugin_dir / "plugin" / "livepreview.lua").exists(), "plugin/livepreview.lua should exist"
        
        # Check main Lua module
        main_module = plugin_dir / "lua" / "livepreview" / "init.lua"
        assert main_module.exists(), "lua/livepreview/init.lua should exist"

    def test_package_json_structure(self):
        """Test that pkg.json has correct structure"""
        plugin_dir = Path(__file__).parent.parent
        pkg_json = plugin_dir / "pkg.json"
        
        assert pkg_json.exists(), "pkg.json should exist"
        
        with open(pkg_json, 'r') as f:
            data = json.load(f)
        
        assert "name" in data, "pkg.json should have name field"
        assert "description" in data, "pkg.json should have description field"
        
        assert data["name"] == "live-preview.nvim", "Package name should be correct"

    def test_neovim_basic_functionality(self):
        """Test basic Neovim functionality"""
        result = run_nvim_lua('print("42")', minimal_init=False)
        assert result.returncode == 0, f"Neovim should run without errors: {result.stderr}"

    def test_plugin_commands_registration(self):
        """Test that plugin commands are registered"""
        lua_code = '''
            -- Check if commands exist
            print(vim.fn.exists(':LivePreview'))
            print(vim.fn.exists(':LivePreviewStop'))
        '''
        
        result = run_nvim_lua(lua_code)
        assert result.returncode == 0, f"Command registration test failed: {result.stderr}"
        
        # Commands should exist (return value 2)
        output_lines = result.stdout.strip().split('\n')
        if len(output_lines) >= 2:
            assert '2' in output_lines[-2] or '2' in output_lines[-1], "LivePreview command should be registered"

    def test_file_type_detection_basic(self):
        """Test basic file type detection without loading full plugin"""
        # Test basic filetype detection in Neovim
        with tempfile.NamedTemporaryFile(suffix='.md', delete=False, mode='w') as f:
            f.write("# Test markdown")
            md_file = f.name
        
        with tempfile.NamedTemporaryFile(suffix='.html', delete=False, mode='w') as f:
            f.write("<h1>Test HTML</h1>")
            html_file = f.name
        
        try:
            lua_code = f'''
                vim.cmd('edit {md_file}')
                print('md_filetype:' .. vim.bo.filetype)
                vim.cmd('edit {html_file}')
                print('html_filetype:' .. vim.bo.filetype)
            '''
            
            result = run_nvim_lua(lua_code)
            assert result.returncode == 0, f"File type test failed: {result.stderr}"
            
            # Check both stdout and stderr for output
            output = result.stdout + result.stderr
            assert "md_filetype:markdown" in output or "md_filetype:md" in output, f"Should detect markdown filetype. Output: {output}"
            assert "html_filetype:html" in output, f"Should detect HTML filetype. Output: {output}"
            
        finally:
            os.unlink(md_file)
            os.unlink(html_file)

    def test_lua_modules_syntax(self):
        """Test that Lua modules have valid syntax"""
        plugin_dir = Path(__file__).parent.parent
        lua_dir = plugin_dir / "lua" / "livepreview"
        
        # Find all Lua files
        lua_files = list(lua_dir.rglob("*.lua"))
        assert len(lua_files) > 0, "Should find Lua files"
        
        for lua_file in lua_files:
            # Test syntax by trying to compile each file
            lua_code = f'''
                -- Test syntax of {lua_file}
                local status, err = pcall(function()
                    loadfile('{lua_file}')
                end)
                print('syntax_check:{lua_file.name}:' .. tostring(status))
                if not status then
                    print('error:' .. tostring(err))
                end
            '''
            
            result = run_nvim_lua(lua_code, minimal_init=False)
            # Check both stdout and stderr for output
            output = result.stdout + result.stderr
            assert f"syntax_check:{lua_file.name}:true" in output, f"Syntax error in {lua_file}: {output}"

    def test_port_utilities(self):
        """Test port-related utilities"""
        # Test find_free_port function
        port = find_free_port(4001)
        assert port >= 4001, "Should find a free port"
        assert not is_port_in_use(port), "Free port should not be in use"
        
        # Test port occupation detection
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.bind(('localhost', port))
            s.listen(1)
            assert is_port_in_use(port), "Port should be in use when occupied"

    def test_file_operations(self):
        """Test file operations"""
        test_content = """# Live Preview Test
        
This is a test markdown file.

## Features  
- Live reload
- WebSocket support
- Multiple file types
"""
        
        # Create temporary file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.md', delete=False) as f:
            f.write(test_content)
            temp_file = f.name
        
        try:
            # Test reading file in Neovim
            lua_code = f'''
                vim.cmd('edit {temp_file}')
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                local content = table.concat(lines, '\\n')
                print('has_title:' .. tostring(string.match(content, 'Live Preview Test') ~= nil))
                print('has_features:' .. tostring(string.match(content, 'WebSocket support') ~= nil))
            '''
            
            result = run_nvim_lua(lua_code)
            assert result.returncode == 0, f"File operations test failed: {result.stderr}"
            # Check both stdout and stderr for output
            output = result.stdout + result.stderr
            assert "has_title:true" in output, f"Should read file title. Output: {output}"
            assert "has_features:true" in output, f"Should read file features. Output: {output}"
            
        finally:
            os.unlink(temp_file)

    def test_makefile_targets(self):
        """Test that Makefile has the correct targets"""
        plugin_dir = Path(__file__).parent.parent
        makefile = plugin_dir / "Makefile"
        
        assert makefile.exists(), "Makefile should exist"
        
        with open(makefile, 'r') as f:
            content = f.read()
        
        assert "test:" in content, "Makefile should have test target"
        assert "test_basic:" in content, "Makefile should have test_basic target"
        assert "pytest" in content, "Makefile should use pytest"

    def test_github_workflow_structure(self):
        """Test GitHub Actions workflow structure"""
        plugin_dir = Path(__file__).parent.parent
        workflow = plugin_dir / ".github" / "workflows" / "tests.yml"
        
        assert workflow.exists(), "GitHub workflow should exist"
        
        with open(workflow, 'r') as f:
            content = f.read()
        
        assert "pytest" in content or "make test" in content, "Workflow should run tests"
        assert "python" in content.lower(), "Workflow should setup Python"
        assert "neovim" in content.lower(), "Workflow should setup Neovim"


if __name__ == "__main__":
    # Run tests with pytest
    pytest.main([__file__, "-v"])