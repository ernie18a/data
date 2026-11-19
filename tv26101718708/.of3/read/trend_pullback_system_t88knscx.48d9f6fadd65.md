Calculation: Bullish trend = close > SMA(close, longer lookback) AND SMA(close, shorter lookback) > SMA(close, longer lookback) AND SMA(close, longer lookback) > SMA(close, longer lookback)[1]
Calculation: Bearish trend = close < SMA(close, longer lookback) AND SMA(close, shorter lookback) < SMA(close, longer lookback) AND SMA(close, longer lookback) < SMA(close, longer lookback)[1]
Calculation: Swing low = low = Lowest(low, swing lookback)
Calculation: Swing high = high = Highest(high, swing lookback)
Calculation: Bullish defended support = Bullish trend AND Swing low
Calculation: Bearish defended resistance = Bearish trend AND Swing high
Calculation: Long entry setup = BarsSince(Bullish defended support) <= pullback-support lookback AND close > SMA(close, longer lookback) AND SMA(close, longer lookback) > SMA(close, longer lookback)[1] AND close > SMA(close, shorter lookback)
Calculation: Short entry setup = BarsSince(Bearish defended resistance) <= pullback-support lookback AND close < SMA(close, longer lookback) AND SMA(close, longer lookback) < SMA(close, longer lookback)[1] AND close < SMA(close, shorter lookback)
Calculation: Long stop level = Lowest(low, pullback-support lookback plus one bar) on each long entry setup; when diamond trailing is enabled, a long position and stop level exist, Bullish defended support holds, no short entry setup holds, and low > the existing long stop level, update it to low
Calculation: Long target level = Highest(high, pullback-support lookback plus one bar) on each long entry setup
Calculation: Short stop level = Highest(high, pullback-support lookback plus one bar) on each short entry setup; when diamond trailing is enabled, a short position and stop level exist, Bearish defended resistance holds, no long entry setup holds, and high < the existing short stop level, update it to high
Calculation: Short target level = Lowest(low, pullback-support lookback plus one bar) on each short entry setup
Long: Bullish defended support
Short: Bearish defended resistance
Long: Swing low AND NOT Bullish trend AND close > SMA(close, longer lookback)
Short: Swing high AND NOT Bearish trend AND close < SMA(close, longer lookback)
Long: Long entry setup
Short: Short entry setup
Exit: long, low <= long stop level OR high >= long target level
Exit: short, high >= short stop level OR low <= short target level