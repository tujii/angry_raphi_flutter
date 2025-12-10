#!/usr/bin/env python3
import json
import re

def add_missing_metadata(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Parse JSON
    data = json.loads(content)
    
    # Find keys that need metadata
    keys_needing_metadata = []
    for key in data.keys():
        if not key.startswith('@') and f'@{key}' not in data:
            # Check if this key has placeholders
            value = data[key]
            if isinstance(value, str) and '{' in value and '}' in value:
                # Find placeholders
                placeholders = re.findall(r'{(\w+)}', value)
                keys_needing_metadata.append((key, placeholders))
            else:
                keys_needing_metadata.append((key, []))
    
    print(f"Found {len(keys_needing_metadata)} keys needing metadata")
    
    # Add metadata for each key
    for key, placeholders in keys_needing_metadata:
        metadata_key = f'@{key}'
        metadata = {"description": f"{key} text"}
        
        if placeholders:
            metadata["placeholders"] = {}
            for placeholder in placeholders:
                metadata["placeholders"][placeholder] = {"type": "String"}
        
        data[metadata_key] = metadata
    
    # Write back to file
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"Added metadata for {len(keys_needing_metadata)} keys to {file_path}")

if __name__ == "__main__":
    add_missing_metadata('/Users/tujiiprince/fun/angry_raphi_flutter/lib/l10n/app_en.arb')
    add_missing_metadata('/Users/tujiiprince/fun/angry_raphi_flutter/lib/l10n/app_de.arb')