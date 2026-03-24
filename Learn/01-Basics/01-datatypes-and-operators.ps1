<#
.SYNOPSIS
    PowerShell data types and operators — annotated learning reference.

.DESCRIPTION
    Covers numbers, strings, booleans, comparison operators, and arithmetic.
    Includes deep commentary on WHY PowerShell behaves the way it does compared
    to other languages (Banker's rounding, division semantics, operator names, etc.)

.NOTES
    Source : LearnXInYMinutes — PowerShell
             https://learnxinyminutes.com/powershell/
             Authors : Wouter Van Schandevijl, Andrew Ryan Davis
             License : Creative Commons Attribution-ShareAlike 3.0 Unported
                       https://creativecommons.org/licenses/by-sa/3.0/
    Annotations : Quadstronaut
#>

# ============================================================
# NUMBERS
# ============================================================

# PowerShell supports standard integer and floating-point literals.
3     # Int32
3.14  # Double
6.3e3 # 6300 (scientific notation — Double)
0x1F  # 31   (hexadecimal — Int32)
1KB   # 1024  — PowerShell has built-in size multipliers: KB, MB, GB, TB, PB

# WHY does division always return a float when the result isn't whole?
# PowerShell follows IEEE 754 semantics. Integer division that produces a
# fractional result is automatically promoted to Double so you don't silently
# lose data. Compare to Python 3 where // is explicit integer division.
7 / 2    # 3.5  (Double, not 3)
7 / 1    # 7    (still Int32 — no promotion needed)

# Modulo (remainder) works as expected.
7 % 2    # 1

# ============================================================
# ROUNDING — BANKER'S ROUNDING (this will surprise you)
# ============================================================

# [Math]::Round() uses Banker's Rounding (IEEE 754 "round half to even") by default.
# This means .5 rounds to the NEAREST EVEN number, not always up.
#
# WHY? Banker's rounding reduces cumulative statistical bias when rounding
# many values. If every .5 rounds up, your sums drift upward over time.
# Financial and scientific code uses it to stay accurate in aggregate.
#
# The catch: it feels wrong until you understand the rule.
[Math]::Round(0.5)   # 0  (nearest even is 0)
[Math]::Round(1.5)   # 2  (nearest even is 2)
[Math]::Round(2.5)   # 2  (nearest even is 2)
[Math]::Round(3.5)   # 4  (nearest even is 4)

# To get the "school math" round-half-up behaviour, pass the rounding mode:
[Math]::Round(2.5, [MidpointRounding]::AwayFromZero)  # 3

# ============================================================
# STRINGS
# ============================================================

# Double quotes allow variable/expression interpolation.
"Hello, World!"
$name = "World"
"Hello, $name!"           # Hello, World!
"2 + 3 = $(2 + 3)"        # 2 + 3 = 5  (subexpressions need $())

# Single quotes are literal — no interpolation. Use when you want the raw text.
'Hello, $name!'           # Hello, $name!
'2 + 3 = $(2 + 3)'        # 2 + 3 = $(2 + 3)

# WHY does PowerShell use backtick (`) as the escape character instead of backslash (\)?
# Because backslash is the Windows path separator (C:\Windows\...) and embedding it as
# an escape would make path strings a nightmare. Backtick was chosen as a neutral symbol.
"Column1`tColumn2"        # tab between columns
"Line1`nLine2"            # newline
"She said `"hello`""      # escaped double quote

# Here-strings for multi-line content (note: @" must be at end of line, "@ at start).
$multiline = @"
This is line one.
This is line two.
Variables still interpolate: $name
"@

$literal = @'
No interpolation here: $name stays as-is.
'@

# String operations
"Hello" + " " + "World"   # concatenation (operator)
"Ha" * 3                  # HaHaHa — repetition
"PowerShell".Length        # 10 — accessing .NET properties directly
"hello world".ToUpper()   # HELLO WORLD
"  trim me  ".Trim()      # trim me

# ============================================================
# BOOLEANS
# ============================================================

$true
$false

# WHY are truthy/falsy rules the way they are?
# PowerShell tries to be intuitive for sysadmins, not mathematicians.
# The rules are documented, but they differ from Python/JavaScript in subtle ways.

# Falsy values: $false, $null, 0, 0.0, "", @() (empty array)
# Truthy: everything else — including the string "0" (unlike some languages)
if ("0") { "truthy" }    # "truthy" — non-empty string is truthy even if it's "0"
if (0)   { "truthy" }    # (nothing) — numeric zero is falsy
if (@()) { "truthy" }    # (nothing) — empty array is falsy
if (@(0)){ "truthy" }    # "truthy" — array with one element (even 0) is truthy

# ============================================================
# COMPARISON OPERATORS
# ============================================================

# WHY does PowerShell use -eq, -lt, -gt instead of ==, <, >?
# In the shell world, < and > are redirection operators (stdin/stdout).
# Using them for comparison would break the parser. PowerShell keeps them as
# redirection and uses letter-based operators instead — consistent with classic
# Unix tools like test(1) and Bash's [ -eq ] syntax.

1 -eq 1      # True   (equal)
1 -ne 2      # True   (not equal)
1 -lt 2      # True   (less than)
2 -gt 1      # True   (greater than)
1 -le 1      # True   (less than or equal)
1 -ge 1      # True   (greater than or equal)

# String comparison (case-insensitive by default)
"abc" -eq "ABC"    # True  — PowerShell strings are case-insensitive by default
"abc" -ceq "ABC"   # False — prefix 'c' forces case-sensitive: -ceq, -clt, -cgt, etc.
"abc" -ieq "ABC"   # True  — prefix 'i' is explicit case-insensitive (default behaviour)

# Type testing
# WHY use -is instead of just checking the type? Because it handles inheritance:
# a [FileInfo] object -is [System.IO.FileSystemInfo] returns True.
1 -is [int]           # True
"hello" -is [string]  # True
1 -is [string]        # False

# ============================================================
# LOGICAL OPERATORS
# ============================================================

# WHY -and, -or, -not instead of &&, ||, ! ?
# Again, the shell: && and || already mean "run next command if previous succeeded/failed"
# in classic shells. PowerShell reserves them as pipeline chain operators (PS 7+).
# Using -and/-or/-not keeps the logic operators unambiguous in all versions.

$true -and $false   # False
$true -or  $false   # True
-not $true          # False
!$true              # False — ! is an alias for -not

# Short-circuit evaluation: PowerShell -and/-or do short-circuit.
# The right side is not evaluated if the left side determines the result.
$x = $null
if ($x -ne $null -and $x.Length -gt 0) { "has content" }  # safe — short-circuits

# ============================================================
# ARITHMETIC OPERATORS
# ============================================================

1 + 1     # 2
3 - 1     # 2
5 * 2     # 10
7 / 2     # 3.5
10 % 3    # 1

# Bitwise operators
0b1010 -band 0b1100   # 8  (binary AND)   — 0b prefix requires PS 6+
0b1010 -bor  0b1100   # 14 (binary OR)
0b1010 -bxor 0b1100   # 6  (binary XOR)
-bnot 0b1010          # bitwise NOT (result depends on int width)
0b0001 -shl 3         # 8  (shift left by 3 bits)
0b1000 -shr 3         # 1  (shift right by 3 bits)

# ============================================================
# TYPE COERCION
# ============================================================

# PowerShell coerces types based on the LEFT operand. This matters.
"1" + 2    # "12"  — left is string, so 2 gets coerced to string
1 + "2"    # 3     — left is int, so "2" gets coerced to int

# Explicit casting
[int]"42"        # 42
[string]42       # "42"
[double]"3.14"   # 3.14
[bool]0          # False
[bool]1          # True
