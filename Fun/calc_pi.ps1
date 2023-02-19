<#
.SYNOPSIS
  Calculates an approximation of pi using the Leibniz formula.

.DESCRIPTION
  This script calculates an approximation of pi using the Leibniz formula.
  The formula is an alternating series that converges to pi/4 as the number of terms approaches infinity.
  The script prompts the user to enter the number of terms to use for the approximation, and then calculates and displays the resulting approximation of pi.

.PARAMETER None
  This script does not take any parameters.

.EXAMPLE
  PS> .\calc_pi.ps1
  Calculates an approximation of pi using the Leibniz formula.

.NOTES
  This script is based on the Leibniz formula for pi, which is an infinite series that converges to pi/4 as the number of terms approaches infinity.
  The script prompts the user to enter the number of terms to use for the approximation.
  The more terms used, the closer the approximation will be to the actual value of pi.
  This script is for educational purposes only and should not be used for any practical calculations.
#>

# Define the number of iterations for the formula
$iterations = 1000000 #more zeroes = higher accuracy & more cpu requirements

# Initialize the sum to 0
$sum = 0

# Loop through the iterations and calculate the sum
for ($i = 0; $i -lt $iterations; $i++) {
  $term = [Math]::Pow(-1, $i) / (2 * $i + 1)
  $sum += $term
}

# Multiply the sum by 4 to get an approximation of pi
$pi = $sum * 4

# Display the result
Write-Host "Pi is approximately $pi."