import os, re, sys

lua_strings = set()
for root, dirs, files in os.walk('A:/GitHub Projects/Avorion Vault/Cosmic Starfall/data'):
    for file in files:
        if file.endswith('.lua'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                # Find "..."%_t and '...'`%_t
                matches = re.findall(r'(["\'])((?:(?=(\\?))\3.)*?)\1\s*%\s*_[tT]', content, re.DOTALL)
                for quote, inner, _ in matches:
                    if '/* Weapon' not in inner:
                        # Translate unescaped quotes inside the string and newlines
                        # For PO files, inner is exactly as it appears in code
                        lua_strings.add(inner)

print(f"Found {len(lua_strings)} strings in Lua files.")

# Write to file for verification
with open('A:/GitHub Projects/Avorion Vault/Cosmic Starfall/extracted_py.txt', 'w', encoding='utf-8') as f:
    for s in sorted(lua_strings):
        f.write(s + '\n')

# Now process .po and .pot files
loc_dir = 'A:/GitHub Projects/Avorion Vault/Cosmic Starfall/data/localization'
if not os.path.exists(loc_dir):
    sys.exit(0)

# We will read each po/pot file block by block.
# A block is separated by blank lines.
for file in os.listdir(loc_dir):
    if file.endswith('.po') or file.endswith('.pot'):
        filepath = os.path.join(loc_dir, file)
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()

        # Split into blocks
        blocks = content.split('\n\n')
        new_blocks = []
        for block in blocks:
            # We keep headers (which usually have msgid "" and msgstr "")
            # Or if the block's msgid is in lua_strings.
            if not block.strip():
                continue
                
            # Extract msgid. It can span multiple lines (msgid "..."\n"...")
            # We'll use a simple regex to get the combined msgid string
            msgid_match = re.search(r'^msgid\s+(.+?)(?:^msgstr|\Z)', block, re.MULTILINE | re.DOTALL)
            if msgid_match:
                msgid_raw = msgid_match.group(1)
                # Combine multiple "..." "..."
                msgid_str = ""
                for m in re.findall(r'"([^"\\]*(?:\\.[^"\\]*)*)"', msgid_raw):
                    msgid_str += m
                
                # Unescape \n and \" from the msgid_str because lua_strings contains the literal source code string
                # Wait, lua_strings has literal \n as two characters!
                # Actually, in the source code it's \n, and in .po it's also \n. So they match perfectly!
                if msgid_str == "" or msgid_str in lua_strings:
                    new_blocks.append(block)
                else:
                    # Not found, drop the block
                    pass
            else:
                # Keep blocks that don't have msgid just in case
                new_blocks.append(block)

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n\n'.join(new_blocks) + '\n\n')

print("PO files updated.")
