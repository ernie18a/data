Calculation: WaveTrend = EMA of the normalized difference between HLC3 and its EMA, where the absolute deviation is EMA-smoothed; normalize by 0.015 times that smoothed deviation.
Calculation: WT2 = short SMA of WaveTrend.
Calculation: CMF = selected rolling aggregation of money-flow volume divided by the same aggregation of volume weight; money-flow volume is ((2 × close − true-range high − true-range low) / true range) × volume weight, where true-range high/low are max/min of the current high/low and previous close, and volume weight is volume raised to a configurable exponent, optionally multiplied by HLC3.
Calculation: CMF_p = CMF, or CMF scaled and shifted when percentage mode is enabled.
Calculation: Long stop level = signal-bar open − stop distance; long target level = signal-bar close + target distance.
Calculation: Short stop level = signal-bar open + stop distance; short target level = signal-bar close − target distance.
Long: WaveTrend crosses above oversold level 1 AND WaveTrend > WT2 AND CMF < upper small-CMF cutoff.
Short: WaveTrend crosses below overbought level 1 AND WT2 > WaveTrend AND CMF > lower small-CMF cutoff.
Exit: Long, when stop/target is enabled, low <= long stop level OR high >= long target level OR one-bar-lagged CMF_p crosses above the upper exit threshold.
Exit: Short, when stop/target is enabled, high >= short stop level OR low <= short target level OR one-bar-lagged CMF_p crosses below the lower exit threshold.