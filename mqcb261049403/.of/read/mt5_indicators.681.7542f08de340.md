Calculation: Trend state = Initialize as bearish after sufficient Williams %R history. On each bar, set it bearish if Williams %R < -100 + threshold, then set it bullish if Williams %R > -threshold; otherwise retain its previous state. The bullish assignment takes precedence if both conditions hold.
Calculation: Higher-timeframe marked direction = The direction of the most recent trend-state change on the higher timeframe; initially undefined. Calculate using the still-forming higher-timeframe bar or a selected completed higher-timeframe bar.
Long: Chart-timeframe trend state changes from bearish to bullish.
Short: Chart-timeframe trend state changes from bullish to bearish.
Long: Higher-timeframe marked direction is bullish.
Short: Higher-timeframe marked direction is bearish.