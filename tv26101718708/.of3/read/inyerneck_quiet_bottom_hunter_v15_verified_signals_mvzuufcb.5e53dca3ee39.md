Calculation: percentage drop from rolling high = (close - highest(high, high-lookback parameter)) / highest(high, high-lookback parameter) * 100
Calculation: volume-to-average ratio = volume / SMA(volume, volume-average lookback parameter)
Calculation: green-or-flat streak = number of consecutive bars through the current bar where close >= open
Long: percentage drop from rolling high <= minimum-drop parameter AND percentage drop from rolling high >= maximum-drop parameter AND volume-to-average ratio <= dry-volume parameter AND RSI(close, RSI lookback parameter) <= RSI threshold parameter AND green-or-flat streak >= streak-length parameter AND bar is confirmed
Exit: long, high >= entry price + profit-target parameter ticks OR low <= entry price - stop-loss parameter ticks