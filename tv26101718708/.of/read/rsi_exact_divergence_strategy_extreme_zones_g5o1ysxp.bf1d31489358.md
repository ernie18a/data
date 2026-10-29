Calculation: RSI pivot high = an RSI value higher than the values on the same number of bars immediately before and after it; confirm after those following bars complete
Calculation: RSI pivot low = an RSI value lower than the values on the same number of bars immediately before and after it; confirm after those following bars complete
Calculation: Bearish divergence = a newly confirmed RSI pivot high has a higher price high and lower RSI than the immediately previous confirmed RSI pivot high, the previous pivot is no more than the maximum lookback bars before the current confirmation bar, and either pivot RSI is at or above the overbought threshold
Calculation: Bullish divergence = a newly confirmed RSI pivot low has a lower price low and higher RSI than the immediately previous confirmed RSI pivot low, the previous pivot is no more than the maximum lookback bars before the current confirmation bar, and either pivot RSI is at or below the oversold threshold
Long: Bullish divergence AND (HTF filter disabled OR previous completed higher-timeframe close > EMA of higher-timeframe closes)
Short: Bearish divergence AND (HTF filter disabled OR previous completed higher-timeframe close < EMA of higher-timeframe closes)
Exit: long, Bearish divergence
Exit: short, Bullish divergence