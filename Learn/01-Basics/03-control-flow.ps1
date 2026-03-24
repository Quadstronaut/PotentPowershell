<#
.SYNOPSIS
    PowerShell control flow — if/else, switch, loops, and pipeline — annotated.

.DESCRIPTION
    Covers conditionals, switch (with PowerShell-specific fall-through rules),
    all loop variants, and the pipeline as a control mechanism.

.NOTES
    Source : LearnXInYMinutes — PowerShell
             https://learnxinyminutes.com/powershell/
             Authors : Wouter Van Schandevijl, Andrew Ryan Davis
             License : Creative Commons Attribution-ShareAlike 3.0 Unported
                       https://creativecommons.org/licenses/by-sa/3.0/
    Annotations : Quadstronaut
#>

# ============================================================
# IF / ELSEIF / ELSE
# ============================================================

$temperature = 72

if ($temperature -gt 90) {
    Write-Host "Hot"
} elseif ($temperature -gt 70) {
    Write-Host "Warm"
} elseif ($temperature -gt 50) {
    Write-Host "Cool"
} else {
    Write-Host "Cold"
}

# Ternary-style with inline if (PowerShell 7.0+):
$label = $temperature -gt 70 ? "Warm" : "Not warm"

# Classic ternary-equivalent for PS 5.1:
$label = if ($temperature -gt 70) { "Warm" } else { "Not warm" }
# WHY does this work? In PowerShell, if/else are expressions that return the last
# value in the executed block. You can assign them directly.

# ============================================================
# SWITCH — More powerful than most languages
# ============================================================

$day = "Monday"

switch ($day) {
    "Saturday" { Write-Host "Weekend" }
    "Sunday"   { Write-Host "Weekend" }
    "Monday"   { Write-Host "Weekday" }
    default    { Write-Host "Also a weekday" }
}

# WHY does PowerShell switch NOT fall through by default?
# In C, Java, and JavaScript, switch cases fall through to the next case unless
# you add an explicit `break`. This causes many subtle bugs.
# PowerShell's switch breaks automatically after each matched case.
# If you WANT fall-through, you use `continue` to skip to the next case check,
# or just don't add a break — but each case is evaluated independently.

# Switch can match multiple cases (unlike most languages):
$value = 5
switch ($value) {
    { $_ -lt 10  } { Write-Host "Less than 10" }   # condition block
    { $_ -gt 3   } { Write-Host "Greater than 3" } # BOTH of these match 5
    { $_ -eq 5   } { Write-Host "Exactly 5" }       # and this one too
}
# Output: all three messages — PowerShell evaluates ALL cases unless you `break`

# Switch with -Wildcard:
$filename = "report_2024.csv"
switch -Wildcard ($filename) {
    "*.csv"  { Write-Host "CSV file" }
    "*.xlsx" { Write-Host "Excel file" }
    "report*"{ Write-Host "Report file" }
}
# Both "*.csv" and "report*" match — both messages print

# Switch with -Regex:
switch -Regex ($filename) {
    "^\w+_\d{4}" { Write-Host "Matches pattern: word_year" }
    "\.csv$"     { Write-Host "Ends in .csv" }
}

# Switch iterating over an array (applies each case to each element):
switch (@(1, 2, 3)) {
    1 { Write-Host "one" }
    2 { Write-Host "two" }
    3 { Write-Host "three" }
}

# ============================================================
# LOOPS
# ============================================================

# --- for loop ---
for ($i = 0; $i -lt 5; $i++) {
    Write-Host $i
}

# --- while loop ---
$i = 0
while ($i -lt 5) {
    Write-Host $i
    $i++
}

# --- do-while (runs at least once) ---
$i = 0
do {
    Write-Host $i
    $i++
} while ($i -lt 5)

# --- do-until (runs until condition is true) ---
$i = 0
do {
    Write-Host $i
    $i++
} until ($i -ge 5)

# --- foreach statement (language keyword) ---
$fruits = @("apple", "banana", "cherry")
foreach ($fruit in $fruits) {
    Write-Host $fruit
}

# WHY use `foreach` statement vs ForEach-Object cmdlet?
#
# `foreach` (statement):
#   - Language construct, runs in the CURRENT scope
#   - Cannot receive pipeline input — it's a control structure, not a cmdlet
#   - Generally FASTER for large collections (no pipeline overhead)
#   - $_ is not set; use the loop variable you declared ($fruit above)
#
# ForEach-Object (cmdlet):
#   - Works IN the pipeline — perfect for streaming large data
#   - Uses $_ (or $PSItem) for the current object
#   - Has -Begin and -End blocks for setup/teardown
#   - Slower per-item due to pipeline infrastructure overhead

# Pipeline version:
$fruits | ForEach-Object { Write-Host $_ }

# ForEach-Object with Begin/Process/End:
$fruits | ForEach-Object `
    -Begin   { Write-Host "--- Start ---" } `
    -Process { Write-Host "Processing: $_" } `
    -End     { Write-Host "--- Done ---" }

# ============================================================
# LOOP CONTROL — break and continue
# ============================================================

# break — exit the loop entirely
for ($i = 0; $i -lt 10; $i++) {
    if ($i -eq 5) { break }
    Write-Host $i   # 0,1,2,3,4
}

# continue — skip to next iteration
for ($i = 0; $i -lt 5; $i++) {
    if ($i -eq 2) { continue }
    Write-Host $i   # 0,1,3,4
}

# ============================================================
# PIPELINE — PowerShell's key differentiator from Bash
# ============================================================

# The pipeline (|) passes OBJECTS, not text.
# This is the most important conceptual difference from Bash.
#
# In Bash: commands emit text, next command must parse that text.
# In PowerShell: commands emit .NET objects with properties and methods.
# The next command receives those objects and can work with their structure directly.

# Example: get all processes using more than 100MB of memory.
# The objects flowing through the pipe are [Process] objects, not text lines.
Get-Process | Where-Object { $_.WorkingSet -gt 100MB } | Sort-Object WorkingSet -Descending

# Each stage:
# Get-Process          — emits [Process] objects
# Where-Object { }     — filters; $_ is the current [Process] object; .WorkingSet is a property
# Sort-Object          — sorts by the WorkingSet property (no text parsing needed!)

# Pipeline with Select-Object to project only needed properties:
Get-Process | Select-Object Name, CPU, WorkingSet | Format-Table -AutoSize

# ============================================================
# EXCEPTION HANDLING — try / catch / finally
# ============================================================

try {
    # Code that might fail
    $result = 1 / 0
    Get-Item "C:\nonexistent\path.txt" -ErrorAction Stop
}
catch [System.DivideByZeroException] {
    # Catch specific exception types
    Write-Warning "Division by zero!"
}
catch [System.IO.FileNotFoundException] {
    Write-Warning "File not found: $($_.Exception.Message)"
}
catch {
    # Catch-all for anything else
    Write-Warning "Unexpected error: $($_.Exception.Message)"
    Write-Warning "Type: $($_.Exception.GetType().Name)"
}
finally {
    # Always runs, even if an exception was thrown
    # Use for cleanup: closing files, releasing resources, etc.
    Write-Host "Cleanup complete."
}

# WHY does Get-Item need -ErrorAction Stop to be caught?
# PowerShell has TWO error streams: terminating and non-terminating.
# Non-terminating errors (like a missing file) write to the error stream
# but don't throw exceptions — try/catch doesn't see them.
# -ErrorAction Stop converts any non-terminating error into a terminating one
# that try/catch can handle. This is critical for robust error handling.

# $ErrorActionPreference — sets the default for all commands in scope:
$ErrorActionPreference = 'Stop'    # all errors become terminating
$ErrorActionPreference = 'Continue' # default — errors print but execution continues
$ErrorActionPreference = 'SilentlyContinue' # suppress error output entirely
