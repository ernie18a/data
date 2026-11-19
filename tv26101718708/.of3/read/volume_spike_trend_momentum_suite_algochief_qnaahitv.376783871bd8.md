Calculation: Long trailing stop = low - ATR(ATR lookback) * ATR multiplier on the first long-trend bar; otherwise max(previous long trailing stop, low - ATR(ATR lookback) * ATR multiplier)
Calculation: Short trailing stop = high + ATR(ATR lookback) * ATR multiplier on the first short-trend bar; otherwise min(previous short trailing stop, high + ATR(ATR lookback) * ATR multiplier)
Long: position is not long AND volume / SMA(volume, volume lookback) >= volume spike multiplier AND close > open AND close > EMA(close, baseline lookback)
Short: position is not short AND volume / SMA(volume, volume lookback) >= volume spike multiplier AND close < open AND close < EMA(close, baseline lookback)
Exit: long, close < long trailing stop
Exit: short, close > short trailing stop