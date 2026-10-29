Calculation: Support = most recent confirmed pivot low, where the low is lower than the lows of the configured number of bars before and after it
Calculation: Resistance = most recent confirmed pivot high, where the high is higher than the highs of the configured number of bars before and after it
Calculation: Support zone = support expanded above and below by the configured percentage buffer
Calculation: Resistance zone = resistance expanded above and below by the configured percentage buffer
Calculation: Bullish rejection candle = lower wick > candle body × configured wick ratio AND close > open; body = absolute difference between close and open; lower wick = lower of open and close minus low
Calculation: Bearish rejection candle = upper wick > candle body × configured wick ratio AND close < open; upper wick = high minus the higher of close and open
Calculation: Strong volume = volume > simple moving average of volume over the configured lookback × configured multiplier
Long: close is within the support zone AND bullish rejection candle AND strong volume
Short: close is within the resistance zone AND bearish rejection candle AND strong volume