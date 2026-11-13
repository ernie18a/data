Calculation: ATR = Average True Range on chart timeframe
Calculation: UpperBand = EMA(close, long lookback) + ATR * buffer multiplier; LowerBand = EMA(close, long lookback) - ATR * buffer multiplier (same multiplier; each bar uses its own band values)
Calculation: ConfirmedAbove = close > UpperBand on each of the last N consecutive bars including the current bar (N >= 1); ConfirmedBelow = close < LowerBand on each of the last N consecutive bars including the current bar
Calculation: MACD histogram = (EMA(close, short lookback) - EMA(close, long lookback)) - EMA of that difference over a signal lookback
Calculation: StochK = SMA(100 * (close - lowest low) / (highest high - lowest low) over a lookback, smoothing length s); StochD = SMA(StochK, s)
Long: ConfirmedAbove is true on this bar AND was false on the previous bar AND (no earlier entry OR bars since the last entry of either side >= minimum spacing) AND position is not already long (flat or short; a short is reversed)
Long: close > EMA(close, long lookback) AND MACD histogram crosses above 0 AND RSI > a lower floor AND RSI < 50 AND MFI(typical price hlc3, volume) < 50
Short: ConfirmedBelow is true on this bar AND was false on the previous bar AND (no earlier entry OR bars since the last entry of either side >= minimum spacing) AND position is not already short (flat or long; a long is reversed)
Short: close < EMA(close, long lookback) AND MACD histogram crosses below 0 AND RSI > 50 AND RSI < an upper ceiling AND MFI(hlc3, volume) > 50
Exit: long, ConfirmedBelow is true on this bar AND was false on the previous bar AND (no earlier entry OR bars since the last entry >= minimum spacing)
Exit: long, low <= entry price - ATR * stop multiplier
Exit: short, close < EMA(close, long lookback) AND MACD histogram crosses below 0 AND RSI > 50 AND RSI < an upper ceiling AND MFI(hlc3, volume) > 50
Exit: short, high >= entry price + ATR * stop multiplier
Exit: short, low <= entry price - ATR * TP1 multiple (close part of the position)
Exit: short, low <= entry price - ATR * TP2 multiple, where TP2 multiple > TP1 multiple (close the remaining part)
Exit: short, (entry price - close) / ATR >= capitulation multiple AND (RSI <= oversold RSI threshold OR StochK <= oversold stoch threshold) AND StochK crosses above StochD