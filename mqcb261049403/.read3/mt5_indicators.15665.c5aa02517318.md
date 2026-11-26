Calculation: breakout run = if low < low[1], -min(lookback, count of consecutive bars from [1] within the prior lookback bars with low > low), else if high > high[1], min(lookback, count of consecutive bars from [1] within the prior lookback bars with high < high), else 0
Long: breakout run(chart bars, chart lookback) > 0
Short: breakout run(chart bars, chart lookback) < 0
Long: breakout run(T1 bars, T1 lookback), sampled on chart bars from the T1 bar corresponding to each chart bar's time, including the still-forming T1 bar, > 0
Short: breakout run(T1 bars, T1 lookback), sampled on chart bars from the T1 bar corresponding to each chart bar's time, including the still-forming T1 bar, < 0