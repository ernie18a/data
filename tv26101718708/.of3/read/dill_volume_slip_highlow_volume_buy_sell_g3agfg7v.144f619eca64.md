Calculation: Fast EMA = EMA(close, short EMA lookback), with short EMA lookback < middle EMA lookback < long EMA lookback
Calculation: Middle EMA = EMA(close, middle EMA lookback)
Calculation: Slow EMA = EMA(close, long EMA lookback)
Calculation: Average volume = SMA(volume, volume-average lookback)
Calculation: Session VWAP = VWAP(close)
Long: Fast EMA > Middle EMA AND Middle EMA > Slow EMA OR volume > Average volume * high-volume multiplier AND (close > open OR (chart timeframe is T1, T2, T3, or T4 AND close > Highest(high[1], breakout lookback) AND close > Session VWAP))
Short: Fast EMA < Middle EMA AND Middle EMA < Slow EMA OR volume > Average volume * high-volume multiplier AND (close < open OR (chart timeframe is T1, T2, T3, or T4 AND close < Lowest(low[1], breakout lookback) AND close < Session VWAP))