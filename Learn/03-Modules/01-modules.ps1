<#
.SYNOPSIS
    PowerShell modules — importing, installing, creating — annotated.

.DESCRIPTION
    Covers the module system, PSGallery, Install-Module vs package managers,
    and how to write your own module.

.NOTES
    Source : LearnXInYMinutes — PowerShell
             https://learnxinyminutes.com/powershell/
             Authors : Wouter Van Schandevijl, Andrew Ryan Davis
             License : Creative Commons Attribution-ShareAlike 3.0 Unported
                       https://creativecommons.org/licenses/by-sa/3.0/
    Annotations : Quadstronaut
#>

# ============================================================
# WHAT IS A MODULE?
# ============================================================

# A module is a packaged collection of PowerShell functions, cmdlets, variables,
# and aliases that can be loaded into any session with Import-Module.
# Modules are the primary way to share and reuse PowerShell code.

# Module types:
# - Script Module   (.psm1) — a .ps1-like file that uses Export-ModuleMember
# - Binary Module   (.dll)  — compiled C# code exposing cmdlets
# - Manifest Module (.psd1) — a descriptor that bundles other modules together
# - Dynamic Module          — created in-memory with New-Module

# ============================================================
# FINDING AND INSTALLING MODULES
# ============================================================

# PSGallery is the official public repository (like PyPI for Python, npm for JS).
# Trust it explicitly before installing:
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Search for modules:
Find-Module -Name "*azure*"
Find-Module -Tag "ActiveDirectory"

# Install a module (requires admin or -Scope CurrentUser):
Install-Module -Name Pester          # test framework
Install-Module -Name PSReadLine      # enhanced line editing
Install-Module -Name Az              # Azure management (Microsoft official)

# Install for current user only (no admin required):
Install-Module -Name ImportExcel -Scope CurrentUser

# WHY use Install-Module vs Chocolatey/Scoop/winget for PowerShell modules?
#
# Install-Module (PowerShellGet):
#   - Purpose-built for PowerShell modules
#   - Puts modules in $env:PSModulePath so Import-Module finds them automatically
#   - Understands module versioning, dependencies, and PSGallery metadata
#   - Best choice for PowerShell-specific tooling
#
# Chocolatey / Scoop / winget:
#   - General-purpose Windows package managers
#   - Better for apps, executables, system tools (git, nodejs, vscode, etc.)
#   - Can install some PowerShell modules but doesn't integrate with PSModulePath
#   - Best choice for non-PowerShell software
#
# Rule of thumb: PS modules → Install-Module; Everything else → Chocolatey/Scoop/winget

# ============================================================
# USING MODULES
# ============================================================

# List all loaded modules:
Get-Module

# List all available (installed but not yet loaded) modules:
Get-Module -ListAvailable

# Import a module into the current session:
Import-Module -Name Pester

# Auto-loading: PowerShell 3+ auto-imports modules when you first call a cmdlet from them.
# You rarely need explicit Import-Module unless you need specific version control.

# Import a specific version:
Import-Module -Name Az -RequiredVersion "9.0.0"

# Remove a module from the current session:
Remove-Module -Name Pester

# ============================================================
# MODULE PATHS
# ============================================================

# PowerShell looks for modules in $env:PSModulePath (colon-separated on Linux, semi on Windows):
$env:PSModulePath -split [System.IO.Path]::PathSeparator

# Common locations:
# Current User: $HOME\Documents\WindowsPowerShell\Modules  (or ~/Documents/PowerShell/Modules on PS7)
# All Users:    C:\Program Files\WindowsPowerShell\Modules
# System:       C:\Windows\System32\WindowsPowerShell\v1.0\Modules

# ============================================================
# WRITING A SIMPLE MODULE
# ============================================================

# A script module is just a .psm1 file. Functions defined in it are private by default.
# Use Export-ModuleMember to make them public.

# Example: Save this as MyUtils.psm1

function Get-Greeting {
    param([string]$Name = "World")
    return "Hello, $Name!"
}

function Private-Helper {
    # This function will NOT be exported — internal use only
    Write-Verbose "Internal helper called"
}

# Export only the public functions:
Export-ModuleMember -Function Get-Greeting

# Or export everything (not recommended — exposes internals):
# Export-ModuleMember -Function *

# ============================================================
# MODULE MANIFESTS (.psd1)
# ============================================================

# A manifest describes your module: version, author, dependencies, exported items.
# Create one with New-ModuleManifest:
New-ModuleManifest `
    -Path ".\MyUtils.psd1" `
    -RootModule "MyUtils.psm1" `
    -ModuleVersion "1.0.0" `
    -Author "Quadstronaut" `
    -Description "Utility functions" `
    -PowerShellVersion "5.1"

# ============================================================
# USING MODULES FROM A LOCAL PATH
# ============================================================

# Import directly by path (useful during development):
Import-Module "C:\Projects\MyUtils\MyUtils.psm1" -Force   # -Force reloads if already imported

# Dot-source a .ps1 file (loads functions into current scope, not as a formal module):
. "C:\Scripts\helpers.ps1"

# WHY dot-source vs Import-Module?
# Import-Module creates an isolated module scope — functions defined inside don't
# pollute the calling scope and can be versioned/managed.
# Dot-sourcing literally injects the file's code into the current scope, like
# copy-pasting it. Simpler for small personal scripts, messy at scale.

# ============================================================
# CHECKING MODULE VERSION AND INFO
# ============================================================

Get-Module -Name Pester | Select-Object Name, Version, Path
Get-Command -Module Pester   # list all exported commands from a module
