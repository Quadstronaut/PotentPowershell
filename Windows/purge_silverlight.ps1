# Get the Silverlight uninstall command for the current version
$silverlightUninstallCommand = (Get-ChildItem -Path "C:\Program Files (x86)\Microsoft Silverlight\*\Silverlight.Configuration.exe" -ErrorAction SilentlyContinue | Select-Object -Last 1).FullName

if ($silverlightUninstallCommand) {
    # Uninstall Silverlight
    Start-Process -FilePath $silverlightUninstallCommand -ArgumentList "/uninstall /force /silent" -Wait

    # Remove Silverlight from the registry
    Remove-Item "HKLM:\Software\Microsoft\Silverlight" -Recurse -Force
    Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{89F4137D-6C26-4A84-BDB8-2E5A4BB71E00}" -Recurse -Force

    # Remove Silverlight from the file system
    Remove-Item "C:\Program Files (x86)\Microsoft Silverlight" -Recurse -Force
    $slpath = Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)) "Microsoft\Plugins"
    Remove-Item $slpath -Recurse -Force -ErrorAction SilentlyContinue

    Write-Output "Silverlight has been uninstalled from the OS and all browsers."
}
else {
    Write-Output "Silverlight is not installed on this machine."
}
