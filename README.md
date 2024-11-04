# sdp-stig-appliance

## Description:
Written to apply STIG related configuration changes for the Appgate appliances using an [appliance customization](https://sdphelp.appgate.com/adminguide/appliance-customization-configure.html). 

## Usage:
- Navigate to the Appgate admin portal
- Upload the .zip file to as an 'Appliance Cusomtization' 
- For each appliance you wish to apply changes to:
  - Edit appliance definition
  - Select desired customization
  - Save changes

## Configuration:
### Optional Configuration:
- The expected underlying OS defined by line 2 in “/data/settings.config”
- The error message defined by line 3 in “/data/settings.config”
### Changing Package For Your Needs
- Edit contents of [/src](/src/) as desired. [More details here](https://sdphelp.appgate.com/adminguide/adding-3rd-party-executables.html)
- Zip files into a folder, be careful that the zip process does not nest an additional folder within. Mac users must also avoid adding __MACOSX & .DS_STORE files. Required structure is
	<pre><code>
   folder.zip
    start
    status
    stop
    data/..etc..
   </code></pre>
   NOT
   <pre><code>
   folder.zip
     folder
       start
       status
       stop
       data/.etc..
    </code></pre>

## Configuration for offline use
The following instructions are <u>only</u> required when the Appgate appliances do not have Internet connectivity, or when static packages need to be contained within the customization.
### Download packages installed by customization
Base URL for Appliance Customization = https://github.com/appgate/sdp-stig-appliance/tree/main

Look for "apt install" lines in the `start` file.  Each of the packages specified will need to be downloaded before installation and the "apt install" command will need to be modified to reference the local package.

Example:
```bash
# Old
apt install -o DPkg::Options::="--force-confold" -y libpam-pwquality

# New

apt install -o DPkg::Options::="--force-confold" -y /opt/customization/data/libpam-pwquality*deb

```
On an identicial version of the Appgate appliance you are building the customization for, do the following:
1. ssh to the appliance
1. run the following with NO customization installed to download the necessary packages.  You may also want to reboot to ensure a fresh system.
```bash 
sudo apt clean
sudo apt update
sudo apt --download-only install libpam-pwquality
mkdir ~/STIG
cp /var/cache/apt/archives/*.deb ~/STIG/
```
The files in `~/STIG/` can now be scp'd off of the appliance for use in a customization.
```bash
scp cz@635.lab.local:~/STIG/* ./src/data/
```
# Scanning Appgate with DISA SCAP Compliance Checker (SCC)
DISA SCAP (Security Content Automation Protocol) Compliance Checker (SCC) is the tool used for automated scanning of systems for STIG compliance.  This tool is available under the "SCAP TOOLS" heading on [this website](https://public.cyber.mil/stigs/scap/).

DISA SCC requires a remote scanning plugin to scan remoste hosts via ssh.  This tool is available under the "SCAP TOOLS" heading on [this website](https://public.cyber.mil/stigs/scap/), and here is a direct link to the [SCC 5.10 UNIX Remote Scanning Plugin](https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/SCC_5.10_UNIX_Remote_Scanning_Plugin.zip).

DISA SCAP Content refers to the STIG definitions for each operating system or product.  To scan Appgate appliances, use the Ubuntu 20.04 or Ubuntu 22.04 STIG Benchmark available under the "SCAP 1.3 CONTENT" heading on [this website](https://public.cyber.mil/stigs/scap/).

Within SCC's "3. Select Content" section, the "Applicability [x] Run content regardless of applicability" check box will need to be checked because Appgate 6.3.5 is built on Ubuntu 22, but the SCAP 1.3 Benchmark for Ubuntu 22 has not been released as of the writing of this document.  The Ubuntu 20.04 STIG Benchmark will be used for now and this document will be updated when the SCAP 1.3 Benchmark for Ubuntu 22.04 is released.

## Appgate Appliance Configuration for Scanning
Appgate appliances throttle ssh and do not include the required ecdsa ssh host key by default.  These settings will need to be changed manually via the Appgate Admin UI and ssh prior to scanning the appliance. 

### Allow SSH to appliance
SSH will need to be enabled and configured to allow incoming ssh requests from the scanner's IP address.  These settings are configured via the Appgate Admin UI normally available at https://controllerIP:8443
```
Admin UI -> System -> Appliances -> [select appliance] -> System Settings (tab) 
  -> [x] SSH Server
  -> SSH Allowed Sources: [IP of your SCAP scanner]
```

### Disable SSH throttling on the Appgate appliance
NOTE: all manual changes via ssh will revert to Appgate default values after reboot.
```bash
sudo iptables -F SSHBRUTE
sudo iptables -A SSHBRUTE -j ACCEPT
```

### Configure ecdsa ssh host key
NOTE: all manual changes via ssh will revert to Appgate default values after reboot.
```bash
sudo ssh-keygen -A
sudo sed -i "/HostKey.*/a HostKey /etc/ssh/ssh_host_ecdsa_key" /etc/ssh/sshd_config
sudo systemctl restart sshd
```
