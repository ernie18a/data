Calculation: Relative volume = volume / simple moving average of volume
Calculation: Relative volume z-score = (relative volume − its simple moving average over the z-score window) / standard deviation of relative volume over the same window
Long: Close crosses above the reclaim EMA
Short: Close crosses below the reclaim EMA
Long: In session AND relative volume z-score is at or above the hot threshold (or, when warm trading is enabled, at or above the warm threshold) AND close > trend EMA AND close crosses above reclaim EMA AND position is not already long AND cooldown has elapsed
Short: In session AND relative volume z-score is at or above the hot threshold (or, when warm trading is enabled, at or above the warm threshold) AND close < trend EMA AND close crosses below reclaim EMA AND position is not already short AND cooldown has elapsed