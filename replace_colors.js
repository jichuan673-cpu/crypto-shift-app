const fs = require('fs');
const path = require('path');

function walkDir(dir, callback) {
    fs.readdirSync(dir).forEach(f => {
        let dirPath = path.join(dir, f);
        let isDirectory = fs.statSync(dirPath).isDirectory();
        isDirectory ? walkDir(dirPath, callback) : callback(dirPath);
    });
}

walkDir(path.join(__dirname, 'lib'), (filePath) => {
    if (filePath.endsWith('.dart')) {
        let content = fs.readFileSync(filePath, 'utf8');
        let newContent = content
            .replace(/const Color\(0xFF00D2FF\)/g, 'const Color(0xFF555555)')
            .replace(/Color\(0xFF00D2FF\)/g, 'const Color(0xFF555555)')
            .replace(/const Color\(0xFF007AFF\)/g, 'const Color(0xFF555555)')
            .replace(/const Icon\(Icons\.lock_outline, size: 48, color: Colors\.amber\)/g, 'Icon(Icons.lock_outline, size: 48, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)')
            .replace(/const Icon\(Icons\.lock, size: 14, color: Colors\.amber\)/g, 'Icon(Icons.lock, size: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)')
            .replace(/const Icon\(Icons\.lock_outline, size: 64, color: Colors\.amber\)/g, 'Icon(Icons.lock_outline, size: 64, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)')
            .replace(/const Icon\(Icons\.lock_outline, size: 40, color: Colors\.amber\)/g, 'Icon(Icons.lock_outline, size: 40, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)');

        if (content !== newContent) {
            fs.writeFileSync(filePath, newContent, 'utf8');
            console.log('Updated ' + filePath);
        }
    }
});
