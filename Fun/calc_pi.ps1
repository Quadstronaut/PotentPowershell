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