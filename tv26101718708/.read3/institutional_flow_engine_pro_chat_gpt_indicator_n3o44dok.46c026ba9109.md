Calculation: RVOL = IF SMA(volume, volume lookback) > 0 THEN volume / SMA(volume, same volume lookback) ELSE 0
Calculation: Prior support = Lowest(low, failed-break lookback)[1]
Calculation: Prior resistance = Highest(high, failed-break lookback)[1]
Long: EMA(close, EMA lookback) > EMA(close, same EMA lookback)[EMA slope lag] AND close > EMA(close, same EMA lookback) AND close > open AND RVOL > RVOL threshold AND RSI(close, RSI lookback) > upper RSI threshold AND MACD histogram(close, fast lookback, slow lookback, signal lookback) > MACD histogram(close, same MACD lookbacks)[1]
Short: EMA(close, EMA lookback) < EMA(close, same EMA lookback)[EMA slope lag] AND close < EMA(close, same EMA lookback) AND close < open AND RVOL > RVOL threshold AND RSI(close, RSI lookback) < lower RSI threshold AND MACD histogram(close, fast lookback, slow lookback, signal lookback) < MACD histogram(close, same MACD lookbacks)[1]
Long: low > high[FVG gap lag]
Short: high < low[FVG gap lag]
Long: low < Prior support AND close > Prior support AND close > open AND RVOL > RVOL threshold
Short: high > Prior resistance AND close < Prior resistance AND close < open AND RVOL > RVOL threshold
Long: low < Lowest(low, liquidity lookback)[1] AND close > open
Short: high > Highest(high, same liquidity lookback)[1] AND close < open