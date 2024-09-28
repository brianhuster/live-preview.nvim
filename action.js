const fs = require('fs');
const glob = require('glob');

const pkg = JSON.parse(fs.readFileSync('pkg.json', 'utf8'));

const updateReadme = (file) => {
    let readme = fs.readFileSync(file, 'utf8');

    // Update plugin name and version
    const nameVersionRegex = /# \w+ \d+\.\d+\.\d+/;
    readme = readme.replace(nameVersionRegex, `# ${pkg.name} ${pkg.version}`);

    // Update Neovim requirements
    const nvimVersionRegex = /- Neovim >= \d+\.\d+\.\d+/;
    readme = readme.replace(nvimVersionRegex, `- Neovim >= ${pkg.engines.nvim}`);

    fs.writeFileSync(file, readme);

    console.log(`${file} has been updated based on pkg.json`);
};

// Find all README.md and README.*.md files
glob('README.md', (err, files) => {
    if (err) throw err;

    if (fs.existsSync('README.md')) {
        files.push('README.md');
    }

    files.forEach(updateReadme);
});

glob('README.*.md', (err, files) => {
    if (err) throw err;

    files.forEach(updateReadme);
});

