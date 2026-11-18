Calculation: transformed price = sqrt((open^2 + high^2 + low^2 + close^2) / 8)
Calculation: lower band = SMA(transformed price, lookback) - SMA(high - low, same lookback) * multiplier
Calculation: upper band = SMA(transformed price, lookback) + SMA(high - low, same lookback) * multiplier
Long: transformed price crosses above upper band AND close > VWAP(ohlc4, T1, bar still forming, evaluated on chart bars)
Exit: long, transformed price crosses below lower band AND close < VWAP(ohlc4, T1, bar still forming, evaluated on chart bars)