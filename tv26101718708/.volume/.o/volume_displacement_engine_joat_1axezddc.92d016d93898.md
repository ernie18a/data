Calculation: Smoothed volume ratio = EMA(shorter-lookback SMA of volume / max(longer-lookback SMA of volume, 1), smoothing length)
Calculation: Prior rolling high/low = highest high / lowest low over the breakout lookback, excluding the current bar
Calculation: Long stop/target = entry price −/+ ATR at entry × stop multiplier × (1 / reward-to-risk ratio for stop; reward-to-risk ratio for target)
Calculation: Short stop/target = entry price +/− ATR at entry × stop multiplier × (1 / reward-to-risk ratio for stop; reward-to-risk ratio for target)
Long: bar is confirmed AND close > prior rolling high AND smoothed volume ratio >= normal-volume ceiling
Short: bar is confirmed AND close < prior rolling low AND smoothed volume ratio >= normal-volume ceiling
Exit: long, bar is confirmed AND (low <= long stop OR high >= long target)
Exit: short, bar is confirmed AND (high >= short stop OR low <= short target)