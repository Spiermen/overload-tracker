#!/usr/bin/env python3
import sys, pathlib
try:
    import yaml
except ImportError:
    # minimal structural checks without PyYAML
    yaml = None

root = pathlib.Path(__file__).resolve().parents[1]
wf = root / ".github/workflows/ios-testflight.yml"
text = wf.read_text()
required = ["macos-14", "ASC_KEY_ID", "fastlane", "npx cap sync ios", "npm run verify", "workflow_dispatch"]
missing = [r for r in required if r not in text]
if missing:
    print("FAIL: workflow missing", missing); sys.exit(1)
if "ASC_KEY_P8" not in text:
    print("FAIL: ASC_KEY_P8 secret not referenced"); sys.exit(1)
# basic YAML parse if available
if yaml:
    data = yaml.safe_load(text)
    assert "jobs" in data and "build" in data["jobs"]
print("PASS: ios-testflight.yml looks sane")

# web sync + no shop links
import subprocess
subprocess.check_call(["bash", str(root / "scripts/sync-www.sh")])
www = (root / "www/index.html").read_text()
assert "DadStrong" in www
assert "soypapawear" not in www
assert (root / "www/native-bridge.js").exists()
assert (root / "ios/App/App.xcodeproj/project.pbxproj").exists()
assert (root / "plugins/dadstrong-bridge/ios/Sources/DadStrongBridgePlugin/DadStrongBridgePlugin.swift").exists()
print("PASS: www sync + ios project + bridge present")
