#!/usr/bin/env python3
import json
import re

def clean_arb_file(file_path):
    print(f"Cleaning {file_path}...")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Parse JSON
    try:
        data = json.loads(content)
    except json.JSONDecodeError as e:
        print(f"JSON decode error: {e}")
        return False
    
    # Create a clean dictionary to avoid duplicates
    clean_data = {}
    
    # Always keep the locale first
    if "@@locale" in data:
        clean_data["@@locale"] = data["@@locale"]
    
    # Process all keys in order, skipping duplicates
    seen_keys = {"@@locale"}
    
    for key, value in data.items():
        if key in seen_keys:
            continue
            
        seen_keys.add(key)
        clean_data[key] = value
        
        # If this is a localization key (not metadata), check if it needs metadata
        if not key.startswith('@'):
            metadata_key = f'@{key}'
            
            # Check if metadata already exists
            if metadata_key not in data:
                # Create basic metadata
                metadata = {"description": f"{key} text"}
                
                # Check if the value contains placeholders
                if isinstance(value, str):
                    placeholders = re.findall(r'{(\w+)}', value)
                    if placeholders:
                        metadata["placeholders"] = {}
                        for placeholder in placeholders:
                            metadata["placeholders"][placeholder] = {"type": "String"}
                
                clean_data[metadata_key] = metadata
                seen_keys.add(metadata_key)
            else:
                # Use existing metadata if present
                if metadata_key in data:
                    clean_data[metadata_key] = data[metadata_key]
                    seen_keys.add(metadata_key)
    
    # Write back cleaned data
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(clean_data, f, ensure_ascii=False, indent=2)
    
    print(f"Cleaned {file_path} - {len(clean_data)} unique keys")
    return True

if __name__ == "__main__":
    # Clean both ARB files
    clean_arb_file('/Users/tujiiprince/fun/angry_raphi_flutter/lib/l10n/app_de.arb')
    clean_arb_file('/Users/tujiiprince/fun/angry_raphi_flutter/lib/l10n/app_en.arb')
    print("ARB files cleaned successfully!")