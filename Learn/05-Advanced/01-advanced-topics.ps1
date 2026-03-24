<#
.SYNOPSIS
    PowerShell advanced topics — pipeline internals, jobs, remoting, execution policy.

.DESCRIPTION
    Covers pipeline object model (vs Bash text), background jobs, PSRemoting,
    the & call operator vs Invoke-Expression, dot-sourcing, and execution policy levels.

.NOTES
    Source : LearnXInYMinutes — PowerShell
             https://learnxinyminutes.com/powershell/
             Authors : Wouter Van Schandevijl, Andrew Ryan Davis
             License : Creative Commons Attribution-ShareAlike 3.0 Unported
                       https://creativecommons.org/licenses/by-sa/3.0/
    Annotations : Quadstronaut
#>

# ============================================================
# THE PIPELINE — OBJECTS, NOT TEXT
# ============================================================

# This is the single most important concept that separates PowerShell from Bash.
#
# BASH pipeline: every command emits a stream of TEXT (bytes). The next command
# receives that text and must PARSE it to extract structured data. This is fragile:
# column widths change, locale affects output, whitespace gets mangled.
#
#   bash: ps aux | awk '{print $11}' | grep firefox   # parse text manually
#
# POWERSHELL pipeline: every command emits .NET OBJECTS with typed properties.
# The next command receives those objects and accesses their properties directly.
# No parsing. No guessing. No locale issues.
#
#   ps: Get-Process | Where-Object Name -eq "firefox" | Select-Object CPU, WorkingSet

# Practical demonstration — get top 5 processes by CPU:
Get-Process |
    Sort-Object CPU -Descending |
    Select-Object -First 5 |
    Format-Table Name, CPU, WorkingSet -AutoSize

# Every object in the pipeline is a [System.Diagnostics.Process].
# You can inspect what properties/methods are available:
Get-Process | Get-Member   # shows all properties and methods

# WHY does this matter for sysadmins?
# Filtering, transforming, and exporting data becomes trivial:
Get-Process | Where-Object { $_.CPU -gt 10 } | Export-Csv "heavy_processes.csv" -NoTypeInformation
# No parsing. The CSV is perfectly structured. You'd need awk+sed+cut to do this in Bash.

# ============================================================
# PIPELINE PERFORMANCE — When NOT to use the pipeline
# ============================================================

# The pipeline is elegant but has overhead. Each object travels through the pipe
# infrastructure (buffering, binding, etc.). For tight loops on large collections,
# a foreach statement is faster.

# SLOW (pipeline overhead):
Measure-Command { 1..100000 | ForEach-Object { $_ * 2 } }

# FAST (no pipeline):
Measure-Command { foreach ($n in 1..100000) { $n * 2 } }

# Use the pipeline for readability and composability.
# Use foreach for performance-critical inner loops.

# ============================================================
# STACKS — Algorithmic data structure example
# ============================================================

# A Stack is LIFO (Last In, First Out). Use it when you need to reverse order
# or process things in the order they were added (backtracking, undo, etc.).

$stack = [System.Collections.Stack]::new()

# Push: add to top
$stack.Push("first")
$stack.Push("second")
$stack.Push("third")

# Pop: remove from top (LIFO order)
$stack.Pop()    # third
$stack.Pop()    # second
$stack.Pop()    # first

# Practical use: reverse a collection
$items = @(1, 2, 3, 4, 5)
$reversed = [System.Collections.Stack]::new()
foreach ($item in $items) { $reversed.Push($item) }
while ($reversed.Count -gt 0) { $reversed.Pop() }   # 5,4,3,2,1

# ============================================================
# CALL OPERATOR & vs INVOKE-EXPRESSION — Critical difference
# ============================================================

# & (call operator) — invoke a command or script in a CHILD scope.
# The child scope inherits variables from the parent but cannot modify them.
# This is the SAFE way to invoke external commands and scripts.

$scriptPath = "C:\Scripts\MyScript.ps1"
& $scriptPath                          # run in child scope
& "C:\Windows\System32\notepad.exe"   # run a native executable
& { param($x) $x * 2 } 5             # invoke a script block with argument → 10

# Invoke-Expression (iex) — evaluate a STRING as PowerShell code in the CURRENT scope.
# Variables defined inside are visible in the caller. This is a security risk.
#
# WHY is Invoke-Expression dangerous?
# If the string comes from user input, a file, or a network, an attacker can inject
# arbitrary PowerShell code. It's the PowerShell equivalent of eval() in JavaScript/Python.

$code = 'Write-Host "Hello from eval"'
Invoke-Expression $code   # works, but avoid for untrusted input

# Legitimate use case for Invoke-Expression: dynamically building a command name:
$verb = "Get"
$noun = "Process"
Invoke-Expression "$verb-$noun"   # executes Get-Process

# Better alternative: use the call operator with a variable command name:
$cmdName = "Get-Process"
& $cmdName   # equivalent, safer

# WHY does & run in child scope but Invoke-Expression runs in current scope?
# & creates a new stack frame — any variables set inside don't leak out.
# iex runs in place — it's equivalent to typing the code directly at the prompt.

$x = "original"
& { $x = "modified" }
$x   # still "original" — child scope change didn't propagate

Invoke-Expression '$x = "modified"'
$x   # "modified" — current scope was changed

# ============================================================
# DOT-SOURCING — Load a script into current scope
# ============================================================

# Dot-sourcing (the . operator followed by a script path) runs a script
# in the CURRENT scope, making its functions and variables available to you.

. "C:\Scripts\helpers.ps1"    # now all functions defined in helpers.ps1 are available

# WHY use dot-sourcing?
# When you have a library of helper functions in a .ps1 file and want to use them
# interactively or in another script WITHOUT creating a formal module.
# It's the "quick and dirty" module system.

# WHY NOT to overuse dot-sourcing:
# Everything from the sourced file lands in your scope — variables, aliases, everything.
# Name collisions can cause subtle bugs. For anything beyond personal scripts,
# prefer proper modules (Import-Module) for encapsulation.

# ============================================================
# BACKGROUND JOBS — Parallel execution
# ============================================================

# Start-Job runs a script block in a separate PowerShell process.
# This is true parallelism — each job gets its own process.

$job = Start-Job -ScriptBlock {
    Start-Sleep -Seconds 3   # simulate slow work
    "Job completed!"
}

# Meanwhile, the main script continues:
Write-Host "Main thread is still running..."

# Wait for the job and get its output:
$result = Receive-Job -Job $job -Wait
Write-Host $result   # Job completed!

# Multiple jobs in parallel:
$jobs = @()
foreach ($i in 1..5) {
    $jobs += Start-Job -ScriptBlock {
        param($n)
        Start-Sleep -Seconds $n
        "Job $n done"
    } -ArgumentList $i
}

$results = $jobs | Wait-Job | Receive-Job
$results   # all 5 results collected

# Cleanup jobs after receiving results:
$jobs | Remove-Job

# WHY use jobs vs ForEach-Object -Parallel (PS 7+)?
# Start-Job: true separate processes, full isolation, heavier overhead.
# ForEach-Object -Parallel: thread-based, lighter, but shares process memory.
# Use jobs for heavy/long tasks; use -Parallel for many small tasks.

# PS 7+ parallel syntax:
# 1..5 | ForEach-Object -Parallel { Start-Sleep 1; "Item $_" } -ThrottleLimit 3

# ============================================================
# PSREMOTING — Execute commands on remote computers
# ============================================================

# PSRemoting uses WinRM (Windows Remote Management) to run PowerShell on remote machines.
# Objects travel across the wire serialized as XML (CLIXML) and deserialize on the other side.
# Note: Deserialized objects are "snapshots" — they don't have live methods.

# Enable remoting on the remote machine (run as admin there):
# Enable-PSRemoting -Force

# One-shot command on remote machine:
Invoke-Command -ComputerName "Server01" -ScriptBlock {
    Get-Process | Select-Object Name, CPU | Sort-Object CPU -Descending | Select-Object -First 5
}

# Persistent session (connection stays open — more efficient for multiple commands):
$session = New-PSSession -ComputerName "Server01"
Invoke-Command -Session $session -ScriptBlock { Get-Hotfix }
Invoke-Command -Session $session -ScriptBlock { Get-Service }
Remove-PSSession $session   # close when done

# Interactive remote session (like SSH):
Enter-PSSession -ComputerName "Server01"
# [Server01]: PS C:\> ... (you're now typing on Server01)
# Exit-PSSession to return

# Run a job remoting (fire and forget):
Invoke-Command -ComputerName "Server01" -ScriptBlock { Start-Process notepad } -AsJob

# ============================================================
# EXECUTION POLICY — Script security model
# ============================================================

# Execution policy controls which scripts PowerShell will run.
# It is NOT a security boundary — a determined user can bypass it.
# Its purpose is to prevent ACCIDENTAL running of scripts.

Get-ExecutionPolicy            # check current policy
Get-ExecutionPolicy -List      # show policy at each scope level

# Policy levels (least to most restrictive):
# Unrestricted — run any script, prompt for internet-downloaded scripts
# RemoteSigned — local scripts run freely; internet scripts need a trusted signature
# AllSigned    — ALL scripts must be signed by a trusted publisher
# Restricted   — no scripts at all (default on Windows clients)
# Bypass       — nothing blocked, no prompts (use in CI/CD pipelines)

# Set policy for current user only (no admin required):
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# WHY does -Scope matter?
# Policies cascade: MachinePolicy > UserPolicy > Process > CurrentUser > LocalMachine
# More restrictive policies set by GPO (MachinePolicy/UserPolicy) cannot be overridden
# by the user. Process scope only applies to the current PowerShell session.

# Bypass for a single script run (does NOT change persistent policy):
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Scripts\MyScript.ps1"
