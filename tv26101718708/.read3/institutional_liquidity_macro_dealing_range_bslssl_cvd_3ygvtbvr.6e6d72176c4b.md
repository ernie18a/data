Calculation: Bullish FVG = low > high[2] AND close[1] > high[2]; zone boundaries = high[2] and low
Calculation: Bearish FVG = high < low[2] AND close[1] < low[2]; zone boundaries = high and low[2]
Calculation: Consequent encroachment = (FVG top + FVG bottom) / 2
Calculation: Range equilibrium = (highest(high, range lookback) + lowest(low, range lookback)) / 2
Calculation: Range delta = 100 * (bullish candle volume sum - bearish candle volume sum) / (bullish candle volume sum + bearish candle volume sum), or 0 when the denominator is 0
Calculation: Demand zone = [low[n], high[n]], where n = 2 if close[2] <= open[2], otherwise n = 3 if close[3] <= open[3]
Calculation: Supply zone = [low[n], high[n]], where n = 2 if close[2] >= open[2], otherwise n = 3 if close[3] >= open[3]
Calculation: Zone CVD = sum of volume on bullish candles minus volume on bearish candles from the zone origin through the current bar, limited by a lookback parameter
Long: low > high[2] AND close[1] > high[2]
Short: high < low[2] AND close[1] < low[2]
Long: close > the upper boundary of an active, uninverted bearish FVG
Short: close < the lower boundary of an active, uninverted bullish FVG
Long: close[1] > open[1] AND (close[2] <= open[2] OR close[3] <= open[3]) AND abs(close[1] - open[1]) >= momentum multiplier * (ATR(S&D lookback)[1] if available, otherwise high[1] - low[1])
Short: close[1] < open[1] AND (close[2] >= open[2] OR close[3] >= open[3]) AND abs(close[1] - open[1]) >= momentum multiplier * (ATR(S&D lookback)[1] if available, otherwise high[1] - low[1])
Long: low <= an unswept level from PivotLow(low, left lookback, right lookback) AND close > that level AND (low > high[2] AND close[1] > high[2] OR close > the upper boundary of an active, uninverted bearish FVG) AND close <= range equilibrium
Short: high >= an unswept level from PivotHigh(high, left lookback, right lookback) AND close < that level AND (high < low[2] AND close[1] < low[2] OR close < the lower boundary of an active, uninverted bullish FVG) AND close >= range equilibrium
Long: Zone CVD > 0 AND ((high >= bottom of an active demand zone AND low <= top of that zone) OR (low <= Consequent encroachment of an accompanying bullish FVG AND high >= Consequent encroachment)) AND close <= range equilibrium
Short: Zone CVD < 0 AND ((high >= bottom of an active supply zone AND low <= top of that zone) OR (low <= Consequent encroachment of an accompanying bearish FVG AND high >= Consequent encroachment)) AND close >= range equilibrium
Long: lowest(low, range lookback) - ATR(range ATR lookback) * zone height multiplier <= close AND close <= lowest(low, range lookback) AND Range delta crosses above 0
Exit: long, high >= range equilibrium
Exit: long, high >= an active unswept PivotHigh level
Exit: long, high >= highest(high, range lookback) + ATR(range ATR lookback) * zone height multiplier
Exit: short, low <= range equilibrium
Exit: short, low <= an active unswept PivotLow level