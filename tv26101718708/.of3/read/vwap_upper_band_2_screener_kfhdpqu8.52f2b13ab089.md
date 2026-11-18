Calculation: VWAP upper band 2 = VWAP((high + low + close) / 3, volume, current session) + band 2 multiplier * sqrt(max(sum(((high + low + close) / 3)^2 * volume, since session start) / sum(volume, since session start) - VWAP((high + low + close) / 3, volume, current session)^2, 0))
Long: close > VWAP upper band 2
Short: close <= VWAP upper band 2