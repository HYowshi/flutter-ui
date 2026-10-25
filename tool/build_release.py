"""Build clean ZIP/TAR.GZ archives from a committed youth_ui checkout."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
ROOT_FILES = {"pubspec.yaml", "README.md", "LICENSE", "CHANGELOG.md",
              "analysis_options.yaml", "AGENTS.md", "llms.txt", "llms-full.txt", ".pubignore"}
DIRECTORIES = {"lib", "docs", "example", "test", "tool"}
FORBIDDEN = {".git", ".dart_tool", "build", "coverage", ".idea", ".vscode", "__pycache__", "dist", ".release"}


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def selected(name):
    path = PurePosixPath(name)
    if path.is_absolute() or ".." in path.parts or any(p in FORBIDDEN for p in path.parts):
        return False
    if path.suffix in {".log", ".pyc", ".iml", ".ipr", ".iws", ".swp"}:
        return False
    if path.name in {".metadata", ".gitignore", "pubspec.lock"}:
        return False
    return name in ROOT_FILES or path.parts[0] in DIRECTORIES


def verify(files, prefix):
    manifest = json.loads(files[f"{prefix}/release.json"])
    expected = {f"{prefix}/{name}" for name in manifest["files"]} | {f"{prefix}/release.json"}
    if set(files) != expected:
        raise ValueError("Archive manifest/file list mismatch")
    for name, digest in manifest["files"].items():
        if not selected(name) or hashlib.sha256(files[f"{prefix}/{name}"]).hexdigest() != digest:
            raise ValueError(f"Unexpected or corrupt file: {name}")
    return manifest


def build(output):
    if git("status", "--porcelain", "--untracked-files=normal").strip():
        raise ValueError("Commit source changes before building a distributable")
    head = git("rev-parse", "HEAD").decode().strip()
    content = git("show", "HEAD:pubspec.yaml").decode()
    version = re.search(r"^version:\s*(\S+)", content, re.M).group(1)
    if not re.fullmatch(r"\d+\.\d+\.\d+(?:-[a-zA-Z0-9.-]+)?", version):
        raise ValueError("Unexpected release version")
    prefix = f"youth_ui-{version}"
    names = sorted(n for n in git("ls-tree", "-r", "--name-only", "HEAD").decode().splitlines() if selected(n))
    files = {}
    for name in names:
        # Read committed blobs, not potentially modified/generated working files.
        mode = git("ls-tree", "HEAD", "--", name).decode().split()[0]
        if mode not in {"100644", "100755"}:
            raise ValueError(f"Unsupported entry: {name}")
        files[f"{prefix}/{name}"] = git("show", f"HEAD:{name}")
    if not all(f"{prefix}/{required}" in files for required in ["LICENSE", "pubspec.yaml", "lib/youth_ui.dart", "README.md"]):
        raise ValueError("Missing required package files")
    manifest = {"name": "youth_ui", "version": version, "commit": head,
                "license": "MIT", "files": {name[len(prefix)+1:]: hashlib.sha256(data).hexdigest() for name, data in files.items()}}
    if not files[f"{prefix}/LICENSE"].startswith(b"MIT License"):
        raise ValueError("Expected the approved MIT license")
    files[f"{prefix}/release.json"] = (json.dumps(manifest, indent=2, ensure_ascii=False) + "\n").encode()
    output.mkdir(parents=True, exist_ok=True)
    zip_path = output / f"{prefix}.zip"
    tar_path = output / f"{prefix}.tar.gz"
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for name, data in files.items():
            entry = zipfile.ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
            entry.external_attr = 0o100644 << 16
            archive.writestr(entry, data, compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
    with tar_path.open("wb") as raw:
        with gzip.GzipFile(filename="", mode="wb", fileobj=raw, mtime=0) as compressed:
            with tarfile.open(fileobj=compressed, mode="w") as archive:
                for name, data in files.items():
                    entry = tarfile.TarInfo(name)
                    entry.size, entry.mode, entry.mtime = len(data), 0o644, 0
                    archive.addfile(entry, io.BytesIO(data))
    with zipfile.ZipFile(zip_path) as archive:
        zipped = {name: archive.read(name) for name in archive.namelist()}
    with tarfile.open(tar_path) as archive:
        tarred = {entry.name: archive.extractfile(entry).read() for entry in archive.getmembers() if entry.isfile()}
    verify(zipped, prefix)
    verify(tarred, prefix)
    if zipped != tarred:
        raise ValueError("ZIP and TAR.GZ contents differ")
    sums = "".join(f"{hashlib.sha256(path.read_bytes()).hexdigest()}  {path.name}\n" for path in [zip_path, tar_path])
    (output / "SHA256SUMS.txt").write_text(sums, encoding="utf-8")
    print(json.dumps({"version": version, "commit": head, "files": len(files),
                      "archives": [{"path": str(p.resolve()), "bytes": p.stat().st_size} for p in [zip_path, tar_path]]}, indent=2))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "dist")
    build(parser.parse_args().output)
