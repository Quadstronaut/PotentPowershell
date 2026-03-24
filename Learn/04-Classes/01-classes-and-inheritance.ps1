<#
.SYNOPSIS
    PowerShell classes and inheritance — annotated.

.DESCRIPTION
    Covers class definition, constructors, properties, methods, static members,
    inheritance, and enums. Explains how PowerShell OOP compares to C# and Python.

.NOTES
    Source : LearnXInYMinutes — PowerShell
             https://learnxinyminutes.com/powershell/
             Authors : Wouter Van Schandevijl, Andrew Ryan Davis
             License : Creative Commons Attribution-ShareAlike 3.0 Unported
                       https://creativecommons.org/licenses/by-sa/3.0/
    Annotations : Quadstronaut
#>

# ============================================================
# DEFINING A CLASS
# ============================================================

# PowerShell classes were introduced in PowerShell 5.0.
# Before that, you'd use Add-Type with C# code or New-Object with COM/WMI.

class Animal {
    # Properties (fields with types)
    [string]$Name
    [int]$Age
    [string]$Sound = "..."   # default value

    # Constructor — runs when you create an instance
    # WHY use a constructor? To enforce that required data is provided at creation time.
    # Without a constructor, you'd need to set properties manually after creation,
    # which risks leaving objects in an incomplete state.
    Animal([string]$name, [int]$age) {
        $this.Name = $name
        $this.Age  = $age
    }

    # Methods — functions that belong to the class
    # $this refers to the current instance (like Python's self, Java/C#'s this)
    [string] Speak() {
        return "$($this.Name) says: $($this.Sound)"
    }

    [string] ToString() {
        return "$($this.Name) (age $($this.Age))"
    }
}

# Creating instances:
# Method 1: [ClassName]::new() — preferred in PowerShell 5+
$dog = [Animal]::new("Rex", 3)

# Method 2: New-Object — older syntax, still works
$cat = New-Object Animal("Whiskers", 5)

# WHY prefer ::new() over New-Object?
# ::new() is faster (no overhead of New-Object's pipeline and reflection),
# works better in classes (you can call it from within methods), and is
# consistent with how .NET types create instances. New-Object still has its
# place for COM objects and backward compat.

$dog.Speak()          # Rex says: ...
$dog.Name = "Buddy"   # properties are mutable (unless you use [ValidateSet] etc.)
$dog.ToString()       # Buddy (age 3)

# ============================================================
# INHERITANCE
# ============================================================

# WHY use inheritance? To model "is-a" relationships and reuse code.
# A Dog IS-A Animal. A Car IS-A Vehicle. The child class gets all parent
# properties and methods, and can add or override them.

class Dog : Animal {
    [string]$Breed

    Dog([string]$name, [int]$age, [string]$breed) : base($name, $age) {
        # : base(...) calls the parent constructor — required if parent has a constructor
        $this.Breed = $breed
        $this.Sound = "Woof"   # override the default from Animal
    }

    [void] Fetch() {
        Write-Host "$($this.Name) fetches the ball!"
    }

    # Override the parent method:
    [string] Speak() {
        return "$($this.Name) the $($this.Breed) barks: $($this.Sound)!"
    }
}

class Cat : Animal {
    Cat([string]$name, [int]$age) : base($name, $age) {
        $this.Sound = "Meow"
    }
}

$rex = [Dog]::new("Rex", 3, "Labrador")
$rex.Speak()    # Rex the Labrador barks: Woof!
$rex.Fetch()    # Rex fetches the ball!

$whiskers = [Cat]::new("Whiskers", 5)
$whiskers.Speak()   # Whiskers says: Meow

# Type checking with inheritance:
$rex -is [Dog]     # True
$rex -is [Animal]  # True — a Dog IS-A Animal (polymorphism)

# ============================================================
# STATIC MEMBERS
# ============================================================

# Static members belong to the CLASS, not to instances.
# WHY use static? For shared state/behaviour that doesn't vary per-instance.
# Example: a counter of how many animals have been created.

class Counter {
    static [int]$Count = 0

    static [void] Increment() {
        [Counter]::Count++
    }

    static [int] GetCount() {
        return [Counter]::Count
    }
}

[Counter]::Increment()
[Counter]::Increment()
[Counter]::GetCount()   # 2

# Access static members with ::, not . (same as .NET convention)

# ============================================================
# ENUMS
# ============================================================

# An enum is a named set of integer constants.
# WHY use enums? They replace magic numbers/strings with descriptive names,
# make code self-documenting, and restrict values to a valid set.

enum DayOfWeek {
    Sunday    = 0
    Monday    = 1
    Tuesday   = 2
    Wednesday = 3
    Thursday  = 4
    Friday    = 5
    Saturday  = 6
}

$today = [DayOfWeek]::Wednesday
$today              # Wednesday
[int]$today         # 3

# Enum in a function parameter — restricts input automatically:
function Get-DayType {
    param([DayOfWeek]$Day)
    if ($Day -eq [DayOfWeek]::Saturday -or $Day -eq [DayOfWeek]::Sunday) {
        return "Weekend"
    }
    return "Weekday"
}

Get-DayType -Day Wednesday   # Weekday
Get-DayType -Day Saturday    # Weekend
# Get-DayType -Day "Blah"   # error — not a valid DayOfWeek value

# Flags enum (combine values with bitwise OR):
[Flags()] enum Permission {
    None    = 0
    Read    = 1
    Write   = 2
    Execute = 4
}

$myPerms = [Permission]::Read -bor [Permission]::Write   # 3
$myPerms   # Read, Write (PowerShell formats flags enums nicely)

# ============================================================
# HIDDEN MEMBERS
# ============================================================

class BankAccount {
    [string]$Owner
    hidden [double]$Balance   # hidden: not shown in IntelliSense or Get-Member by default

    BankAccount([string]$owner, [double]$initialBalance) {
        $this.Owner   = $owner
        $this.Balance = $initialBalance
    }

    [void] Deposit([double]$amount) {
        $this.Balance += $amount
    }

    [double] GetBalance() {
        return $this.Balance
    }
}

$account = [BankAccount]::new("Alice", 1000)
$account.Deposit(500)
$account.GetBalance()   # 1500
# $account.Balance      # works if you know the name, but hidden from tab-complete/Get-Member
