Calculation: Signed volume = volume when close > open, otherwise -volume
Calculation: Recent block signed-volume sum = sum of signed volume over one block length, including the current bar
Calculation: Previous block signed-volume sum = sum of signed volume over the immediately preceding block of equal length
Calculation: Older block signed-volume sum = sum of signed volume over the next preceding block of equal length
Calculation: Projected-trend signed-volume average = average, for each offset i from 0 through one block length, of the mean of signed volume at offsets i, i + one block length, and i + two block lengths
Long: Recent block signed-volume sum > 0 OR Previous block signed-volume sum > 0 OR Older block signed-volume sum > 0 OR Projected-trend signed-volume average > 0
Short: Recent block signed-volume sum <= 0 OR Previous block signed-volume sum <= 0 OR Older block signed-volume sum <= 0 OR Projected-trend signed-volume average <= 0