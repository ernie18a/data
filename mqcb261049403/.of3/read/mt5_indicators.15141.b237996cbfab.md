Calculation: Binary-wave change = current smoothed binary-wave value - previous smoothed binary-wave value
Calculation: Binary-wave change RMS = sqrt(mean(square(binary-wave change), lookback))
Long: Binary-wave change > lower threshold multiplier × Binary-wave change RMS AND Binary-wave change <= higher threshold multiplier × Binary-wave change RMS
Long: Binary-wave change > higher threshold multiplier × Binary-wave change RMS
Short: Binary-wave change < -lower threshold multiplier × Binary-wave change RMS AND Binary-wave change >= -higher threshold multiplier × Binary-wave change RMS
Short: Binary-wave change < -higher threshold multiplier × Binary-wave change RMS