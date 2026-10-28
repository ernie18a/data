Calculation: On-balance volume = cumulative volume added when close rises, subtracted when close falls, and unchanged when close is unchanged
Calculation: Smoothed OBV = Hull moving average of on-balance volume
Calculation: OBV baseline = rolling simple moving average of smoothed OBV
Calculation: OBV slope Z-score = z-score over a rolling window of smoothed OBV minus its value at the slope lookback
Calculation: Confirmed pivot high/low = a high/low with the configured number of lower highs/higher lows on the left and right; use it only when the right-side bars have completed
Long: smoothed OBV crosses above its baseline
Long: OBV slope Z-score crosses above its positive threshold
Long: newly confirmed OBV pivot high is higher than the previous confirmed OBV pivot high
Long: the latest two confirmed OBV highs are rising and the latest two confirmed OBV lows are rising, OR the most recent confirmed OBV pivot is a higher low
Long: on a confirmed price pivot low, the latest price pivot low is below the preceding price pivot low AND the latest confirmed OBV pivot low is above the preceding confirmed OBV pivot low AND the two price pivot lows are separated by at least the minimum and at most the maximum pivot bars AND the latest price and OBV pivot lows are within twice the right-pivot lookback bars of each other AND OBV slope Z-score is above the negative threshold
Short: smoothed OBV crosses below its baseline
Short: OBV slope Z-score crosses below its negative threshold
Short: newly confirmed OBV pivot low is lower than the previous confirmed OBV pivot low
Short: the latest two confirmed OBV highs are falling and the latest two confirmed OBV lows are falling, OR the most recent confirmed OBV pivot is a lower high
Short: on a confirmed price pivot high, the latest price pivot high is above the preceding price pivot high AND the latest confirmed OBV pivot high is below the preceding confirmed OBV pivot high AND the two price pivot highs are separated by at least the minimum and at most the maximum pivot bars AND the latest price and OBV pivot highs are within twice the right-pivot lookback bars of each other AND OBV slope Z-score is below the positive threshold