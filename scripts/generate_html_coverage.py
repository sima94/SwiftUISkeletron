#!/usr/bin/env python3
"""
generate_html_coverage.py — Unified HTML coverage report.

Sources:
  - SwiftUISkeletron.app : merged xcresult (unit tests + UI tests)
  - Infuse, NetworkRelay, FormValidator : swift test --enable-code-coverage

Usage (via Makefile):
  python3 scripts/generate_html_coverage.py \
      --xcresult DerivedData/MergedResults.xcresult \
      --output   coverage-html \
      --packages Infuse NetworkRelay FormValidator
"""

import argparse
import html
import json
import os
import subprocess
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def run(cmd, cwd=None):
    r = subprocess.run(cmd, capture_output=True, text=True, cwd=cwd)
    return r.stdout


def xccov_json(xcresult):
    out = run(["xcrun", "xccov", "view", "--report", "--json", xcresult])
    return json.loads(out)


def xccov_file_lines(file_path, xcresult):
    """Return dict {line_number: hit_count | None}  (None = not executable)."""
    out = run(["xcrun", "xccov", "view", "--file", file_path, "--archive", xcresult])
    result = {}
    for raw in out.splitlines():
        parts = raw.split("|", 2)
        if len(parts) < 3:
            continue
        ln = parts[0].strip()
        cnt = parts[1].strip()
        if not ln.isdigit():
            continue
        result[int(ln)] = int(cnt) if cnt.isdigit() else None
    return result


def llvm_cov_lines(file_path, profdata, binary):
    """Return dict {line_number: hit_count | None} via llvm-cov."""
    out = run([
        "xcrun", "llvm-cov", "show",
        "--format=text",
        f"--instr-profile={profdata}",
        binary,
        file_path,
    ])
    result = {}
    for raw in out.splitlines():
        parts = raw.split("|", 2)
        if len(parts) < 3:
            continue
        ln = parts[0].strip()
        cnt = parts[1].strip()
        if not ln.isdigit():
            continue
        result[int(ln)] = int(cnt) if cnt.isdigit() else None
    return result


def read_package_json_summary(pkg_dir, pkg_name):
    """Read per-file summary from llvm-cov JSON (swift test output)."""
    cov_path = os.path.join(pkg_dir, ".build", "debug", "codecov", f"{pkg_name}.json")
    if not os.path.isfile(cov_path):
        return []
    with open(cov_path) as f:
        data = json.load(f)
    entries = []
    for fe in data.get("data", [{}])[0].get("files", []):
        path = fe.get("filename", "")
        if "/Tests/" in path or "runner.swift" in path:
            continue
        s = fe.get("summary", {}).get("lines", {})
        entries.append({
            "path": path,
            "coverage": s.get("percent", 0) / 100.0,
            "covered": s.get("covered", 0),
            "executable": s.get("count", 0),
        })
    return entries


def find_package_binary(pkg_dir):
    """Find the .xctest binary produced by swift test."""
    base = os.path.join(pkg_dir, ".build", "arm64-apple-macosx", "debug")
    for entry in os.listdir(base) if os.path.isdir(base) else []:
        if entry.endswith("PackageTests.xctest"):
            bin_path = os.path.join(base, entry, "Contents", "MacOS",
                                    entry.replace(".xctest", ""))
            if os.path.isfile(bin_path):
                return bin_path
    return None


# ---------------------------------------------------------------------------
# HTML generation
# ---------------------------------------------------------------------------

_CSS = """
body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;
     font-size:13px;margin:0;background:#1e1e1e;color:#d4d4d4}
a{color:#4fc3f7;text-decoration:none}a:hover{text-decoration:underline}
.hdr{background:#252526;padding:14px 20px;border-bottom:1px solid #3e3e42}
.hdr h1{margin:0 0 2px;font-size:18px}
.hdr .sub{color:#9e9e9e;font-size:12px}
.pbar{height:6px;background:#3e3e42;border-radius:3px;margin-top:8px}
.pfill{height:100%;border-radius:3px}
table{width:100%;border-collapse:collapse}
th{background:#2d2d30;padding:7px 12px;text-align:left;
   border-bottom:1px solid #3e3e42;position:sticky;top:0;font-weight:600}
td{padding:5px 12px;border-bottom:1px solid #252526}
tr:hover td{background:#2a2d2e}
.pct{font-weight:700;width:64px}
.lines{width:80px;color:#858585}
.barcell{width:140px}
.bg{height:10px;background:#3e3e42;border-radius:5px}
.fg{height:100%;border-radius:5px}
.grp th{background:#1a3a2a;color:#9cdcb0;font-size:11px;letter-spacing:.05em;
        text-transform:uppercase;padding:4px 12px}
/* File view */
.fhdr{background:#252526;padding:12px 20px;border-bottom:1px solid #3e3e42;
      position:sticky;top:0}
.fhdr h2{margin:0 0 2px;font-size:15px;font-family:monospace}
.fhdr .stats{color:#9e9e9e;font-size:12px}
.back{font-size:12px;margin-bottom:6px;display:block}
.src-table{width:100%;border-collapse:collapse;font-family:'SF Mono',monospace;font-size:12px}
.src-table tr.hit  td{background:#162116}
.src-table tr.miss td{background:#2b1414}
.src-table tr:hover td{filter:brightness(1.25)}
td.ln{width:44px;text-align:right;padding:0 6px;color:#636363;
      border-right:1px solid #2d2d30;user-select:none}
td.ct{width:52px;text-align:center}
td.code{padding:0 8px}
pre{margin:0;white-space:pre-wrap;word-break:break-all}
.badge{font-size:10px;padding:1px 5px;border-radius:8px}
.badge.h{background:#1b3d1b;color:#4ec9b0}
.badge.m{background:#4b1515;color:#f44747}
"""


def _color(pct):
    if pct >= 80:
        return "#4ec9b0"
    if pct >= 50:
        return "#dcdcaa"
    return "#f44747"


def _progress_html(pct, height=6):
    c = _color(pct)
    return (f'<div class="pbar" style="height:{height}px">'
            f'<div class="pfill" style="width:{pct:.1f}%;background:{c}"></div></div>')


def generate_file_page(fname, fpath, summary, line_data, output_dir):
    pct = summary["coverage"] * 100
    covered = summary["covered"]
    executable = summary["executable"]
    c = _color(pct)

    try:
        with open(fpath, encoding="utf-8", errors="replace") as f:
            src_lines = f.readlines()
    except OSError:
        src_lines = []

    rows = []
    for i, src in enumerate(src_lines, 1):
        cnt = line_data.get(i)
        esc = html.escape(src.rstrip("\n"))
        if cnt is None:
            cls, badge = "", ""
        elif cnt == 0:
            cls = ' class="miss"'
            badge = '<span class="badge m">0</span>'
        else:
            cls = ' class="hit"'
            badge = f'<span class="badge h">{cnt}</span>'
        rows.append(
            f'<tr{cls}>'
            f'<td class="ln">{i}</td>'
            f'<td class="ct">{badge}</td>'
            f'<td class="code"><pre>{esc}</pre></td>'
            f'</tr>'
        )

    page = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8">
<title>Coverage — {html.escape(fname)}</title>
<style>{_CSS}</style></head><body>
<div class="fhdr">
  <a href="index.html" class="back">← Coverage Report</a>
  <h2>{html.escape(fname)}</h2>
  <div class="stats">{covered}/{executable} lines &nbsp;·&nbsp;
    <span style="color:{c};font-weight:700">{pct:.1f}%</span></div>
  {_progress_html(pct, 5)}
</div>
<table class="src-table">{''.join(rows)}</table>
</body></html>"""

    out = os.path.join(output_dir, fname + ".html")
    with open(out, "w") as f:
        f.write(page)


def generate_index(groups, output_dir):
    """groups = list of (group_name, [entry_dict])"""
    total_cov = sum(e["covered"] for _, entries in groups for e in entries)
    total_exec = sum(e["executable"] for _, entries in groups for e in entries)
    total_pct = (total_cov / total_exec * 100) if total_exec else 0.0
    tc = _color(total_pct)

    sections = []
    for gname, entries in groups:
        g_cov = sum(e["covered"] for e in entries)
        g_exec = sum(e["executable"] for e in entries)
        g_pct = (g_cov / g_exec * 100) if g_exec else 0.0
        gc = _color(g_pct)

        rows = []
        for e in sorted(entries, key=lambda x: x["coverage"]):
            p = e["coverage"] * 100
            c = _color(p)
            rows.append(
                f'<tr>'
                f'<td><a href="{html.escape(e["html_file"])}">'
                f'{html.escape(e["display"])}</a></td>'
                f'<td class="pct" style="color:{c}">{p:.1f}%</td>'
                f'<td class="lines">{e["covered"]}/{e["executable"]}</td>'
                f'<td class="barcell">'
                f'<div class="bg"><div class="fg" style="width:{p:.1f}%;background:{c}"></div></div>'
                f'</td></tr>'
            )

        sections.append(
            f'<tr class="grp"><th colspan="4">'
            f'{html.escape(gname)} &nbsp;'
            f'<span style="color:{gc};font-weight:700">{g_pct:.1f}%</span>'
            f' ({g_cov}/{g_exec})'
            f'</th></tr>'
            + "".join(rows)
        )

    page = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8">
<title>Coverage Report — SwiftUISkeletron</title>
<style>{_CSS}</style></head><body>
<div class="hdr">
  <h1>Code Coverage Report</h1>
  <div class="sub">SwiftUISkeletron · Unit Tests + UI Tests + Package Tests</div>
  <div style="margin-top:6px;font-size:22px;font-weight:700;color:{tc}">{total_pct:.1f}%</div>
  <div class="sub">{total_cov}/{total_exec} executable lines covered</div>
  {_progress_html(total_pct, 8)}
</div>
<table>
<thead><tr>
  <th>File</th><th>Coverage</th><th>Lines</th><th>Distribution</th>
</tr></thead>
<tbody>{''.join(sections)}</tbody>
</table>
</body></html>"""

    with open(os.path.join(output_dir, "index.html"), "w") as f:
        f.write(page)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--xcresult", required=True, help="Path to MergedResults.xcresult")
    ap.add_argument("--output", default="coverage-html")
    ap.add_argument("--packages", nargs="*", default=[],
                    help="Paths to local SPM package dirs (Infuse NetworkRelay FormValidator)")
    ap.add_argument("--project-root", default=".", help="Repo root for relative display paths")
    args = ap.parse_args()

    root = os.path.abspath(args.project_root)
    os.makedirs(args.output, exist_ok=True)

    # ------------------------------------------------------------------
    # 1. App sources from xcresult (merged unit + UI test coverage)
    # ------------------------------------------------------------------
    print(f"Reading xcresult: {args.xcresult}")
    cov = xccov_json(args.xcresult)

    app_entries = []
    for target in cov.get("targets", []):
        tname = target.get("name", "")
        if tname.endswith(".xctest"):
            continue  # skip test bundles
        # Skip SPM packages here — we'll use direct swift-test coverage below
        is_spm = not tname.endswith(".app")

        for fe in target.get("files", []):
            fpath = fe.get("path", "")
            fname = os.path.basename(fpath)
            if not os.path.isfile(fpath) or fe.get("executableLines", 0) == 0:
                continue

            summary = {
                "coverage": fe.get("lineCoverage", 0),
                "covered": fe.get("coveredLines", 0),
                "executable": fe.get("executableLines", 0),
            }

            print(f"  [{tname}] {fname}  {summary['coverage']*100:.0f}%")
            line_data = xccov_file_lines(fpath, args.xcresult)
            generate_file_page(fname, fpath, summary, line_data, args.output)

            app_entries.append({
                "display": os.path.relpath(fpath, root),
                "html_file": fname + ".html",
                **summary,
            })

    # ------------------------------------------------------------------
    # 2. Local SPM packages from swift test coverage
    # ------------------------------------------------------------------
    pkg_groups = []
    for pkg_dir in (args.packages or []):
        pkg_dir = os.path.abspath(pkg_dir)
        pkg_name = os.path.basename(pkg_dir)
        print(f"\nReading package: {pkg_name}")

        profdata = os.path.join(pkg_dir, ".build", "debug", "codecov", "default.profdata")
        binary = find_package_binary(pkg_dir)
        files = read_package_json_summary(pkg_dir, pkg_name)

        if not files:
            print(f"  (no coverage data — run: cd {pkg_name} && swift test --enable-code-coverage)")
            continue

        pkg_entries = []
        for fe in files:
            fpath = fe["path"]
            fname = os.path.basename(fpath)
            if not os.path.isfile(fpath):
                continue

            line_data = {}
            if os.path.isfile(profdata) and binary and os.path.isfile(binary):
                line_data = llvm_cov_lines(fpath, profdata, binary)

            print(f"  {fname}  {fe['coverage']*100:.0f}%")
            generate_file_page(fname, fpath, fe, line_data, args.output)

            pkg_entries.append({
                "display": os.path.relpath(fpath, root),
                "html_file": fname + ".html",
                **fe,
            })

        if pkg_entries:
            pkg_groups.append((pkg_name, pkg_entries))

    # ------------------------------------------------------------------
    # 3. Build grouped index
    # ------------------------------------------------------------------
    # Split app entries by target prefix
    app_files = [e for e in app_entries if e["display"].startswith("SwiftUISkeletron/")]
    fmv_files = [e for e in app_entries if "FormValidator/" in e["display"]]
    nr_files  = [e for e in app_entries if "NetworkRelay/" in e["display"]]
    other_app = [e for e in app_entries
                 if e not in app_files and e not in fmv_files and e not in nr_files]

    groups = [("SwiftUISkeletron.app  (Unit + UI Tests)", app_files + other_app)]
    for gname, entries in pkg_groups:
        groups.append((f"{gname}  (Package Tests)", entries))

    generate_index(groups, args.output)

    total_files = sum(len(e) for _, e in groups)
    print(f"\n✅  HTML report: {args.output}/index.html  ({total_files} files)")


if __name__ == "__main__":
    main()
