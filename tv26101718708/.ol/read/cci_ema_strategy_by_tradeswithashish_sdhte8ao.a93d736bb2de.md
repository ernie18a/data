Calculation: Long-lookback CCI = (hlc3 − SMA(hlc3, lookback)) / (0.015 × mean absolute deviation of hlc3 from that SMA over the lookback); its lookback is longer than the short-lookback CCI’s.
Calculation: Short-lookback CCI = same CCI calculation with a shorter lookback than the long-lookback CCI.
Calculation: Smoothed long-term EMA = EMA of EMA(close, lookback), using the same long-term lookback for both; the short-term EMA uses a shorter lookback.
Calculation: Long trailing stop = maximum of the previous stop, short-term EMA, and smoothed long-term EMA while long; initialize it to the maximum of the two EMAs.
Calculation: Short trailing stop = minimum of the previous stop, short-term EMA, and smoothed long-term EMA while short; initialize it to the minimum of the two EMAs.
Calculation: Long target = signal-bar OHLC4 × (1 + target percentage).
Calculation: Short target = signal-bar OHLC4 × (1 − target percentage).
Long: position is flat AND bar is complete AND close > smoothed long-term EMA AND close > open AND volume > its 20-bar SMA AND long-lookback CCI > 0 AND short-lookback CCI > 100 AND close > VWAP AND (close − low) / (high − low) > 0.6 AND volume > previous bar volume.
Short: position is flat AND bar is complete AND close < smoothed long-term EMA AND close < open AND volume > its 20-bar SMA AND long-lookback CCI < 0 AND short-lookback CCI < −100 AND close < VWAP AND (close − low) / (high − low) < 0.4 AND volume > previous bar volume.
Exit: Long, (long-lookback CCI < 0 OR close < smoothed long-term EMA OR close < short-term EMA) AND (low <= long trailing stop OR high >= long target)
Exit: Short, (long-lookback CCI > 0 OR close > smoothed long-term EMA OR close > short-term EMA) AND (high >= short trailing stop OR low <= short target)