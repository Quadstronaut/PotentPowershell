<#
.SYNOPSIS
    Approximates Pi using the Leibniz formula.

.DESCRIPTION
    Calculates Pi via the Leibniz infinite series: pi/4 = 1 - 1/3 + 1/5 - 1/7 + ...
    More iterations = higher accuracy at the cost of CPU time.
    Educational demonstration of iterative approximation and floating-point math.

.PARAMETER Iterations
    Number of terms to sum. Default: 1,000,000. More terms → closer to true Pi.

.EXAMPLE
    PS> .\Get-PiApproximation.ps1
    Pi is approximately 3.14159165358979 (after 1,000,000 iterations)

.EXAMPLE
    PS> .\Get-PiApproximation.ps1 -Iterations 10000000
    Higher accuracy, more CPU time.

.NOTES
    Author     : Quadstronaut
    Formula    : Leibniz formula for Pi — https://en.wikipedia.org/wiki/Leibniz_formula_for_pi
    Convergence: Very slow — millions of terms needed for a few correct digits.
                 For faster convergence, see the Machin formula or BBP formula.
#>

[CmdletBinding()]
param(
    [int]$Iterations = 1000000
)

Write-Verbose "Calculating Pi with $Iterations iterations..."

$sum = 0.0

for ($i = 0; $i -lt $Iterations; $i++) {
    # Leibniz term: (-1)^i / (2i + 1)
    # The sign alternates: +1, -1, +1, -1, ...
    # The denominator grows: 1, 3, 5, 7, ...
    $term = [Math]::Pow(-1, $i) / (2 * $i + 1)
    $sum += $term
}

# The series converges to pi/4, so multiply by 4
$pi = $sum * 4

Write-Host "Pi is approximately $pi (after $Iterations iterations)"
Write-Host "True Pi:            3.14159265358979323846..."
Write-Host "Error:              $([Math]::Abs([Math]::PI - $pi))"
