Calculation: TrailingStopLong = IF(close > TrailingStopLong[1], MAX(price source - multiplier * ATR(atr lookback), TrailingStopLong[1]), price source - multiplier * ATR(atr lookback))
Long: close > EMA(close, shortest lookback) AND close > EMA(close, middle lookback) AND close > EMA(close, longest lookback) AND EMA(close, shortest lookback) > EMA(close, middle lookback) AND EMA(close, shortest lookback) > EMA(close, longest lookback) AND EMA(close, longest lookback) > EMA(close, longest lookback)[n] AND Highest(high, range lookback, T1, last completed bar) < close * (1 + percentage) AND close >= Lowest(low, range lookback, T1, last completed bar) * (1 + percentage)
Long: close > TrailingStopLong
Short: close <= TrailingStopLong
Long: close > SMA(close, SMA lookback)
Short: close <= SMA(close, SMA lookback)