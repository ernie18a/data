Calculation: Volume ratio = volume / SMA(volume, volume lookback)
Calculation: Blow-off top = volume ratio >= blow-off volume multiple AND high > low AND (high - MAX(open, close)) / (high - low) >= upper-wick ratio
Calculation: Fixed stop = entry price - hard-stop multiple × ATR(ATR lookback) on the entry bar
Calculation: Peak close = highest close since entry
Calculation: Trailing stop = peak close - trail-stop multiple × ATR(ATR lookback) on the current bar
Long: position is flat AND volume ratio >= volume-surge multiple AND close > open AND (close - low) / (high - low) >= minimum close-range fraction AND RSI(close, RSI lookback) < maximum RSI AND close > EMA(close, EMA lookback) AND NOT blow-off top
Short: blow-off top
Exit: Long, blow-off top OR (peak close has not reached the minimum gain percentage above entry price AND low <= fixed stop) OR (peak close has reached the minimum gain percentage above entry price AND low <= MAX(fixed stop, trailing stop))