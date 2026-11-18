Calculation: MarketStructure(high, low, swing lookback) = 1 when the latest confirmed pivot high is greater than the previous confirmed pivot high AND the latest confirmed pivot low is greater than the previous confirmed pivot low; -1 when both latest pivots are lower than their previous pivots; otherwise 0. Pivots use the swing lookback on both sides. Calculate on T bars using the last completed T bar; chart bars take that value.
Long: MarketStructure(high, low, swing lookback, T1) > 0
Short: MarketStructure(high, low, swing lookback, T1) < 0
Long: MarketStructure(high, low, swing lookback, T2) > 0
Short: MarketStructure(high, low, swing lookback, T2) < 0
Long: MarketStructure(high, low, swing lookback, T3) > 0
Short: MarketStructure(high, low, swing lookback, T3) < 0
Long: MarketStructure(high, low, swing lookback, T4) > 0
Short: MarketStructure(high, low, swing lookback, T4) < 0
Long: MarketStructure(high, low, swing lookback, T5) > 0
Short: MarketStructure(high, low, swing lookback, T5) < 0
Long: MarketStructure(high, low, swing lookback, T6) > 0
Short: MarketStructure(high, low, swing lookback, T6) < 0