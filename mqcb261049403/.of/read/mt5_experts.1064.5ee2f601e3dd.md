Calculation: Adaptive average = for close price P and lookback N, start at P[N+1]; from bar N+2 onward, ER = abs(P[t] - P[t-N]) / (small positive price increment + sum of abs(P[i] - P[i-1]) over the latest N bars); A[t] = A[t-1] + (ER * (2/(fast period+1) - 2/(slow period+1)) + 2/(slow period+1))^exponent * (P[t] - A[t-1]); the fast period is shorter than the slow period.
Calculation: Change and threshold = adaptive average minus its previous value, and a multiplier times the population standard deviation of the latest N adaptive-average changes, respectively; round each to the price precision plus two decimal places.
Calculation: Indicator-timeframe change and threshold = the same calculations on a configurable timeframe that may be higher than, lower than, or equal to the chart timeframe; use the last completed indicator bar by default, or the still-forming bar when configured.
Long: Change > threshold.
Short: Change < -threshold.
Long: Indicator-timeframe change > indicator-timeframe threshold AND the most recent earlier indicator bar with change > threshold OR change < -threshold has change < -threshold.
Short: Indicator-timeframe change < -indicator-timeframe threshold AND the most recent earlier indicator bar with change > threshold OR change < -threshold has change > threshold.
Exit: long, the latest indicator-timeframe bar at or before the selected bar with change > threshold OR change < -threshold has change < -threshold.
Exit: short, the latest indicator-timeframe bar at or before the selected bar with change > threshold OR change < -threshold has change > threshold.
Exit: long, low <= entry price - stop distance OR high >= entry price + profit distance.
Exit: short, high >= entry price + stop distance OR low <= entry price - profit distance.