Calculation: Body = abs(open - close)
Calculation: Candle range = high - low
Calculation: Lower wick = min(open, close) - low
Calculation: Upper wick = high - max(open, close)
Calculation: Long stop = at the long signal, low[1] - stop ATR multiplier × ATR(ATR lookback)
Calculation: Long target = at the long signal, close + reward-risk ratio × (close - long stop)
Calculation: Short stop = at the short signal, high[1] + stop ATR multiplier × ATR(ATR lookback)
Calculation: Short target = at the short signal, close - reward-risk ratio × (short stop - close)
Long: close > SMA(close, trend lookback) AND low <= lowest(low, zone lookback) × (1 + zone tolerance fraction) AND ((lower wick >= long-wick-to-body ratio × body AND upper wick <= opposing-wick fraction × body AND candle range > minimum-range ATR multiple × ATR(ATR lookback)) OR (open[1] > close[1] AND close > open AND close > open[1] AND open < close[1])) AND close > high[1] AND (volume filter disabled OR volume >= SMA(volume, volume lookback) × volume multiplier) AND (no previous entry OR current bar index - last entry bar > cooldown period)
Short: close < SMA(close, trend lookback) AND high >= highest(high, zone lookback) × (1 - zone tolerance fraction) AND ((upper wick >= long-wick-to-body ratio × body AND lower wick <= opposing-wick fraction × body AND candle range > minimum-range ATR multiple × ATR(ATR lookback)) OR (open[1] < close[1] AND close < open AND close < open[1] AND open > close[1])) AND close < low[1] AND (volume filter disabled OR volume >= SMA(volume, volume lookback) × volume multiplier) AND (no previous entry OR current bar index - last entry bar > cooldown period)
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target