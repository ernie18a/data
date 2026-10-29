Calculation: Zero-lag EMA = EMA(close + (close − close[ floor((length − 1) / 2) ]), length)
Calculation: Volatility band = 1.2 × highest(ATR(length), 3 × length)
Calculation: Trend state on each requested timeframe = initially bearish; becomes bullish when that timeframe’s close crosses above its zero-lag EMA + volatility band; becomes bearish when its close crosses below its zero-lag EMA − volatility band; otherwise retains its previous state. For a higher requested timeframe, use the bar still forming; requested timeframes may be higher or lower than the chart timeframe.
Long: Trend state is bullish
Short: Trend state is bearish