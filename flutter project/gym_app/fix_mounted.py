import os, re
files = ['lib/trainers.dart', 'lib/sessions_schedule.dart', 'lib/sessions.dart', 'lib/plans.dart', 'lib/memberships.dart', 'lib/members.dart']
for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pattern for successful load: await api call followed by setState
    content = re.sub(r'(await (?:_api|widget\.api)[^;]+;\s*)setState\(\(', r'\1if (!mounted) return;\n      setState((', content)
    
    # Pattern for catch block followed by setState
    content = re.sub(r'(catch\s*\([^\)]+\)\s*\{\s*)setState\(\(', r'\1if (!mounted) return;\n      setState((', content)

    # Some methods might have double if (!mounted) now if we run multiple times, fix it
    content = content.replace('if (!mounted) return;\n      if (!mounted) return;', 'if (!mounted) return;')

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)
