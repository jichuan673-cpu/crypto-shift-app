import os
import re

def replace_in_file(filepath, replacements):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    for old, new in replacements:
        new_content = re.sub(old, new, new_content)
        
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

def main():
    lib_dir = os.path.join(os.getcwd(), 'lib')
    
    # We want to replace Color(0xFF00D2FF) with a chic color.
    # We will use 'Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : const Color(0xFF333333)'
    # But because of const contexts, sometimes this is invalid.
    # Let's just use 'const Color(0xFF555555)' globally to be safe, or 'Colors.grey' where not const.
    # Actually, a chic grey for the primary color in main.dart:
    # Let's just replace 'const Color(0xFF00D2FF)' with 'const Color(0xFF555555)' everywhere first.
    # And 'Color(0xFF00D2FF)' with 'const Color(0xFF555555)'
    
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                
                replacements = [
                    (r'const Color\(0xFF00D2FF\)', r'const Color(0xFF555555)'),
                    (r'Color\(0xFF00D2FF\)', r'const Color(0xFF555555)'),
                    # Also replace the blue color in root_screen
                    (r'const Color\(0xFF007AFF\)', r'const Color(0xFF555555)'),
                    # Lock icons:
                    (r'const Icon\(Icons\.lock_outline, size: 48, color: Colors\.amber\)', r'Icon(Icons.lock_outline, size: 48, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)'),
                    (r'const Icon\(Icons\.lock, size: 14, color: Colors\.amber\)', r'Icon(Icons.lock, size: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)'),
                    (r'const Icon\(Icons\.lock_outline, size: 64, color: Colors\.amber\)', r'Icon(Icons.lock_outline, size: 64, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)'),
                    (r'const Icon\(Icons\.lock_outline, size: 40, color: Colors\.amber\)', r'Icon(Icons.lock_outline, size: 40, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)'),
                ]
                
                replace_in_file(filepath, replacements)

if __name__ == "__main__":
    main()
