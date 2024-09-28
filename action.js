const fs = require('fs');

const packspec = JSON.parse(fs.readFileSync('pkg.json', 'utf8'));

// Function to update a README file
const updateReadme = (file) => {
    let readme = fs.readFileSync(file, 'utf8');

    // Update plugin name and version
    const nameVersionRegex = /# \w+ \d+\.\d+\.\d+/;
    readme = readme.replace(nameVersionRegex, `# ${packspec.name} ${packspec.version}`);

    // Update Neovim requirements
    const nvimVersionRegex = /- Neovim \d+\.\d+\.\d+/;
    readme = readme.replace(nvimVersionRegex, `- Neovim ${packspec.engines.nvim}`);

    fs.writeFileSync(file, readme);

    console.log(`${file} has been updated based on pkg.json`);
};

// List files in the root directory
const files = fs.readdirSync('.');

// Filter for README.md and README.*.md files
const readmeFiles = files.filter(file => file === 'README.md' || file.match(/^README\..*\.md$/));

// Update each README file
readmeFiles.forEach(updateReadme);

