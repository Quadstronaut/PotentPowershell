<#
.SYNOPSIS
    PowerShell variables, arrays, ArrayLists, hashtables, and tuples — annotated.

.DESCRIPTION
    Covers why arrays are fixed-size, how ArrayList solves that, what tuples are
    and why immutability matters, and how hashtable ordering works.

.NOTES
    Source : LearnXInYMinutes — PowerShell
             https://learnxinyminutes.com/powershell/
             Authors : Wouter Van Schandevijl, Andrew Ryan Davis
             License : Creative Commons Attribution-ShareAlike 3.0 Unported
                       https://creativecommons.org/licenses/by-sa/3.0/
    Annotations : Quadstronaut
#>

# ============================================================
# VARIABLES
# ============================================================

# Variable names start with $ and can contain letters, digits, underscores.
# PowerShell is dynamically typed — the type is inferred from the value.
$x = 10
$greeting = "Hello"
$pi = 3.14159

# WHY the $ sigil? It comes from Unix shell tradition (Bash, sh, etc.) where $var
# means "the VALUE of var" as opposed to just "var" (the name). PowerShell
# kept this to feel familiar to sysadmins coming from Bash/sh.

# You can strongly type variables by prepending a type accelerator.
# This forces every assignment to that variable to match the type.
[int]$count = 5
[string]$label = "items"

# Automatic variables (set by PowerShell, don't overwrite these):
# $_ or $PSItem  — current pipeline object
# $?            — success/failure of last command ($true/$false)
# $LASTEXITCODE — exit code of last native executable
# $null         — the null value (like null/None/nil in other languages)
# $true / $false — boolean literals

# ============================================================
# ARRAYS — Fixed-size by default
# ============================================================

# Array literal syntax — comma separates elements, @() is the array operator.
$fruits = @("apple", "banana", "cherry")

# WHY are PowerShell arrays fixed-size?
# PowerShell arrays are .NET System.Object[] arrays under the hood.
# .NET arrays are fixed-size at the CLR level for performance: the runtime
# allocates a contiguous block of memory exactly the right size.
# Resizing requires allocating a new block and copying everything over.
# PowerShell hides this with the += operator, but it creates a NEW array each time.

$arr = @(1, 2, 3)
$arr += 4    # This does NOT modify $arr in place.
             # It creates a brand new array [1,2,3,4] and rebinds $arr to it.
             # If you += in a loop 1000 times, you copy the entire array 1000 times.
             # That's O(n²) time — fine for small data, slow for large data.

# Accessing elements (zero-indexed)
$fruits[0]    # apple
$fruits[1]    # banana
$fruits[-1]   # cherry (negative index counts from end — like Python)
$fruits[-2]   # banana

# Slicing
$fruits[0..1]          # apple, banana (range operator)
$fruits[0,2]           # apple, cherry (specific indices)

# WHY does -eq on arrays FILTER instead of compare?
# When the left operand of -eq is an array, PowerShell treats it as a filter
# and returns matching elements rather than doing a boolean comparison.
# This is a deliberate design choice: it makes array searching idiomatic.
$numbers = @(1, 2, 3, 2, 1)
$numbers -eq 2     # returns @(2, 2) — all matching elements, not $true/$false
$numbers -ne 2     # returns @(1, 3, 1) — all non-matching elements

# To check IF a value exists in an array:
$numbers -contains 2   # True  (boolean)
$numbers -notcontains 5 # True (boolean)

# Array properties and methods
$fruits.Count          # 3
$fruits.Length         # 3 (same thing)
$fruits -join ", "     # "apple, banana, cherry"
[Array]::Reverse($fruits)  # reverses in place

# ============================================================
# ARRAYLIST — Resizable (use this for performance in loops)
# ============================================================

# ArrayList is a .NET class from System.Collections that supports dynamic resizing.
# Internally it uses a doubling strategy: when full, it doubles capacity and copies once.
# That's O(1) amortized append vs O(n) for array +=.
$list = [System.Collections.ArrayList]::new()
$list.Add("apple")    # returns the index of the added item (suppress with $null = or [void])
$list.Add("banana")
$list.Add("cherry")

# Suppress the index output (common pattern)
$null = $list.Add("date")
[void]$list.Add("elderberry")

$list.Remove("banana")    # removes by value
$list.RemoveAt(0)         # removes by index
$list.Count               # current item count
$list.Contains("cherry")  # True

# You can also use the generic List[T] for type-safe lists:
$typedList = [System.Collections.Generic.List[string]]::new()
$typedList.Add("hello")
$typedList.Add("world")
# $typedList.Add(42)  # This would throw — type safety enforced

# ============================================================
# HASHTABLES — Key-value pairs
# ============================================================

# @{} creates an unordered hashtable. Order of key iteration is NOT guaranteed.
$person = @{
    Name = "Alice"
    Age  = 30
    City = "Seattle"
}

# Accessing values
$person["Name"]     # Alice
$person.Name        # Alice — dot notation works too (syntactic sugar)
$person.Age         # 30

# WHY is @{} unordered?
# The default Hashtable uses a hash function to map keys to buckets.
# Iteration order depends on hash values, not insertion order — that's the whole
# point of a hash table: O(1) lookup, not ordered storage.

# Adding and removing
$person["Email"] = "alice@example.com"   # add new key
$person.Phone = "555-1234"               # dot notation also works for adding
$person.Remove("Phone")                   # remove a key

# Checking for keys/values
$person.ContainsKey("Name")     # True
$person.ContainsValue("Alice")  # True

# ============================================================
# ORDERED HASHTABLE — When insertion order matters
# ============================================================

# [ordered] is a type accelerator that creates a System.Collections.Specialized.OrderedDictionary.
# Keys are iterated in the order they were inserted.
$orderedPerson = [ordered]@{
    Name = "Bob"
    Age  = 25
    City = "Portland"
}

# WHY use [ordered]? Examples: config files, CSV column order, display tables,
# anywhere the sequence of keys has meaning to a human or downstream system.
foreach ($key in $orderedPerson.Keys) {
    Write-Host "$key : $($orderedPerson[$key])"
}
# Prints in insertion order: Name, Age, City

# ============================================================
# SPLATTING — Passing parameter sets elegantly
# ============================================================

# Splatting lets you store a set of parameters in a hashtable and pass them
# to a command all at once using @variableName (not $variableName).
# This is one of PowerShell's "killer features" for readable, maintainable scripts.

# Without splatting — hard to read, easy to miss a parameter:
Copy-Item -Path "C:\source.txt" -Destination "C:\dest.txt" -Force -Verbose

# With splatting — clean, easy to add/remove parameters:
$copyParams = @{
    Path        = "C:\source.txt"
    Destination = "C:\dest.txt"
    Force       = $true
    Verbose     = $true
}
Copy-Item @copyParams

# WHY does splatting use @ instead of $?
# $ means "value of this variable" — a hashtable.
# @ means "spread these key-value pairs as named parameters."
# The syntax difference makes the intent explicit and prevents ambiguity.

# Splatting works with arrays too (for positional parameters):
$pingArgs = @("google.com", "-Count", "4")
ping @pingArgs   # equivalent to: ping google.com -Count 4

# ============================================================
# TUPLES — Immutable ordered collections
# ============================================================

# A tuple is an ordered, immutable sequence of values. Once created, you cannot
# change its elements. This is a .NET type (System.Tuple).

$point = [System.Tuple]::Create(10, 20)
$point.Item1    # 10
$point.Item2    # 20

# WHY are tuples immutable?
# 1. SAFETY: If you pass a tuple to a function, you know it can't be modified.
#    Arrays are reference types — a function could silently mutate your data.
# 2. INTENT: A tuple says "these values belong together and represent a fixed thing."
#    A 2D point is always (x, y). Making it immutable enforces that contract.
# 3. THREAD SAFETY: Immutable objects can be shared across threads without locks.
#    Mutable shared state is the #1 source of concurrency bugs.
#
# Python analogy: Python has built-in tuple syntax — (10, 20).
# Python tuples are also immutable for the same reasons.
# In Python, (x, y) = point unpacks a tuple; PowerShell doesn't have built-in
# destructuring, but you can do: $x = $point.Item1; $y = $point.Item2

# Tuples can hold mixed types (generic Tuple[T1,T2,...] enforces this):
$mixed = [System.Tuple]::Create("Alice", 30, $true)
$mixed.Item1    # Alice (string)
$mixed.Item2    # 30 (int)
$mixed.Item3    # True (bool)

# ValueTuple is the modern alternative (PS 5.1+, .NET 4.7+), supports deconstruction:
# $vt = [System.ValueTuple]::Create(1, 2)  # struct-based, slightly more efficient
