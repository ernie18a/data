Calculation: Trailing bands = Raw upper band is (high + low) / 2 + ATR × multiplier; raw lower band is (high + low) / 2 - ATR × multiplier. The trailing lower band is the greater of the raw lower band and previous trailing lower band if the previous close was above the previous trailing lower band; otherwise it is the raw lower band. The trailing upper band is the lesser of the raw upper band and previous trailing upper band if the previous close was below the previous trailing upper band; otherwise it is the raw upper band. Initialize each trailing band to its raw band.
Calculation: Trend state = Initialize to 0. On each bar, set to -1 if close < trailing lower band; otherwise set to 1 if close > trailing upper band; otherwise retain the previous state.
Long: Trend state = 1
Long: Trend state = 1 AND previous trend state = -1
Short: Trend state != 1
Short: Trend state = -1 AND previous trend state = 1