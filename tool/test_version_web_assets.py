import json
from pathlib import Path
import re
import tempfile
import unittest

from version_web_assets import prepare


class WebAssetsTest(unittest.TestCase):
    def test_versioned_loader_and_offline_manifest_remain_consistent(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'main.dart.js').write_bytes(b'example application')
            (root / 'flutter_bootstrap.js').write_text('{"mainJsPath":"main.dart.js"}', encoding='utf-8')
            (root / 'index.html').write_text('<script src="flutter_bootstrap.js" async></script>', encoding='utf-8')
            (root / 'flutter_service_worker.js').write_text('const RESOURCES = {"main.dart.js":"old"};\nconst CORE = ["main.dart.js", "flutter_bootstrap.js"];', encoding='utf-8')
            prepare(root)
            loader_name = re.search(r'src="([^"]+)"', (root / 'index.html').read_text())[1]
            loader = json.loads((root / loader_name).read_text())
            self.assertEqual((root / loader['mainJsPath']).read_bytes(), b'example application')
            worker = (root / 'flutter_service_worker.js').read_text()
            resources = json.loads(re.search(r'const RESOURCES = (.*);', worker)[1])
            core = json.loads(re.search(r'const CORE = (.*);', worker)[1])
            self.assertIn(loader_name, resources)
            self.assertIn(loader['mainJsPath'], resources)
            self.assertIn(loader_name, core)
            self.assertIn(loader['mainJsPath'], core)
            self.assertNotIn('main.dart.js', core)
            self.assertTrue((root / 'main.dart.js').exists())
            first = (root / 'index.html').read_bytes()
            prepare(root)
            self.assertEqual(first, (root / 'index.html').read_bytes())

    def test_changed_app_gets_a_new_url(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'main.dart.js').write_bytes(b'first')
            (root / 'flutter_bootstrap.js').write_text('{"mainJsPath":"main.dart.js"}', encoding='utf-8')
            (root / 'index.html').write_text('<script src="flutter_bootstrap.js"></script>', encoding='utf-8')
            prepare(root)
            first = (root / 'index.html').read_bytes()
            (root / 'main.dart.js').write_bytes(b'second')
            prepare(root)
            self.assertNotEqual(first, (root / 'index.html').read_bytes())

    def test_current_flutter_cleanup_worker_is_preserved(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'main.dart.js').write_bytes(b'app')
            (root / 'flutter_bootstrap.js').write_text('{"mainJsPath":"main.dart.js"}', encoding='utf-8')
            (root / 'index.html').write_text('<script src="flutter_bootstrap.js"></script>', encoding='utf-8')
            worker = 'self.registration.unregister();'
            (root / 'flutter_service_worker.js').write_text(worker, encoding='utf-8')
            prepare(root)
            self.assertEqual((root / 'flutter_service_worker.js').read_text(), worker)

    def test_unsupported_loader_does_not_mutate_build(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'main.dart.js').write_bytes(b'app')
            (root / 'flutter_bootstrap.js').write_text('unsupported', encoding='utf-8')
            (root / 'index.html').write_text('original', encoding='utf-8')
            with self.assertRaises(ValueError):
                prepare(root)
            self.assertEqual((root / 'index.html').read_text(), 'original')
            self.assertEqual(len(list(root.iterdir())), 3)
