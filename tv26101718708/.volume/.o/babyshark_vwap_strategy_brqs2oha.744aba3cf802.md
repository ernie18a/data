Calculation: Rolling volume-weighted mean = sum(close × volume) / sum(volume) over a lookback of chart bars; use the still-forming current bar.
Calculation: Rolling volume-weighted average absolute deviation = sum(volume × absolute(close − rolling volume-weighted mean)) / sum(volume) over the same lookback as the mean; use the still-forming current bar.
Calculation: Lower deviation band 2 = rolling volume-weighted mean − 2 × rolling volume-weighted average absolute deviation
Calculation: Upper deviation band 2 = rolling volume-weighted mean + 2 × rolling volume-weighted average absolute deviation
Calculation: OBV = cumulative volume added when close rises, subtracted when close falls, and unchanged when close is unchanged.
Calculation: OBV RSI = RSI of OBV, using one lookback for RSI.
Long: close ≤ lower deviation band 2 AND OBV RSI ≤ its lower threshold AND position is flat AND more than 10 bars have elapsed since the last exit
Short: close ≥ upper deviation band 2 AND OBV RSI ≥ its higher threshold AND position is flat AND more than 10 bars have elapsed since the last exit
Exit: long, close crosses above the rolling volume-weighted mean OR close < entry price × 0.994
Exit: short, close crosses below the rolling volume-weighted mean OR close > entry price × 1.006