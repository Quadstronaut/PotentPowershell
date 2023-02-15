# Scans system files and repairs corrupted files, if possible.
sfc /scannow

# Verifies the integrity of system files without repairing them.
sfc /verifyonly

# Scans an individual file and repairs it, if possible.
sfc /scanfile=C:\Windows\System32\calc.exe

# Scans an offline Windows installation and repairs the specified file, if possible.
sfc /offwindir=C:\Win /offbootdir=C:\Win /scanfile=C:\Win\System32\calc.exe

# Scans and repairs the Windows image, downloading necessary files from Windows Update if required.
dism /online /cleanup-image /restorehealth

# Cleans up the WinSxS folder, removing unnecessary files to free up space.
dism /online /cleanup-image /startcomponentcleanup

# Combines the functionality of /startcomponentcleanup with /resetbase to reduce the size of the WinSxS folder even further.
dism /online /cleanup-image /startcomponentcleanup /resetbase

# Analyzes the component store and reports the size of the WinSxS folder and how much space it can free up.
dism /online /cleanup-image /analyzecomponentstore

# Lists all installed packages and their states.
dism /online /get-packages