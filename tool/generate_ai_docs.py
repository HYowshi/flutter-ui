"""Generate source-signature docs and a readable AI bundle; no third-party deps.

This is a bounded extractor for this repository's formatted Dart declarations,
not a Dart type resolver. CI detects stale output. Source is the final authority.
"""
from __future__ import annotations

import argparse
import hashlib
import html
from pathlib import Path
import re
import shutil
import sys
import textwrap

ROOT = Path(__file__).resolve().parents[1]
SITE = "https://hyowshi.github.io/flutter-ui"
GITHUB = "https://github.com/HYowshi/flutter-ui/blob/main"
GUIDES = [
    "ai-guide.md", "api-reference.md", "ai-cookbook.md", "consumer-agents.md",
    "forms-feedback.vi.md", "images.vi.md", "wireframe.vi.md",
    "customization.vi.md", "states-dialog-date.vi.md", "motion-input-notice.vi.md",
]
RECIPES = [
    "example/lib/customization_example.dart",
    "example/lib/recipes/auth_recipe.dart",
    "example/lib/recipes/editor_recipe.dart",
]


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig").replace("\r\n", "\n")


def mask_non_code(source: str) -> str:
    """Preserve offsets/newlines while skipping comments and Dart strings."""
    chars = list(source)
    i = 0
    while i < len(source):
        start = i
        if source.startswith("//", i):
            i = source.find("\n", i)
            if i < 0:
                i = len(source)
        elif source.startswith("/*", i):
            i += 2
            depth = 1
            while i < len(source) and depth:
                if source.startswith("/*", i):
                    depth += 1
                    i += 2
                elif source.startswith("*/", i):
                    depth -= 1
                    i += 2
                else:
                    i += 1
        elif source[i] in "\"'":
            raw = i > 0 and source[i - 1] == "r"
            quote = source[i] * (3 if source.startswith(source[i] * 3, i) else 1)
            i += len(quote)
            while i < len(source):
                if not raw and source[i] == "\\":
                    i += 2
                elif source.startswith(quote, i):
                    i += len(quote)
                    break
                else:
                    i += 1
        else:
            i += 1
            continue
        for j in range(start, min(i, len(chars))):
            if chars[j] != "\n":
                chars[j] = " "
    return "".join(chars)


def balanced_end(code: str, start: int, left: str, right: str) -> int:
    depth = 0
    for index in range(start, len(code)):
        if code[index] == left:
            depth += 1
        elif code[index] == right:
            depth -= 1
            if depth == 0:
                return index + 1
    raise ValueError(f"Unbalanced {left} at offset {start}")


def exported_units() -> list[Path]:
    visited: set[Path] = set()
    def visit(path: Path) -> None:
        path = path.resolve()
        if path in visited:
            return
        if not path.is_relative_to(ROOT / "lib"):
            raise ValueError(f"Export/part leaves lib: {path}")
        visited.add(path)
        for target in re.findall(r"^(?:export|part)\s+'([^']+)';", read(path), re.M):
            visit(path.parent / target)
    visit(ROOT / "lib/youth_ui.dart")
    return sorted(visited)


def signature_blocks(path: Path) -> list[tuple[str, str]]:
    source = read(path)
    code = mask_non_code(source)
    result = []
    declarations = re.finditer(
        r"^(?:(?:abstract|final|base|sealed|interface)\s+)*(class|enum|extension)\s+(\w+)",
        code, re.M,
    )
    for match in declarations:
        kind, name = match.groups()
        if name.startswith("_"):
            continue
        opening = code.index("{", match.end())
        ending = balanced_end(code, opening, "{", "}")
        if kind == "enum":
            result.append((name, source[match.start():ending].strip()))
            continue
        header = source[match.start():opening].strip()
        body = code[opening + 1:ending - 1]
        members = []
        for line in re.finditer(r"^  \S[^\n]*", body, re.M):
            relative = line.start()
            prefix = body[:relative]
            if prefix.count("{") != prefix.count("}"):
                continue
            start = opening + 1 + relative + 2
            text = code[start:opening + 1 + line.end()]
            if text.startswith(("@", "//", "}", ")")):
                continue
            ctor = re.match(rf"(?:const\s+|factory\s+)?{name}(?:\.([\w]+))?\s*\(", text)
            if ctor:
                if ctor.group(1) and ctor.group(1).startswith("_"):
                    continue
                paren = code.index("(", start)
                stop = balanced_end(code, paren, "(", ")")
                members.append(textwrap.dedent("  " + source[start:stop]).strip() + ";")
                continue
            # Fields reveal types for this.field constructor parameters.
            if re.match(r"(?:(?:static|late|final|const)\s+)+", text):
                semi = code.find(";", start, ending)
                arrow = code.find("=>", start, ending)
                paren = code.find("(", start, ending)
                if semi >= 0 and ("final " in text or "const " in text):
                    declaration = source[start:semi + 1]
                    names = re.findall(r"\b_\w+\b", mask_non_code(declaration))
                    # Private storage isn't an integration API.
                    if names or " final _" in " " + declaration:
                        continue
                    members.append(textwrap.dedent("  " + declaration).strip())
                    continue
            # Public methods/getters, excluding Flutter protocol overrides.
            getter = re.match(r"(?:static\s+)?[\w<>?, ]+\s+get\s+(\w+)\b", text)
            method = re.match(r"(?:static\s+)?[\w<>?, ()]+?\s+(\w+)(?:<[^\n]*?>)?\s*\(", text)
            candidate = getter or method
            if not candidate:
                continue
            member_name = candidate.group(1)
            if member_name.startswith("_") or member_name in {
                "build", "createState", "dispose", "copyWith", "lerp", "updateShouldNotify",
            }:
                continue
            if getter:
                stop = min(p for p in (code.find("=>", start), code.find("{", start)) if p >= 0)
            else:
                paren = code.index("(", start)
                stop = balanced_end(code, paren, "(", ")")
            members.append(textwrap.dedent("  " + source[start:stop]).strip() + ";")
        if not members:
            members = ["// No explicit public constructor/method declared here; see source."]
        result.append((name, header + " {\n" + "\n\n".join(textwrap.indent(m, "  ") for m in members) + "\n}"))
    return result


def render_api(version: str) -> str:
    units = exported_units()
    fingerprint = hashlib.sha256()
    for path in [ROOT / "pubspec.yaml", *units]:
        fingerprint.update(path.relative_to(ROOT).as_posix().encode())
        fingerprint.update(read(path).encode())
    sections = []
    for path in units:
        relative = path.relative_to(ROOT).as_posix()
        for name, declarations in signature_blocks(path):
            sections.append(f"## {name}\n\n[Source: {relative}]({GITHUB}/{relative})\n\n```dart\n{declarations}\n```\n")
    if not sections:
        raise ValueError("No public API extracted")
    toc = "\n".join(f"- [{title}](#{title.lower()})" for title in re.findall(r"^## (\w+)$", "\n".join(sections), re.M))
    return f"""# youth_ui API reference

Generated for **{version}** from the public export/part graph of lib/youth_ui.dart.
Source fingerprint: `{fingerprint.hexdigest()}`.

Do not edit manually. Run `python tool/generate_ai_docs.py`; CI checks drift.
These are source-derived declaration excerpts: explicit constructors/defaults,
public field types, and public methods/getters declared by this package. Constructor
initializer assertions, implementation bodies, inherited members, top-level helpers
and routine Flutter protocol overrides are omitted. This is not a Dart type resolver
or a replacement for source/dartdoc. If extraction cannot express a new syntax,
update the extractor or consult source; do not infer missing APIs.

`this.x` gets its type from the field declarations below. Imports are omitted for
compactness; consumer import is `package:youth_ui/youth_ui.dart` plus Flutter imports.
For integration constraints, limits and ownership see [AI guide](ai-guide.md) and
its linked detailed guides. Do not copy a declaration as an executable example.

{toc}

""" + "\n".join(sections)


def render_bundle(version: str, api: str) -> str:
    sections = [f"# youth_ui {version}: AI full-text documentation\n\nGenerated bundle; individual source/guide files remain authoritative.\n"]
    for guide in GUIDES:
        content = api if guide == "api-reference.md" else read(ROOT / "docs" / guide)
        sections.append(f"\n---\n\nSource: {GITHUB}/docs/{guide}\n\n{content}")
    for recipe in RECIPES:
        sections.append(f"\n---\n\nRunnable source: {GITHUB}/{recipe}\n\n```dart\n{read(ROOT / recipe)}```\n")
    return "\n".join(sections)


def publish(destination: Path) -> None:
    if not destination.is_dir():
        raise ValueError("Publish destination must already exist (web build output)")
    if destination.resolve() == ROOT or destination.resolve() == ROOT / "docs":
        raise ValueError("Refusing to publish into source root/docs")
    directory = destination / "ai"
    directory.mkdir(exist_ok=True)
    for name in ("llms.txt", "llms-full.txt"):
        shutil.copyfile(ROOT / name, destination / name)
    for guide in GUIDES:
        shutil.copyfile(ROOT / "docs" / guide, directory / guide)
    for recipe in RECIPES:
        shutil.copyfile(ROOT / recipe, directory / Path(recipe).name)
    links = "\n".join(f'<li><a href="{html.escape(name)}">{html.escape(name)}</a></li>' for name in ["../llms.txt", "../llms-full.txt", *GUIDES, *(Path(r).name for r in RECIPES)])
    prompt = "Dự án dùng youth_ui từ HYowshi/flutter-ui. Đọc https://hyowshi.github.io/flutter-ui/llms.txt và ai-guide trước khi viết UI. Kiểm tra phiên bản trong pubspec.lock, ưu tiên component có sẵn và giữ router/state/theme hiện tại."
    page = f"""<!doctype html><html lang="vi"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Flutter UI — tài liệu cho AI</title>
<style>body{{font:17px/1.65 system-ui,sans-serif;max-width:780px;margin:48px auto;padding:0 24px;color:#172b45;background:#f8faff}}a{{color:#155bb4}}h1{{line-height:1.2}}pre{{white-space:pre-wrap;background:#e8eef9;padding:24px;border-radius:16px}}li{{margin:9px 0}}</style>
<main><a href="../">← Component Studio</a><h1>Flutter UI · tài liệu cho AI</h1>
<p>Bắt đầu từ <a href="../llms.txt">llms.txt</a>. AI đọc được tài liệu này trực tiếp, không cần chạy giao diện Flutter.</p>
<h2>Prompt dùng trong dự án khác</h2><pre>{html.escape(prompt)}</pre>
<p>Tài liệu đi kèm API và ví dụ chạy được. Hãy đối chiếu phiên bản dependency đã cài; không phải AI nào cũng tự đọc llms.txt.</p>
<h2>Tài liệu và mã nguồn mẫu</h2><ul>{links}</ul></main></html>"""
    (directory / "index.html").write_text(page, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Fail if generated docs are stale")
    parser.add_argument("--publish", type=Path, help="Copy readable files into an existing web build")
    args = parser.parse_args()
    version = re.search(r"^version:\s*(\S+)", read(ROOT / "pubspec.yaml"), re.M).group(1)
    for path in (ROOT / "llms.txt", ROOT / "docs/ai-guide.md"):
        if version not in read(path):
            raise ValueError(f"Update documented version in {path.relative_to(ROOT)}")
    api = render_api(version)
    output = {ROOT / "docs/api-reference.md": api, ROOT / "llms-full.txt": render_bundle(version, api)}
    stale = []
    for path, content in output.items():
        if args.check:
            if not path.exists() or read(path) != content:
                stale.append(path.relative_to(ROOT).as_posix())
        else:
            path.write_text(content, encoding="utf-8")
    if stale:
        print("Stale documentation: " + ", ".join(stale), file=sys.stderr)
        return 1
    if args.publish:
        publish(args.publish)
    print("AI documentation verified" if args.check else "AI documentation generated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
