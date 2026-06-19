#!/usr/bin/env python3
"""
moviebox_pull.py — Copy downloaded MovieBox episodes from Android to your laptop.

Requirements:
  - ADB (Android Debug Bridge) installed on your laptop
  - USB debugging enabled on your phone (Settings → Developer Options → USB debugging)
  - Phone connected via USB (or ADB over Wi-Fi — see --wifi flag)

Usage:
  python moviebox_pull.py                     # interactive mode
  python moviebox_pull.py --dest ~/Videos     # save to a specific folder
  python moviebox_pull.py --wifi 192.168.x.x  # connect over Wi-Fi instead of USB
  python moviebox_pull.py --list              # just list files, don't pull
"""

import subprocess
import sys
import os
import argparse
import shutil
from pathlib import Path

# Known MovieBox / CinemaBox package names (there are many clones)
KNOWN_PACKAGES = [
    "com.cinemax.moviebox",
    "com.moviebox.android",
    "com.cinemabox.moviebox",
    "com.moviebox",
    "com.thebox.moviebox",
    "com.boxmovies.android",
    "com.moviesbox",
    "com.hdmovies.box",
    "com.moviebox.hd",
    "com.cinemax",
]

VIDEO_EXTENSIONS = {".mp4", ".mkv", ".avi", ".mov", ".ts", ".m4v", ".webm", ".flv", ".mpg", ".mpeg"}

# Directories ADB can read without root (external/shared storage)
SEARCH_ROOTS = [
    "/sdcard/Android/data",
    "/sdcard/Android/obb",
    "/sdcard/Movies",
    "/sdcard/Download",
    "/storage/emulated/0/Android/data",
    "/storage/emulated/0/Movies",
    "/storage/emulated/0/Download",
]


def run(cmd, check=True, capture=True):
    result = subprocess.run(cmd, shell=True, capture_output=capture, text=True)
    if check and result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or f"Command failed: {cmd}")
    return result.stdout.strip()


def check_adb():
    if not shutil.which("adb"):
        print(
            "\n[ERROR] 'adb' not found on your PATH.\n"
            "Install it:\n"
            "  macOS:   brew install android-platform-tools\n"
            "  Ubuntu:  sudo apt install adb\n"
            "  Windows: https://developer.android.com/tools/releases/platform-tools\n"
        )
        sys.exit(1)


def get_devices():
    out = run("adb devices")
    lines = [l for l in out.splitlines()[1:] if l.strip() and "offline" not in l]
    return [l.split("\t")[0] for l in lines if "\tdevice" in l]


def adb(serial, cmd, check=True):
    return run(f"adb -s {serial} {cmd}", check=check)


def shell(serial, cmd, check=False):
    result = subprocess.run(
        f"adb -s {serial} shell {cmd}",
        shell=True, capture_output=True, text=True
    )
    return result.stdout.strip(), result.returncode


def detect_package(serial):
    """Try to find which MovieBox package is installed."""
    print("[*] Detecting MovieBox package name…")
    out, _ = shell(serial, "pm list packages")
    installed = set(line.replace("package:", "").strip() for line in out.splitlines())

    for pkg in KNOWN_PACKAGES:
        if pkg in installed:
            print(f"    Found: {pkg}")
            return pkg

    # Fallback: search for anything with 'movie' or 'box' or 'cinema' in the name
    matches = [p for p in installed if any(kw in p.lower() for kw in ("movie", "cinema", "boxmovie", "moviebox"))]
    if matches:
        print(f"    Possible matches: {matches}")
        for m in matches:
            print(f"      {m}")
        return matches[0]

    print("    Could not detect MovieBox package — will search all video files in accessible storage.")
    return None


def find_video_files(serial, package):
    """Search accessible directories for video files."""
    search_dirs = list(SEARCH_ROOTS)

    if package:
        # App-specific external dirs (readable without root)
        search_dirs = [
            f"/sdcard/Android/data/{package}",
            f"/storage/emulated/0/Android/data/{package}",
            f"/sdcard/Android/obb/{package}",
        ] + search_dirs

    print("[*] Scanning for video files (this may take a moment)…")

    found = []
    seen = set()

    for root in search_dirs:
        out, code = shell(serial, f"find '{root}' -type f 2>/dev/null")
        if code != 0 or not out:
            continue
        for line in out.splitlines():
            line = line.strip()
            ext = Path(line).suffix.lower()
            if ext in VIDEO_EXTENSIONS and line not in seen:
                seen.add(line)
                # Get file size
                size_out, _ = shell(serial, f"stat -c '%s' '{line}' 2>/dev/null")
                try:
                    size_bytes = int(size_out)
                except ValueError:
                    size_bytes = 0
                found.append({"path": line, "size": size_bytes})

    return found


def format_size(n):
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024:
            return f"{n:.1f} {unit}"
        n /= 1024
    return f"{n:.1f} TB"


def choose_files(files):
    print(f"\nFound {len(files)} video file(s):\n")
    for i, f in enumerate(files):
        name = Path(f["path"]).name
        print(f"  [{i+1:>2}] {name}  ({format_size(f['size'])})")
        print(f"        {f['path']}")

    print("\nWhich files do you want to pull?")
    print("  Enter numbers separated by commas (e.g. 1,3,5), 'all', or 'q' to quit: ", end="")
    choice = input().strip().lower()

    if choice == "q":
        return []
    if choice == "all":
        return files

    selected = []
    for part in choice.split(","):
        part = part.strip()
        if part.isdigit():
            idx = int(part) - 1
            if 0 <= idx < len(files):
                selected.append(files[idx])
    return selected


def pull_files(serial, files, dest):
    dest = Path(dest).expanduser().resolve()
    dest.mkdir(parents=True, exist_ok=True)
    print(f"\n[*] Saving to: {dest}\n")

    for f in files:
        name = Path(f["path"]).name
        out_path = dest / name
        # Avoid overwriting
        if out_path.exists():
            stem = out_path.stem
            suffix = out_path.suffix
            counter = 1
            while out_path.exists():
                out_path = dest / f"{stem}_{counter}{suffix}"
                counter += 1

        print(f"  Pulling: {name}  ({format_size(f['size'])})")
        try:
            adb(serial, f"pull '{f['path']}' '{out_path}'")
            print(f"    Saved → {out_path}")
        except RuntimeError as e:
            print(f"    [FAIL] {e}")

    print("\n[Done]")


def connect_wifi(ip):
    port = 5555
    if ":" in ip:
        ip, port = ip.rsplit(":", 1)
    print(f"[*] Connecting to {ip}:{port} over Wi-Fi…")
    print("    (Make sure your phone is on the same network and ADB TCP mode is on)")
    out = run(f"adb connect {ip}:{port}", check=False)
    print(f"    {out}")


def main():
    parser = argparse.ArgumentParser(
        description="Pull MovieBox downloaded episodes from Android to your laptop via ADB."
    )
    parser.add_argument("--dest", default="~/Videos/MovieBox", help="Destination folder on your laptop (default: ~/Videos/MovieBox)")
    parser.add_argument("--wifi", metavar="IP[:PORT]", help="Connect to phone over Wi-Fi (e.g. 192.168.1.42)")
    parser.add_argument("--list", action="store_true", help="List found files without pulling")
    parser.add_argument("--package", help="Override app package name (skip auto-detection)")
    args = parser.parse_args()

    check_adb()

    if args.wifi:
        connect_wifi(args.wifi)

    devices = get_devices()
    if not devices:
        print(
            "\n[ERROR] No Android device detected.\n"
            "  1. Connect your phone with a USB cable.\n"
            "  2. Enable USB debugging: Settings → About Phone → tap Build Number 7× → Developer Options → USB Debugging.\n"
            "  3. Accept the 'Allow USB debugging' prompt on your phone.\n"
            "  4. Run this script again.\n"
        )
        sys.exit(1)

    if len(devices) > 1:
        print("Multiple devices found:")
        for i, d in enumerate(devices):
            print(f"  [{i+1}] {d}")
        choice = input("Choose device number: ").strip()
        serial = devices[int(choice) - 1]
    else:
        serial = devices[0]

    print(f"[*] Using device: {serial}\n")

    package = args.package or detect_package(serial)
    files = find_video_files(serial, package)

    if not files:
        print(
            "\n[!] No video files found in accessible storage.\n"
            "\nPossible reasons:\n"
            "  1. MovieBox stores files in private internal storage (/data/data/…) — root is required to access these.\n"
            "  2. The files are encrypted by the app and won't play outside MovieBox even if copied.\n"
            "  3. The package name wasn't detected — try: python moviebox_pull.py --package com.your.package\n"
            "\nTo find the package name manually:\n"
            "  adb shell pm list packages | grep -i movie\n"
        )
        sys.exit(0)

    if args.list:
        print(f"\nFound {len(files)} video file(s):\n")
        for f in files:
            print(f"  {Path(f['path']).name}  ({format_size(f['size'])})")
            print(f"  {f['path']}\n")
        return

    selected = choose_files(files)
    if not selected:
        print("Nothing selected. Exiting.")
        return

    pull_files(serial, selected, args.dest)


if __name__ == "__main__":
    main()
