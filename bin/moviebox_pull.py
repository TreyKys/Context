#!/usr/bin/env python3
"""
moviebox_pull.py — Copy downloaded MovieBox episodes from Android to your laptop.

Requirements:
  - Linux environment enabled on your Chromebook (Settings → Advanced → Developers → Linux)
  - ADB installed in Linux:  sudo apt update && sudo apt install adb python3
  - Phone and Chromebook on the same Wi-Fi network

Chromebook quick-start (Wi-Fi, recommended):
  1. On your phone: Settings → About Phone → tap Build Number 7×
  2. Developer Options → enable Wireless Debugging
  3. Tap "Pair device with pairing code" — note the IP:port and 6-digit code
  4. In your Linux terminal:
       python3 moviebox_pull.py --pair 192.168.x.x:PORT
     Enter the 6-digit code when prompted.
  5. Back in Wireless Debugging, note the IP:port shown on the MAIN screen (different port).
       python3 moviebox_pull.py --wifi 192.168.x.x:PORT

Usage:
  python3 moviebox_pull.py --pair IP:PORT     # one-time pairing (Android 11+)
  python3 moviebox_pull.py --wifi IP:PORT     # connect after pairing
  python3 moviebox_pull.py --list             # list found files without pulling
  python3 moviebox_pull.py --dest ~/Videos    # save to a specific folder
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


def connect_wifi(addr):
    """Connect to a previously paired device."""
    if ":" not in addr:
        addr = f"{addr}:5555"
    print(f"[*] Connecting to {addr} over Wi-Fi…")
    out = run(f"adb connect {addr}", check=False)
    print(f"    {out}")


def pair_device(addr):
    """Android 11+ wireless pairing flow using a one-time pairing code."""
    if ":" not in addr:
        print("[ERROR] --pair requires IP:PORT (e.g. 192.168.1.5:37489)")
        sys.exit(1)
    print(f"[*] Pairing with {addr}…")
    print("    Enter the 6-digit code shown on your phone: ", end="", flush=True)
    code = input().strip()
    result = subprocess.run(
        f"adb pair {addr} {code}",
        shell=True, capture_output=True, text=True
    )
    output = (result.stdout + result.stderr).strip()
    print(f"    {output}")
    if result.returncode != 0 or "failed" in output.lower():
        print(
            "\n[HINT] Pairing failed. Make sure:\n"
            "  • Phone and Chromebook are on the same Wi-Fi network\n"
            "  • You used the port from 'Pair device with pairing code' (not the main Wireless Debugging port)\n"
            "  • The 6-digit code is current (it refreshes every time you open that screen)\n"
        )
        sys.exit(1)
    print("\n[OK] Paired! Now run with --wifi using the IP:PORT from the main Wireless Debugging screen.")


def main():
    parser = argparse.ArgumentParser(
        description="Pull MovieBox downloaded episodes from Android to your laptop via ADB."
    )
    parser.add_argument("--dest", default="~/Videos/MovieBox", help="Destination folder (default: ~/Videos/MovieBox)")
    parser.add_argument("--wifi", metavar="IP:PORT", help="Connect to phone over Wi-Fi after pairing")
    parser.add_argument("--pair", metavar="IP:PORT", help="One-time Wi-Fi pairing (Android 11+) — run this first")
    parser.add_argument("--list", action="store_true", help="List found files without pulling")
    parser.add_argument("--package", help="Override app package name (skip auto-detection)")
    args = parser.parse_args()

    check_adb()

    if args.pair:
        pair_device(args.pair)
        sys.exit(0)

    if args.wifi:
        connect_wifi(args.wifi)

    devices = get_devices()
    if not devices:
        print(
            "\n[ERROR] No Android device detected.\n"
            "\nOn a Chromebook, Wi-Fi is the most reliable method:\n"
            "  1. Phone: Settings → About Phone → tap Build Number 7×\n"
            "  2. Phone: Developer Options → Wireless Debugging → enable it\n"
            "  3. Phone: tap 'Pair device with pairing code' — note the IP:PORT and 6-digit code\n"
            "  4. Chromebook Linux terminal:\n"
            "       python3 moviebox_pull.py --pair 192.168.x.x:PAIR_PORT\n"
            "  5. Enter the 6-digit code when prompted\n"
            "  6. Back on phone: note the IP:PORT on the MAIN Wireless Debugging screen\n"
            "  7. Chromebook Linux terminal:\n"
            "       python3 moviebox_pull.py --wifi 192.168.x.x:CONNECT_PORT\n"
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
