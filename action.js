const fs = require('fs');

const packspec = JSON.parse(fs.readFileSync('pkg.json', 'utf8'));
console.log(packspec.name, packspec.version, packspec.engines.nvim);

const updateReadme = (file) => {
    let readme = fs.readFileSync(file, 'utf8');

    // Update plugin name and version
    const nameVersionRegex = /^# [\w.-]+/m;
    console.log(readme.match(nameVersionRegex));
    readme = readme.replace(nameVersionRegex, `# ${packspec.name} ${packspec.version}`);

    // Update Neovim requirements
    const nvimVersionRegex = /^- Neovim.*/m;
    console.log(readme.match(nvimVersionRegex));
    readme = readme.replace(nvimVersionRegex, `- Neovim ${packspec.engines.nvim}`);

    fs.writeFileSync(file, readme);

    console.log(`${file} has been updated based on pkg.json`);
};

// List all files in the current directory
const files = fs.readdirSync('.');

const readmeFiles = files.filter(file => file === 'README.md' || file.match(/^README\..*\.md$/));

readmeFiles.forEach(updateReadme);

