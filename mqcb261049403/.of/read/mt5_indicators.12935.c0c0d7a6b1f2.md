Calculation: Gaussian average = weighted mean of the selected price series over a lookback including the current bar, with weight exp(A × k^N) for age k; if the absolute value of N exceeds 5, use N = 5. The selectable price series are open, high, low, close, (high + low)/2, (high + low + close)/3, (high + low + 2 × close)/4, (open + close)/2, (open + high + low + close)/4, high if close > open otherwise low if close < open otherwise close, and (high + close)/2 if close > open otherwise (low + close)/2 if close < open otherwise close.
Calculation: Rounded change = current Gaussian average minus previous Gaussian average, rounded to the configured price precision plus two decimal places.
Calculation: Lower and upper thresholds = population standard deviation of Gaussian-average bar-to-bar changes over a lookback including the current change, multiplied respectively by a lower and a higher coefficient and rounded to the configured price precision plus two decimal places.
Long: Gaussian average > previous Gaussian average
Short: Gaussian average < previous Gaussian average
Long: Rounded change > lower threshold AND rounded change <= upper threshold
Long: Rounded change > upper threshold
Short: Rounded change < -lower threshold AND rounded change >= -upper threshold
Short: Rounded change < -upper threshold