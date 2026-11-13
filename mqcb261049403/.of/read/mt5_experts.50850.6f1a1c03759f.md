Calculation: LevelS = (H + L + O + C)/4 - k * (H - L), where H, L, O, C are the high, low, open and close of the last completed bar of a timeframe higher than the chart timeframe, and k is a fixed ratio between 0 and 1.
Long: previous completed chart bar low < LevelS AND previous completed chart bar close > LevelS
Short: previous completed chart bar low > LevelS AND previous completed chart bar close < LevelS
Exit: long, low <= entry price - D OR high >= entry price + D, where D is a fixed price distance
Exit: short, high >= entry price + D OR low <= entry price - D, where D is the same fixed price distance