Calculation: Weighted price = (2 × close + high + low) / 4
Calculation: Volume-weighted price = sum(Weighted price × volume over the current and preceding AVERAGE chart-timeframe bars) / sum(volume over those bars)
Calculation: Normalized value = 100 × (Volume-weighted price − its minimum over the current and preceding PERIOD chart-timeframe bars) / max(its maximum minus its minimum over those bars, minimum price increment)
Calculation: Fast line = linearly weighted moving average of Normalized value over AVERAGE chart-timeframe bars, including the current bar
Calculation: Slow line = linearly weighted moving average of Fast line over AVERAGE chart-timeframe bars, including the current bar; same lookback as the Fast line
Long: Fast line > Slow line
Short: Fast line ≤ Slow line