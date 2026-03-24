# PotentPowershell

> Peering through the portal of PowerShell,
> Perched a repository, most powerful.
> Packed with scripts of all shapes and sizes,
> Poised to pounce on your admin crises.

A dual-purpose PowerShell repository: an **educational reference** for learning PowerShell deeply, and a **practical toolkit** of real utility scripts.

---

## Repository Structure

```
PotentPowershell/
├── Learn/                          # Annotated learning files (CC BY-SA 3.0)
│   ├── 01-Basics/
│   │   ├── 01-datatypes-and-operators.ps1
│   │   ├── 02-variables-and-collections.ps1
│   │   └── 03-control-flow.ps1
│   ├── 02-Functions/
│   │   └── 01-functions.ps1
│   ├── 03-Modules/
│   │   └── 01-modules.ps1
│   ├── 04-Classes/
│   │   └── 01-classes-and-inheritance.ps1
│   └── 05-Advanced/
│       └── 01-advanced-topics.ps1
│
└── Scripts/                        # Practical utility scripts
    ├── AWS/
    │   ├── Invoke-AwsConfigure.ps1
    │   └── New-AwsAccount.ps1
    ├── Discord/
    │   └── Send-RichEmbed.ps1
    ├── Fun/
    │   └── Get-PiApproximation.ps1
    ├── Gaming/
    │   ├── Start-EDMultiAccount.ps1
    │   └── Invoke-SteamVerification.ps1
    └── Windows/
        ├── Maintenance/
        │   ├── Invoke-SystemUpgrade.ps1
        │   ├── Invoke-DiskCheck.ps1
        │   ├── Get-ErrorReport.ps1
        │   └── Invoke-SfcDism.ps1
        ├── PackageManagers/
        │   ├── Import-ChocolateyPackages.ps1
        │   ├── Update-PythonInstallation.ps1
        │   └── Invoke-ScoopBrowser.ps1
        ├── SafeMode/
        │   ├── Enter-SafeMode.ps1
        │   └── Exit-SafeMode.ps1
        └── Utilities/
            ├── Get-OpenWindows.ps1
            ├── Set-AdminAutoElevate.ps1
            ├── Remove-Silverlight.ps1
            ├── Get-ScreenGeometry.ps1
            ├── Sync-Directories.ps1
            └── Start-MSRewards.ps1
```

---

## Learn/ — Recommended Reading Order

The `Learn/` files are annotated transcriptions of the [LearnXInYMinutes PowerShell guide](https://learnxinyminutes.com/powershell/), with deep commentary on *why* PowerShell works the way it does. Comments explain concepts that seem weird compared to Python, Bash, C#, or JavaScript.

| # | File | Key concepts covered |
|---|------|---------------------|
| 1 | `01-Basics/01-datatypes-and-operators.ps1` | Numbers, Banker's rounding, strings, escape characters, booleans, comparison operators (`-eq`, `-lt`), logical operators (`-and`, `-or`) |
| 2 | `01-Basics/02-variables-and-collections.ps1` | The `$` sigil, fixed-size arrays, ArrayList, hashtables, ordered hashtables, splatting, tuples |
| 3 | `01-Basics/03-control-flow.ps1` | if/elseif/else, switch (no fall-through!), foreach vs ForEach-Object, try/catch/finally, `-ErrorAction Stop` |
| 4 | `02-Functions/01-functions.ps1` | Parameters, implicit return, `[CmdletBinding()]`, BEGIN/PROCESS/END blocks, ValidateSet, splatting |
| 5 | `03-Modules/01-modules.ps1` | Install-Module vs Chocolatey/Scoop, PSGallery, writing modules, dot-sourcing |
| 6 | `04-Classes/01-classes-and-inheritance.ps1` | `::new()` vs `New-Object`, inheritance, `$this`, static members, enums, flags |
| 7 | `05-Advanced/01-advanced-topics.ps1` | Pipeline objects vs text (Bash comparison), jobs, PSRemoting, `&` vs `Invoke-Expression`, execution policy |

### Things explained in unusual depth

- **Banker's rounding** — why `[Math]::Round(2.5)` returns `2`, not `3`
- **Fixed-size arrays** — why `+=` is O(n²) and when to use ArrayList instead
- **Tuples** — what immutability actually gives you (safety, intent, thread-safety)
- **`$` sigil** — where it comes from (Unix shell heritage)
- **`-eq` on arrays** — why it filters instead of comparing
- **`-and`/`-or` instead of `&&`/`||`** — why the shell reserved those symbols
- **Backtick escape** — why not backslash (Windows paths)
- **`[CmdletBinding()]`** — every common parameter you get for free
- **BEGIN/PROCESS/END** — why without PROCESS you only get the last pipeline item
- **`&` vs `Invoke-Expression`** — scope difference and why iex is dangerous
- **Pipeline objects vs Bash text** — the single biggest conceptual shift

---

## Scripts/ — Quick Reference

### Windows Maintenance
| Script | What it does |
|--------|-------------|
| `Invoke-SystemUpgrade.ps1` | SFC + DISM (background) + Chocolatey upgrade + pip upgrade + Windows Update |
| `Invoke-DiskCheck.ps1` | Runs `chkdsk C: /f /r` (auto-elevates) |
| `Get-ErrorReport.ps1` | 7-day Application/System event log error summary |
| `Invoke-SfcDism.ps1` | Reference for all SFC and DISM repair commands |

### Package Managers
| Script | What it does |
|--------|-------------|
| `Import-ChocolateyPackages.ps1` | Finds existing software with Chocolatey packages and brings it under management |
| `Update-PythonInstallation.ps1` | Upgrades Python, removes old versions, upgrades pip, cleans venvs |
| `Invoke-ScoopBrowser.ps1` | Interactive Scoop package browser with background installs |

### Safe Mode
| Script | What it does |
|--------|-------------|
| `Enter-SafeMode.ps1` | Sets `bcdedit` safe mode flag and reboots (Safe Mode with Networking) |
| `Exit-SafeMode.ps1` | Clears safe mode flag (run before rebooting to return to normal) |

### Utilities
| Script | What it does |
|--------|-------------|
| `Get-OpenWindows.ps1` | Lists all processes with visible windows + their titles |
| `Set-AdminAutoElevate.ps1` | Adds auto-elevation to PowerShell profile |
| `Remove-Silverlight.ps1` | Fully removes Microsoft Silverlight (EOL Oct 2021) |
| `Get-ScreenGeometry.ps1` | Reports bounds + working area for all connected monitors |
| `Sync-Directories.ps1` | Robocopy-based directory sync with 64-thread parallel copy |
| `Start-MSRewards.ps1` | Opens Edge to search clicker for Microsoft Rewards points |

### AWS
| Script | What it does |
|--------|-------------|
| `Invoke-AwsConfigure.ps1` | Interactive AWS CLI setup with credential reuse and region selection |
| `New-AwsAccount.ps1` | Full AWS account hardening checklist (IAM, MFA, billing, CloudTrail, SSO) |

### Gaming
| Script | What it does |
|--------|-------------|
| `Start-EDMultiAccount.ps1` | Launches multiple Elite Dangerous accounts via Sandboxie |
| `Invoke-SteamVerification.ps1` | Forces Steam to verify all installed game files |

### Fun
| Script | What it does |
|--------|-------------|
| `Get-PiApproximation.ps1` | Approximates Pi via the Leibniz formula |

### Discord
| Script | What it does |
|--------|-------------|
| `Send-RichEmbed.ps1` | Posts a rich embed message to a Discord channel via webhook |

---

## Quick Start

```powershell
# Run any script directly (some require admin)
.\Scripts\Windows\Maintenance\Invoke-SystemUpgrade.ps1

# Get help for any script
Get-Help .\Scripts\Windows\Utilities\Sync-Directories.ps1 -Full

# Open a Learn file in VS Code
code .\Learn\01-Basics\01-datatypes-and-operators.ps1
```

---

## Attribution

**Learn/ files** are based on the [LearnXInYMinutes PowerShell guide](https://learnxinyminutes.com/powershell/)
by Wouter Van Schandevijl and Andrew Ryan Davis, licensed under
[Creative Commons Attribution-ShareAlike 3.0 Unported](https://creativecommons.org/licenses/by-sa/3.0/).
Annotations and commentary by Quadstronaut.

**Scripts/** are original work by Quadstronaut unless otherwise noted in individual file headers.

---

## Resources

- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)
- [LearnXInYMinutes — PowerShell](https://learnxinyminutes.com/powershell/)
- [PowerShell Gallery](https://www.powershellgallery.com/)
- [Approved Verbs for PowerShell Commands](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)
