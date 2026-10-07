#!/usr/bin/env python3
"""Fail-closed checks for Vibe Habits App Store releases.

The script is intentionally read-only except for its local validation report.
It never contacts Apple and never reads the App Store Connect private key.
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import plistlib
import re
import struct
import subprocess
import tempfile
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PROJECT = ROOT / "habits tracker.xcodeproj" / "project.pbxproj"
APP_IDENTIFIER = "app.vibehabits.ios"
WIDGET_IDENTIFIER = "app.vibehabits.ios.widget"
APPLE_TEAM_ID = "SB6QYUH97U"
LOCALES = ("en-US", "pt-BR")
RELEASE_FACTS = (
    "physicalDeviceValidated",
    "coreFlowsValidated",
    "permissionsValidated",
    "privacyDeclarationsReviewed",
    "storeMetadataComplete",
    "reviewInformationComplete",
    "regionalBehaviorConfirmed",
    "contentRightsConfirmed",
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source(expected_version: str) -> None:
    text = PROJECT.read_text()
    require(re.fullmatch(r"\d+\.\d+\.\d+", expected_version) is not None,
            "Release version must use MAJOR.MINOR.PATCH")
    for value, label in (
        (APP_IDENTIFIER, "app bundle identifier"),
        (WIDGET_IDENTIFIER, "widget bundle identifier"),
        (APPLE_TEAM_ID, "Apple team"),
    ):
        require(value in text, f"Unexpected {label}")
    versions = set(re.findall(r"MARKETING_VERSION = ([0-9]+\.[0-9]+\.[0-9]+);", text))
    require(expected_version in versions,
            f"Project does not declare marketing version {expected_version}")


def png_dimensions_and_color(path: Path) -> tuple[int, int, int]:
    raw = path.read_bytes()
    require(raw[:8] == b"\x89PNG\r\n\x1a\n", f"Screenshot is not PNG: {path}")
    width, height = struct.unpack(">II", raw[16:24])
    color_type = raw[25]
    require(color_type in (0, 2), f"Screenshot must be opaque RGB/grayscale: {path}")
    offset = 8
    while offset < len(raw):
        length = struct.unpack(">I", raw[offset:offset + 4])[0]
        require(raw[offset + 4:offset + 8] != b"tRNS",
                f"Screenshot contains transparency: {path}")
        offset += length + 12
    return width, height, color_type


def listing() -> None:
    limits = {
        "name": 30,
        "subtitle": 30,
        "keywords": 100,
        "description": 4000,
        "promotional_text": 170,
    }
    valid_sizes = {(1320, 2868), (2064, 2752)}
    for locale in LOCALES:
        metadata = ROOT / "fastlane" / "metadata" / locale
        for field, maximum in limits.items():
            value = (metadata / f"{field}.txt").read_text().strip()
            require(0 < len(value) <= maximum,
                    f"Invalid metadata length: {locale}/{field}")
        for field in ("support_url", "privacy_url", "marketing_url"):
            value = (metadata / f"{field}.txt").read_text().strip()
            require(value.startswith("https://"), f"Missing HTTPS URL: {locale}/{field}")

        screenshots = sorted((ROOT / "fastlane" / "screenshots" / locale).glob("*.png"))
        require(len(screenshots) == 10, f"Expected 10 screenshots for {locale}")
        iphone = [path for path in screenshots if "iPhone-6.9" in path.name]
        ipad = [path for path in screenshots if "iPad-13" in path.name]
        require(len(iphone) == 5 and len(ipad) == 5,
                f"Expected five iPhone and five iPad screenshots for {locale}")
        for path in screenshots:
            width, height, _ = png_dimensions_and_color(path)
            require((width, height) in valid_sizes,
                    f"Unsupported screenshot dimensions {width}x{height}: {path}")

    notes = (ROOT / "fastlane" / "metadata" / "review_information" / "notes.txt").read_text()
    for section in (
        "APP PURPOSE, AUDIENCE, AND VALUE",
        "ACCESS AND REVIEW STEPS",
        "EXTERNAL SERVICES",
        "REGIONAL AVAILABILITY",
        "REGULATED INDUSTRIES AND THIRD-PARTY MATERIAL",
    ):
        require(section in notes, f"App Review notes are incomplete: {section}")


def decode_profile(path: Path) -> dict:
    result = subprocess.run(
        ["security", "cms", "-D", "-i", str(path)],
        check=True,
        capture_output=True,
    )
    return plistlib.loads(result.stdout)


def validate_bundle(bundle: Path, identifier: str, version: str, build: str) -> dict:
    info = plistlib.loads((bundle / "Info.plist").read_bytes())
    require(info.get("CFBundleIdentifier") == identifier, f"Wrong signed bundle: {identifier}")
    require(info.get("CFBundleShortVersionString") == version,
            f"Wrong signed version in {identifier}")
    require(str(info.get("CFBundleVersion")) == str(build),
            f"Wrong signed build in {identifier}")

    profile_path = bundle / "embedded.mobileprovision"
    require(profile_path.is_file(), f"Provisioning profile missing from {identifier}")
    profile = decode_profile(profile_path)
    require(APPLE_TEAM_ID in profile.get("TeamIdentifier", []),
            f"Wrong provisioning team in {identifier}")
    expires = profile.get("ExpirationDate")
    require(expires and expires.replace(tzinfo=dt.timezone.utc) > dt.datetime.now(dt.timezone.utc),
            f"Expired provisioning profile in {identifier}")
    require(not profile.get("ProvisionedDevices") and not profile.get("ProvisionsAllDevices"),
            f"App Store distribution profile required for {identifier}")
    entitlements = profile.get("Entitlements", {})
    require(entitlements.get("application-identifier") == f"{APPLE_TEAM_ID}.{identifier}",
            f"Wrong provisioned identifier for {identifier}")
    require(entitlements.get("get-task-allow") is not True,
            f"Debug entitlement present in {identifier}")

    privacy_path = bundle / "PrivacyInfo.xcprivacy"
    require(privacy_path.is_file(), f"Privacy manifest missing from {identifier}")
    privacy = plistlib.loads(privacy_path.read_bytes())
    require(privacy.get("NSPrivacyTracking") is False,
            f"Unexpected tracking declaration in {identifier}")
    require(privacy.get("NSPrivacyCollectedDataTypes") == [],
            f"Unexpected collected-data declaration in {identifier}")
    subprocess.run(
        ["codesign", "--verify", "--deep", "--strict", str(bundle)],
        check=True,
        capture_output=True,
    )
    return {
        "bundle": identifier,
        "version": version,
        "build": str(build),
        "profile": profile.get("Name"),
        "expiration": expires.isoformat(),
    }


def signed_ipa(path: str, version: str, build: str) -> str:
    ipa = Path(path).expanduser().resolve()
    require(ipa.is_file(), "Signed IPA is missing")
    with tempfile.TemporaryDirectory(prefix="vibe-habits-release-") as temp:
        with zipfile.ZipFile(ipa) as archive:
            require(all(not Path(name).is_absolute() and ".." not in Path(name).parts
                        for name in archive.namelist()), "Unsafe IPA archive path")
            archive.extractall(temp)
        apps = list((Path(temp) / "Payload").glob("*.app"))
        require(len(apps) == 1, "Unexpected IPA payload")
        app = apps[0]
        bundles = [validate_bundle(app, APP_IDENTIFIER, version, build)]
        widgets = list((app / "PlugIns").glob("*.appex"))
        require(len(widgets) == 1, "Expected one widget extension")
        bundles.append(validate_bundle(widgets[0], WIDGET_IDENTIFIER, version, build))

    digest = sha256(ipa)
    output = ROOT / "artifacts" / "publication" / "ipa-validation.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps({
        "signature": "verified",
        "version": version,
        "build": str(build),
        "ipa_sha256": digest,
        "ipa_bytes": ipa.stat().st_size,
        "bundles": bundles,
    }, indent=2) + "\n")
    return digest


def submission_evidence(path: str, version: str, build: str, ipa_digest: str) -> None:
    evidence_path = Path(path).expanduser().resolve()
    require(evidence_path.is_file(), "Physical release evidence is missing")
    report = json.loads(evidence_path.read_text())
    require(report.get("version") == version and str(report.get("build")) == str(build),
            "Evidence belongs to another App Store build")
    require(report.get("ipaSha256") == ipa_digest,
            "Evidence belongs to another signed IPA")
    require(bool(report.get("physicalDevice")) and bool(report.get("operatingSystem")),
            "Physical device and operating system are required")
    for fact in RELEASE_FACTS:
        require(report.get(fact) is True, f"Release validation pending: {fact}")
    video_value = report.get("physicalVideo", "")
    video = Path(video_value).expanduser()
    if not video.is_absolute():
        video = ROOT / video
    require(video.is_file(), "Physical validation video is missing")
    require(sha256(video) == report.get("physicalVideoSha256"),
            "Physical validation video changed or its checksum is missing")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", action="store_true")
    parser.add_argument("--listing", action="store_true")
    parser.add_argument("--submission", action="store_true")
    parser.add_argument("--version", required=True)
    parser.add_argument("--build")
    parser.add_argument("--ipa")
    parser.add_argument(
        "--evidence",
        default=str(ROOT / "artifacts" / "publication" / "release-evidence.json"),
    )
    args = parser.parse_args()

    source(args.version)
    if args.listing or args.submission:
        listing()
    digest = None
    if args.ipa:
        require(args.build, "IPA validation requires --build")
        digest = signed_ipa(args.ipa, args.version, args.build)
    if args.submission:
        require(args.build and args.ipa and digest,
                "Submission requires --build and the matching signed --ipa")
        submission_evidence(args.evidence, args.version, args.build, digest)
    print(f"Release preflight passed: {args.version}" + (f" ({args.build})" if args.build else ""))


if __name__ == "__main__":
    main()
