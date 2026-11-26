Calculation: latest imbalance direction on T bars = bullish when low > high[2] AND (gap-size filter disabled OR low - high[2] >= minimum gap multiplier * ATR(ATR lookback) on T bars); bearish when high < low[2] AND (gap-size filter disabled OR low[2] - high >= minimum gap multiplier * ATR(ATR lookback) on T bars); otherwise retain the previous direction, initially none
Long: on chart bars, low > high[2] AND (gap-size filter disabled OR low - high[2] >= minimum gap multiplier * ATR(ATR lookback))
Short: on chart bars, high < low[2] AND (gap-size filter disabled OR low[2] - high >= minimum gap multiplier * ATR(ATR lookback))
Long: on chart bars taking values from the still-forming T1 bar, latest imbalance direction on T1 bars is bullish
Short: on chart bars taking values from the still-forming T1 bar, latest imbalance direction on T1 bars is bearish
Long: on chart bars taking values from the still-forming T2 bar, latest imbalance direction on T2 bars is bullish
Short: on chart bars taking values from the still-forming T2 bar, latest imbalance direction on T2 bars is bearish
Long: on chart bars taking values from the still-forming T3 bar, latest imbalance direction on T3 bars is bullish
Short: on chart bars taking values from the still-forming T3 bar, latest imbalance direction on T3 bars is bearish