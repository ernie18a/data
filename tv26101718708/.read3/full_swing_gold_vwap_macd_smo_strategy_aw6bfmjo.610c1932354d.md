Calculation: T1 VWAP = VWAP(low, volume, T1 period, current period still forming, calculated on chart bars)
Calculation: MACD histogram = MACD histogram(MACD source, shorter MACD lookback, longer MACD lookback, MACD signal lookback)
Calculation: Oscillator = TSI(close, shorter TSI lookback, longer TSI lookback) - EMA(TSI(close, shorter TSI lookback, longer TSI lookback), TSI signal lookback)
Long: close > T1 VWAP AND MACD histogram > MACD histogram[1] AND Oscillator > 0
Short: close < T1 VWAP AND MACD histogram < MACD histogram[1] AND Oscillator < 0
Exit: long, high >= entry price + close * long take-profit percentage OR low <= entry price - close * long stop-loss percentage
Exit: short, low <= entry price - close * short take-profit percentage OR high >= entry price + close * short stop-loss percentage