"""Give showcase entry assets content-based URLs, including offline cache entries."""
import hashlib
import json
from pathlib import Path
import re
import sys


def prepare(root: Path) -> None:
    main = (root / 'main.dart.js').read_bytes()
    bootstrap = (root / 'flutter_bootstrap.js').read_text(encoding='utf-8')
    index = (root / 'index.html').read_text(encoding='utf-8')
    main_name = f'main.{hashlib.sha256(main).hexdigest()[:16]}.dart.js'
    bootstrap, count = re.subn(
        r'("mainJsPath"\s*:\s*)"main.dart.js"',
        lambda match: match[1] + json.dumps(main_name), bootstrap,
    )
    if count != 1:
        raise ValueError('Expected one dart2js entry in Flutter bootstrap')
    bootstrap_bytes = bootstrap.encode('utf-8')
    bootstrap_name = f'flutter_bootstrap.{hashlib.sha256(bootstrap_bytes).hexdigest()[:16]}.js'
    index, count = re.subn(
        r'(src=")flutter_bootstrap(?:\.[0-9a-f]{16})?\.js(")',
        lambda match: match[1] + bootstrap_name + match[2], index,
    )
    if count != 1:
        raise ValueError('Expected one bootstrap script in index.html')
    index_bytes = index.encode('utf-8')
    worker_path = root / 'flutter_service_worker.js'
    worker = None
    if worker_path.exists():
        worker = worker_path.read_text(encoding='utf-8')
        match = re.search(r'const RESOURCES = (\{.*?\});', worker, re.S)
        if match is None and 'self.registration.unregister()' not in worker:
            raise ValueError('Unsupported Flutter offline resource manifest')
        if match is not None:
            resources = json.loads(match[1])
            for name, content in [(main_name, main), (bootstrap_name, bootstrap_bytes),
                                  ('index.html', index_bytes), ('/', index_bytes)]:
                resources[name] = hashlib.md5(content, usedforsecurity=False).hexdigest()
            worker = worker[:match.start(1)] + json.dumps(resources) + worker[match.end(1):]
            core = re.search(r'const CORE = (\[.*?\]);', worker, re.S)
            if core is not None:
                aliases = {'main.dart.js': main_name, 'flutter_bootstrap.js': bootstrap_name}
                entries = [aliases.get(name, name) for name in json.loads(core[1])]
                worker = worker[:core.start(1)] + json.dumps(entries) + worker[core.end(1):]
    # Keep original aliases available for clients already running the old loader.
    (root / main_name).write_bytes(main)
    (root / bootstrap_name).write_bytes(bootstrap_bytes)
    (root / 'index.html').write_bytes(index_bytes)
    if worker is not None:
        worker_path.write_text(worker, encoding='utf-8')


if __name__ == '__main__':
    prepare(Path(sys.argv[1]))
