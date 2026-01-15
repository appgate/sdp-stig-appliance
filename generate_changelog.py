import re
import json
import requests
from pathlib import Path
from typing import Any

CUSTOMIZATION_START_SCRIPT = "src/start"

STIG_SOURCES = {
    "20.04": {
        "download_url": "https://www.stigviewer.com/stigs/canonical_ubuntu_2004_lts/export/json",
        "base_url": "https://www.stigviewer.com/stigs/canonical_ubuntu_2004_lts",
    },
    "22.04": {
        "download_url": "https://www.stigviewer.com/stigs/canonical_ubuntu_2204_lts/export/json",
        "base_url": "https://www.stigviewer.com/stigs/canonical_ubuntu_2204_lts",
    },
    "24.04": {
        "download_url": "https://www.stigviewer.com/stigs/canonical_ubuntu_2404_lts/export/json",
        "base_url": "https://www.stigviewer.com/stigs/canonical_ubuntu_2404_lts",
    },
}


def extract_stig_ids_from_bash(filepath: str) -> set[str]:
    pattern = re.compile(r"#\s*(V-\d{6})")
    with open(filepath, "r") as f:
        return {match.group(1) for line in f for match in pattern.finditer(line)}


def fetch_stig_json(url: str) -> dict[str, Any]:
    response = requests.get(url)
    response.raise_for_status()
    return response.json()


def generate_markdown(
    stig_ids: set[str], stig_data: dict[str, Any], base_url: str
) -> list[str]:
    lines = []
    # Create a lookup dictionary from the groups array
    findings = {}
    for group in stig_data.get("groups", []):
        findings[group["groupId"]] = {
            "severity": group["ruleSeverity"],
            "title": group["ruleTitle"]
        }

    for stig_id in sorted(stig_ids):
        entry = findings.get(stig_id)
        if not entry:
            continue
        link = f"{base_url}/{stig_id}"
        lines.append(
            f"- [**{stig_id}**]({link}) ({entry['severity']}): {entry['title']}"
        )
    return lines


def main():
    stig_ids = extract_stig_ids_from_bash(CUSTOMIZATION_START_SCRIPT)
    print(f"Found the following STIG IDs in {CUSTOMIZATION_START_SCRIPT}: {stig_ids}")
    all_lines = []
    for version, config in STIG_SOURCES.items():
        print(f"Fetching STIG data for Ubuntu {version} from {config['download_url']}")
        stig_data = fetch_stig_json(config["download_url"])
        matched_ids = {sid for sid in stig_ids if any(group["groupId"] == sid for group in stig_data.get("groups", []))}
        if matched_ids:
            all_lines.extend(
                generate_markdown(matched_ids, stig_data, config["base_url"])
            )
    with open("changelog.md", "w") as f:
        f.write("\n".join(all_lines))
    print("Generated changelog.md")


if __name__ == "__main__":
    main()
