Calculation: HL2 = (high + low) / 2
Calculation: VPVAH(high, low, volume, lookback, rows) = value area high of the volume profile over the last lookback bars including the current bar, with rows equal-height price rows spanning the lowest low to the highest high of those bars and each bar's volume spread across rows in proportion to the overlap of the bar's high-low range with each row
Calculation: VPVAL(high, low, volume, lookback, rows) = value area low of the volume profile defined by VPVAH(high, low, volume, lookback, rows)
Long: close crosses above SMA(close, MA lookback)
Short: close crosses below SMA(close, MA lookback)
Long: close >= open AND HL2 > high[1]
Short: close < open AND HL2 < low[1]
Exit: long, low <= VPVAL(high, low, volume, put lookback, rows)
Exit: long, high >= VPVAH(high, low, volume, call lookback, rows)
Exit: short, high >= VPVAH(high, low, volume, put lookback, rows)
Exit: short, low <= VPVAL(high, low, volume, call lookback, rows)