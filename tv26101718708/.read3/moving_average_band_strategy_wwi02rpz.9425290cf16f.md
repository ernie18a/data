Calculation: Upper Band = selected moving average(high, lookback, moving-average type) × (1 + band offset)
Calculation: Lower Band = selected moving average(low, lookback, moving-average type) × (1 - band offset)
Long: close crosses above Upper Band AND long trades are enabled AND no long position is open
Short: close crosses below Lower Band AND short trades are enabled AND no short position is open
Exit: Long, low ≤ Lower Band at entry OR (risk-reward target is enabled AND high ≥ entry price + (entry price - Lower Band at entry) × risk-reward ratio)
Exit: Short, high ≥ Upper Band at entry OR (risk-reward target is enabled AND low ≤ entry price - (Upper Band at entry - entry price) × risk-reward ratio)