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