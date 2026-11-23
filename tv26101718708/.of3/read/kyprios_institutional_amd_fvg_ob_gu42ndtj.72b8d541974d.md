Calculation: strong body = ABS(close - open) > SMA(ABS(close - open), body lookback) * body multiplier
Calculation: high volume = volume > SMA(volume, volume lookback) * volume multiplier
Calculation: bullish impulse = close > open AND close > high[1] AND strong body AND high volume
Calculation: bearish impulse = close < open AND close < low[1] AND strong body AND high volume
Calculation: bullish HTF trend = close > EMA(close, HTF lookback, T1, last completed bar)
Calculation: bearish HTF trend = close < EMA(close, HTF lookback, T1, last completed bar)
Calculation: session = (hour(datetime) >= session 1 start AND hour(datetime) <= session 1 end) OR (hour(datetime) >= session 2 start AND hour(datetime) <= session 2 end)
Calculation: bullish manipulation = low < Lowest(low, range lookback)[manipulation sweep lookback] AND close > Lowest(low, range lookback) AND close > open AND ABS(close - open) > ATR(atr lookback) * manipulation body multiplier AND high volume AND session
Calculation: bearish manipulation = high > Highest(high, range lookback)[manipulation sweep lookback] AND close < Highest(high, range lookback) AND close < open AND ABS(close - open) > ATR(atr lookback) * manipulation body multiplier AND high volume AND session
Calculation: last pivot high(length) = most recent non-NA PivotHigh(high, length, length) value up to and including the current bar
Calculation: last pivot low(length) = most recent non-NA PivotLow(low, length, length) value up to and including the current bar
Long: PivotLow(low, structure pivot length, structure pivot length) > last pivot low(structure pivot length)[1]
Short: PivotHigh(high, structure pivot length, structure pivot length) > last pivot high(structure pivot length)[1]
Long: close > last pivot high(CHOCH pivot length) AND close[1] <= last pivot high(CHOCH pivot length)
Short: close < last pivot low(CHOCH pivot length) AND close[1] >= last pivot low(CHOCH pivot length)
Long: close > last pivot high(BOS pivot length) AND close[1] <= last pivot high(BOS pivot length) AND bullish impulse
Short: close < last pivot low(BOS pivot length) AND close[1] >= last pivot low(BOS pivot length) AND bearish impulse
Long: close[1] < open[1] AND close > high[1] AND close > open AND close - open > ATR(atr lookback) * OB impulse multiplier AND bullish HTF trend AND high volume
Short: close[1] > open[1] AND close < low[1] AND close < open AND open - close > ATR(atr lookback) * OB impulse multiplier AND bearish HTF trend AND high volume
Long: low > high[2] AND low - high[2] > ATR(atr lookback) * FVG gap multiplier AND bullish impulse AND bullish HTF trend AND session
Short: high < low[2] AND low[2] - high > ATR(atr lookback) * FVG gap multiplier AND bearish impulse AND bearish HTF trend AND session
Long: low < last pivot low(liquidity pivot length) AND close > last pivot low(liquidity pivot length)
Short: high > last pivot high(liquidity pivot length) AND close < last pivot high(liquidity pivot length)
Long: bullish manipulation
Short: bearish manipulation
Long: bullish manipulation AND bullish HTF trend AND close > high[1] AND ABS(close - open) > ATR(atr lookback) * distribution body multiplier AND high volume
Short: bearish manipulation AND bearish HTF trend AND close < low[1] AND ABS(close - open) > ATR(atr lookback) * distribution body multiplier AND high volume