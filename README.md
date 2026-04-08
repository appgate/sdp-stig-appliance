# AppGate ZTNA STIG Customization

## Overview
This repository contains an **Appliance Customization** package used to apply STIG-related configuration to AppGate ZTNA appliances.

Use this customization as part of your STIG compliance workflow for a **seeded appliance**.

## STIG Compliance Workflow (Seeded Appliance)
To make an AppGate ZTNA appliance STIG compliant, complete the following steps:

1. Run `man cz-stig` on the appliance and apply the commands displayed.
2. Download the customization zip from the release or create the customization zip by running `make stig-customization.zip` in the repository root if you configure the customization (see [Repository Customization Notes](https://github.com/appgate/sdp-stig-appliance?tab=readme-ov-file#repository-customization-notes)).
3. Upload the STIG customization from this repository and enable it on the appliance(s) by following the steps below.

## Installing the Customization
1. Sign in to the AppGate Admin UI.
2. Upload the `.zip` package as an **Appliance Customization**.
3. For each appliance where STIG settings must be applied:
   - Edit the appliance configuration.
   - Select this customization under Miscellaneous > Appliance Customization.
   - Save and deploy changes.

## Repository Customization Notes
### Optional Configuration
The customization can be adjusted with `/data/settings.config`:
- Line 2: Expected underlying OS value
- Line 3: Error message text

### Packaging Changes
If you modify the package contents under `src/`, ensure the zip structure is correct.

Required layout:

```text
folder.zip
  start
  status
  stop
  data/...
```

## Tailoring Profile
A SCAP tailoring profile is included to control which findings are selected during scanning.
You can mark findings as "not selected" in the tailoring file to exclude them from checks.

[`CAN_Ubuntu_24-04_STIG001.003.005MAC-2_Public_tailored_tailoring.xml`](./CAN_Ubuntu_24-04_STIG001.003.005MAC-2_Public_tailored_tailoring.xml) is used by internal scans to achieve the advertised score. Please contact an AppGate ZTNA representative to obtain a copy of the attestation that explains the justifications for exclusions specified in this tailoring file.
