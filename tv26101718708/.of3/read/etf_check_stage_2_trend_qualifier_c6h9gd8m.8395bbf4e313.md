Calculation: Stage 2 Count = number of true among (close > SMA(close, mid lookback); close > SMA(close, slow lookback); SMA(close, fast lookback) > SMA(close, mid lookback); SMA(close, fast lookback) > SMA(close, slow lookback); SMA(close, slow lookback) > SMA(close, slow lookback)[slow slope lookback]; (close - lowest(low, year lookback)) / lowest(low, year lookback) * 100 >= min percent above low; (highest(high, year lookback) - close) / highest(high, year lookback) * 100 <= max percent below high; (close - SMA(close, fast lookback)) / SMA(close, fast lookback) * 100 >= -max percent below fast SMA)
Calculation: RS Strong(X) = close / X > SMA(close / X, RS lookback) AND SMA(close / X, RS lookback) > SMA(close / X, RS lookback)[RS slope lookback]
Calculation: Above Key MAs = close > EMA(close, EMA lookback) AND close > SMA(close, fast lookback)
Calculation: Higher Low = lowest(low, low window) > lowest(low, low window)[low window]
Calculation: Theme Score = number of true among (Stage 2 Count >= stage count threshold; Above Key MAs; RS Strong(S&P 500 close); RS Strong(Nasdaq 100 close); high > highest(high, high window)[1] OR Higher Low)
Calculation: RS Line = close / benchmark index close
Calculation: Leadership Confirmed = Theme Score >= theme threshold AND number of true among (Above Key MAs; 0 <= (close - EMA(close, EMA lookback)) / EMA(close, EMA lookback) * 100 <= max extension; Higher Low) >= entry threshold
Long: Stage 2 Count >= stage count threshold AND Stage 2 Count[1] < stage count threshold
Exit: long, Stage 2 Count[1] >= stage count threshold AND Stage 2 Count < stage count threshold
Long: benchmark index is not the traded instrument AND RS Line >= highest(RS Line, year lookback) AND RS Line[1] < highest(RS Line, year lookback)[1]
Long: Theme Score >= theme threshold AND Theme Score[1] < theme threshold
Long: Leadership Confirmed AND NOT Leadership Confirmed[1]