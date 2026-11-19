Calculation: basis = SMA(EMA(source price, lookback), lookback)
Calculation: deviation = EMA(abs(close − basis), 3 × lookback) × multiplier
Calculation: upper band = basis + deviation
Calculation: lower band = basis − deviation
Calculation: trend = 1 when close > upper band, −1 when close < lower band, otherwise its prior value; initially 0
Calculation: normalized volume = (volume − lowest(volume, int(lookback × multiplier))) ÷ (highest(volume, int(lookback × multiplier)) − lowest(volume, int(lookback × multiplier))) × 100
Calculation: bearish sweep strength = sum of stored normalized volume for active prior swing-high levels below high; store high[1] and normalized volume[1] when trend < 0, high[1] > high, high[2] < high[1], and high[1] < upper band; remove a level when high > level or upper band < level
Calculation: bullish sweep strength = sum of stored normalized volume for active prior swing-low levels above low; store low[1] and normalized volume[1] when trend > 0, low[1] < low, low[2] > low[1], and low[1] > lower band; remove a level when low < level or lower band > level
Long: trend crosses above 0
Short: trend crosses below 0
Long: bullish sweep strength > 0
Short: bearish sweep strength > 0
Long: bullish sweep strength > major sweep threshold
Short: bearish sweep strength > major sweep threshold
Long: trend crosses above 0 AND long entries are enabled AND position is flat or short
Short: trend crosses below 0 AND short entries are enabled AND position is flat or long
Exit: long, trend crosses below 0 AND short entries are disabled
Exit: short, trend crosses above 0 AND long entries are disabled