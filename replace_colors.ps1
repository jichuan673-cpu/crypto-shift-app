$libPath = "c:\Users\kalus\.gemini\antigravity\lib"
$files = Get-ChildItem -Path $libPath -Filter "*.dart" -Recurse

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    $newContent = $content -replace 'const Color\(0xFF00D2FF\)', 'const Color(0xFF555555)'
    $newContent = $newContent -replace 'Color\(0xFF00D2FF\)', 'const Color(0xFF555555)'
    $newContent = $newContent -replace 'const Color\(0xFF007AFF\)', 'const Color(0xFF555555)'
    
    $newContent = $newContent -replace 'const Icon\(Icons\.lock_outline, size: 48, color: Colors\.amber\)', 'Icon(Icons.lock_outline, size: 48, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)'
    $newContent = $newContent -replace 'const Icon\(Icons\.lock, size: 14, color: Colors\.amber\)', 'Icon(Icons.lock, size: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)'
    $newContent = $newContent -replace 'const Icon\(Icons\.lock_outline, size: 64, color: Colors\.amber\)', 'Icon(Icons.lock_outline, size: 64, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)'
    $newContent = $newContent -replace 'const Icon\(Icons\.lock_outline, size: 40, color: Colors\.amber\)', 'Icon(Icons.lock_outline, size: 40, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)'

    if ($content -ne $newContent) {
        Set-Content -Path $file.FullName -Value $newContent -NoNewline -Encoding UTF8
        Write-Host "Updated $($file.FullName)"
    }
}
