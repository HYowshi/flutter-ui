"""Regression checks for extraction/publishing, using only Python's stdlib."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location("generate_ai_docs", Path(__file__).with_name("generate_ai_docs.py"))
DOCS = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(DOCS)


class AiDocsTests(unittest.TestCase):
    def test_signatures_skip_bodies_private_initializers_comments_and_string_braces(self):
        source = """// class NotAClass { }
class Demo<T> {
  const Demo({this.text = 'literal } (', this.onChange}) : _private = 'init';
  factory Demo.named({required T value}) => throw UnimplementedError();
  final String text;
  final void Function(Map<String, int>)? onChange;
  final String _private;
  static Future<T?> pick<T>({String title = 'not ) a delimiter'}) async {
    return null;
  }
  void _hidden() {}
  Widget build(BuildContext context) => throw UnimplementedError();
}
enum Choice { one, two }
"""
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "fixture.dart"
            path.write_text(source, encoding="utf-8")
            output = dict(DOCS.signature_blocks(path))
        self.assertEqual(set(output), {"Demo", "Choice"})
        self.assertIn("const Demo({this.text = 'literal } (', this.onChange});", output["Demo"])
        self.assertIn("factory Demo.named({required T value});", output["Demo"])
        self.assertIn("static Future<T?> pick<T>({String title = 'not ) a delimiter'});", output["Demo"])
        self.assertIn("final void Function(Map<String, int>)? onChange;", output["Demo"])
        for excluded in ["_private", "_hidden", "build(", "return null", "UnimplementedError"]:
            self.assertNotIn(excluded, output["Demo"])

    def test_real_export_graph_includes_parts_and_factory_defaults(self):
        units = DOCS.exported_units()
        paths = {p.relative_to(DOCS.ROOT).as_posix() for p in units}
        self.assertIn("lib/src/date_field.dart", paths)
        self.assertIn("lib/src/select.dart", paths)
        self.assertIn("lib/src/wireframe_inference.dart", paths)
        self.assertNotIn("lib/src/search_text.dart", paths)
        blocks = dict(block for path in units for block in DOCS.signature_blocks(path))
        self.assertIn("const UIImage.provider(", blocks["UIImage"])
        self.assertIn("factory UITextField.search(", blocks["UITextField"])
        self.assertIn("factory UIWireframe.auto(", blocks["UIWireframe"])
        self.assertIn("static Future<bool> confirm(", blocks["UIAdaptiveDialog"])
        self.assertIn("static Future<DateTimeRange?> range(", blocks["UIDatePicker"])
        self.assertIn("this.pageSize = 10", blocks["UITable"])
        self.assertIn("Future<bool> submit();", blocks["UIFormController"])

    def test_published_files_are_exact_readable_copies(self):
        with tempfile.TemporaryDirectory() as temporary:
            destination = Path(temporary)
            DOCS.publish(destination)
            self.assertEqual(DOCS.read(destination / "llms.txt"), DOCS.read(DOCS.ROOT / "llms.txt"))
            for guide in DOCS.GUIDES:
                self.assertEqual(DOCS.read(destination / "ai" / guide), DOCS.read(DOCS.ROOT / "docs" / guide))
            for recipe in DOCS.RECIPES:
                self.assertEqual(DOCS.read(destination / "ai" / Path(recipe).name), DOCS.read(DOCS.ROOT / recipe))
            page = DOCS.read(destination / "ai/index.html")
            self.assertIn('href="../llms-full.txt"', page)
            self.assertIn('href="ai-guide.md"', page)


if __name__ == "__main__":
    unittest.main()
