Calculation: volatility = volatility factor × highest(ATR(lookback), lookback × volatility-window multiplier)
Calculation: trend = 1 when close crosses above ZLEMA(close, lookback) + volatility, -1 when close crosses below ZLEMA(close, lookback) - volatility, otherwise the previous trend value (initially 0); calculated on timeframe bars
Long: trend(T1, current bar still forming; calculated on T1 bars and sampled on chart bars) == 1
Long: trend(T2, current bar still forming; calculated on T2 bars and sampled on chart bars) == 1
Long: trend(T3, current bar still forming; calculated on T3 bars and sampled on chart bars) == 1
Long: trend(T4, current bar still forming; calculated on T4 bars and sampled on chart bars) == 1
Long: trend(T5, current bar still forming; calculated on T5 bars and sampled on chart bars) == 1
Short: trend(T1, current bar still forming; calculated on T1 bars and sampled on chart bars) != 1
Short: trend(T2, current bar still forming; calculated on T2 bars and sampled on chart bars) != 1
Short: trend(T3, current bar still forming; calculated on T3 bars and sampled on chart bars) != 1
Short: trend(T4, current bar still forming; calculated on T4 bars and sampled on chart bars) != 1
Short: trend(T5, current bar still forming; calculated on T5 bars and sampled on chart bars) != 1