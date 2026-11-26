Long: Supertrend(ATR lookback, ATR multiplier) is bullish
Short: Supertrend(ATR lookback, ATR multiplier) is bearish
Calculation: Deviation level(n) = flip close + direction × n × SMA(high - low, range lookback) × deviation multiplier, where direction is 1 for bullish and -1 for bearish
Exit: long, high > Deviation level(n) AND high[1] <= Deviation level(n), for each projected level n
Exit: short, low < Deviation level(n) AND low[1] >= Deviation level(n), for each projected level n