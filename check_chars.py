import unicodedata

dart_file = 'lib/features/product/presentation/product_detail_screen.dart'
with open(dart_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Check for Chinese characters specifically
for i, c in enumerate(content):
    if ord(c) > 0x4E00 and ord(c) < 0x9FFF:  # Chinese characters range
        start = max(0, i-5)
        end = min(len(content), i+5)
        print(f"Chinese char at {i}: {c!r}, context: {content[start:end]!r}")
        if i > 100:
            break
else:
    print("No Chinese characters found")

# Check for Japanese/Chinese specifically
for i, c in enumerate(content):
    name = unicodedata.name(c, '')
    if 'CJK' in name:
        print(f"CJK char at {i}: {c!r} ({name})")
        if i > 50:
            break
else:
    print("No CJK characters found")

# Also check for any suspicious characters
suspicious = []
for i, c in enumerate(content):
    if ord(c) > 127:
        cat = unicodedata.category(c)
        if cat not in ('Po', 'Mn', 'Lu', 'Ll', 'Nd', 'Mc', 'Me', 'Zs'):
            suspicious.append((i, c, cat))
            
print(f"\nSuspicious non-ASCII chars count: {len(suspicious)}")
if suspicious:
    for idx, (i, c, cat) in enumerate(suspicious[:50]):
        print(f"  Index {i}: char={c!r} ({cat})")
