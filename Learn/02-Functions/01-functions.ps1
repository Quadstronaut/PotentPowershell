<#
.SYNOPSIS
    PowerShell functions — from basic to advanced — annotated.

.DESCRIPTION
    Covers simple functions, parameter declarations, CmdletBinding, BEGIN/PROCESS/END
    pipeline blocks, return values, and ValidateSet. Deep commentary on WHY each
    feature exists and what it unlocks.

.NOTES
    Source : LearnXInYMinutes — PowerShell
             https://learnxinyminutes.com/powershell/
             Authors : Wouter Van Schandevijl, Andrew Ryan Davis
             License : Creative Commons Attribution-ShareAlike 3.0 Unported
                       https://creativecommons.org/licenses/by-sa/3.0/
    Annotations : Quadstronaut
#>

# ============================================================
# BASIC FUNCTIONS
# ============================================================

function Greet {
    Write-Host "Hello!"
}
Greet   # Call with no parentheses (unlike C#/Python/JavaScript)

# WHY no parentheses for calling functions?
# PowerShell uses shell-style invocation: command arg1 arg2 (space-separated).
# Parentheses in PowerShell mean "evaluate this expression," not "call this function."
# Greet()  # This works BUT creates an empty array argument — avoid it for PS functions.

# ============================================================
# PARAMETERS
# ============================================================

function Greet-Person {
    param(
        [string]$Name = "World",   # default value
        [int]$Times   = 1
    )
    for ($i = 0; $i -lt $Times; $i++) {
        Write-Host "Hello, $Name!"
    }
}

Greet-Person                        # Hello, World!
Greet-Person -Name "Alice"          # Hello, Alice!
Greet-Person -Name "Bob" -Times 3   # Hello, Bob! (x3)

# Mandatory parameters:
function Get-Greeting {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    return "Hello, $Name!"
}

# ============================================================
# RETURN VALUES — Implicit and explicit
# ============================================================

# WHY does PowerShell have "implicit return"?
# Any value that isn't captured or piped is automatically placed on the output stream.
# This is intentional — it makes pipeline-centric code natural. You don't have to
# explicitly return from every code path; any unconsumed output becomes the return value.

function Get-Square {
    param([int]$n)
    $n * $n    # Not captured → goes to output stream → becomes the return value
}
$result = Get-Square 5    # $result = 25

# Explicit return works too and also exits the function:
function Get-AbsoluteValue {
    param([double]$n)
    if ($n -lt 0) { return -$n }
    return $n
}

# GOTCHA: Write-Host does NOT go to the output stream.
# It writes directly to the console (the "information" stream, host).
# This means you can't capture Write-Host output with $var = FunctionName.
# Use Write-Output (or just bare values) when you want capturable output.
function Bad-Return  { Write-Host "42" }    # not capturable
function Good-Return { Write-Output "42" }  # capturable
function Also-Good   { "42" }               # also capturable — bare string

# ============================================================
# CMDLETBINDING — Upgrading to an Advanced Function
# ============================================================

# Adding [CmdletBinding()] to a function turns it into an "advanced function."
# This grants it all the common parameters that built-in cmdlets have, for free:
#   -Verbose    : enable verbose output (Write-Verbose messages appear)
#   -Debug      : enable debug output (Write-Debug messages appear, with prompts)
#   -WhatIf     : simulate the command without executing it
#   -Confirm    : prompt before executing
#   -ErrorAction, -WarningAction, -InformationAction, -OutVariable, etc.
#
# WHY is this important? Because your scripts now behave like built-in cmdlets.
# Users already know how to use -Verbose and -WhatIf. You get that UX for free.

function Set-UserStatus {
    [CmdletBinding(SupportsShouldProcess = $true)]  # enables -WhatIf and -Confirm
    param(
        [Parameter(Mandatory = $true)]
        [string]$Username,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Active", "Inactive", "Suspended")]  # only these values accepted
        [string]$Status
    )

    # $PSCmdlet.ShouldProcess is the -WhatIf check.
    # If -WhatIf is passed, ShouldProcess returns $false and prints "What if: ..."
    # If -Confirm is passed, it prompts the user before returning $true.
    if ($PSCmdlet.ShouldProcess("$Username", "Set status to $Status")) {
        Write-Verbose "Setting $Username to $Status..."   # only shows with -Verbose
        Write-Host "Done: $Username is now $Status"
    }
}

# Usage:
# Set-UserStatus -Username "alice" -Status "Active"
# Set-UserStatus -Username "alice" -Status "Active" -WhatIf
# Set-UserStatus -Username "alice" -Status "Active" -Verbose
# Set-UserStatus -Username "alice" -Status "Oops"   # error: not in ValidateSet

# ============================================================
# BEGIN / PROCESS / END BLOCKS — Pipeline-aware functions
# ============================================================

# When a function accepts pipeline input, you need BEGIN/PROCESS/END blocks.
# Without them, $_ only contains the LAST item piped in — everything else is lost.
#
# WHY? The pipeline streams objects one at a time. PROCESS runs once per object.
# BEGIN runs once before streaming starts (setup). END runs once after (teardown).

function Measure-StringLength {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$InputString
    )

    BEGIN {
        Write-Verbose "Starting length measurements..."
        $total = 0    # initialize accumulator before any pipeline items arrive
    }

    PROCESS {
        # $InputString is populated fresh for EACH piped object here
        $len = $InputString.Length
        Write-Output ([PSCustomObject]@{
            String = $InputString
            Length = $len
        })
        $total += $len
    }

    END {
        Write-Verbose "Total characters processed: $total"
    }
}

# Pipeline usage:
"hello", "world", "PowerShell" | Measure-StringLength -Verbose

# Without BEGIN/PROCESS/END — WRONG:
function Bad-Pipeline {
    param([Parameter(ValueFromPipeline=$true)][string]$s)
    Write-Host $s    # only prints the LAST item piped in
}
"a","b","c" | Bad-Pipeline   # prints "c" only!

# ============================================================
# PARAMETER VALIDATION ATTRIBUTES
# ============================================================

function Set-Volume {
    [CmdletBinding()]
    param(
        [ValidateRange(0, 100)]
        [int]$Level,

        [ValidatePattern('^\d{3}-\d{4}$')]   # regex validation
        [string]$PhoneNumber,

        [ValidateNotNullOrEmpty()]
        [string]$Label,

        [ValidateScript({ Test-Path $_ })]   # custom validation — must be a real path
        [string]$LogPath
    )
    # ...
}

# ============================================================
# SPLATTING PARAMETERS IN FUNCTION CALLS
# ============================================================

# Build up parameters dynamically, then splat them:
$params = @{
    Username = "alice"
    Status   = "Active"
    Verbose  = $true
}
Set-UserStatus @params   # same as: Set-UserStatus -Username "alice" -Status "Active" -Verbose

# WHY splat instead of building a long command string?
# 1. No injection risk — values are passed as objects, not parsed as text.
# 2. Conditionally add parameters:
if ($debug) { $params["Debug"] = $true }
Set-UserStatus @params
