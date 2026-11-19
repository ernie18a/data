Calculation: Selected Volatility Stop = Volatility Stop(source, lookback, ATR factor) on chart bars when no higher timeframe is selected, or on T1 using its last completed bar (or its still-forming bar when repainting is enabled), read on chart bars
Calculation: HTF breach = higher timeframe selected AND NOT Limbo AND crosses(chart close, Volatility Stop stop on T1)
Calculation: Limbo = (Limbo OR HTF breach) AND T1 trend state equals its previous chart-bar value
Long: Selected Volatility Stop trend state is up
Short: Selected Volatility Stop trend state is down
Long: T1 trend state is down AND equals its previous chart-bar value AND HTF breach
Short: T1 trend state is up AND equals its previous chart-bar value AND HTF breach