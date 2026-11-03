Calculation: Average volume = simple moving average of volume over the lookback period
Calculation: High-volume bar = volume > average volume × volume threshold AND (minimum volume filter is disabled OR volume ≥ minimum volume filter)
Calculation: Block impact = 0 unless the bar is high-volume; on a high-volume bar with close > open, volume ÷ average volume ÷ impact normalization divisor × price factor; with close < open, the same value negated; otherwise 0. Price factor = 1 unless absolute price movement is enabled, then abs((close − open) ÷ open) × 10.
Calculation: Cumulative impact = previous cumulative impact × decay factor + current block impact; initialize to 0.
Calculation: Consecutive nonpositive-impact bars = consecutive bars with cumulative impact ≤ 0; consecutive nonnegative-impact bars = consecutive bars with cumulative impact ≥ 0. Reset each count when its respective condition fails.
Calculation: Bar range percentage = abs(high − low) ÷ ((high + low) ÷ 2) × 100.
Long: Cumulative impact crosses above 0 (current > 0 AND previous ≤ 0)
Long: A bearish exhaustion was active on the previous bar AND current high > the high of its first bar
Long: Current bar is high-volume AND close > open AND there is no stored sell signal from within the lookback period
Short: Cumulative impact crosses below 0 (current < 0 AND previous ≥ 0)
Short: A bullish exhaustion was active on the previous bar AND current low < the low of its first bar
Short: Current bar is high-volume AND close < open AND there is no stored buy signal from within the lookback period
Exit: Long, cumulative impact < −signal threshold
Exit: Short, cumulative impact > signal threshold