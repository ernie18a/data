Calculation: Bullish regime = trend source > SMA of trend source AND RSI of RSI source >= bullish range lower bound AND RSI <= bullish range upper bound for at least the required number of consecutive bars. The trend source and RSI source are independently selected backtest data series.
Calculation: Bearish regime = trend source < SMA of trend source AND RSI of RSI source >= bearish range lower bound AND RSI <= bearish range upper bound for at least the same required number of consecutive bars.
Calculation: Bullish transition = bullish regime is true on the current chart bar AND was false on the preceding chart bar AND (higher-timeframe filter is disabled OR bullish regime is true on the last completed higher-timeframe bar) AND (ADX filter is disabled OR ADX >= minimum strength). The higher-timeframe regime uses the same sources, lengths, range bounds, and confirmation count as the chart-timeframe regime. ADX uses the same length for directional movement and ADX smoothing.
Calculation: Bearish transition = bearish regime is true on the current chart bar AND was false on the preceding chart bar AND (higher-timeframe filter is disabled OR bearish regime is true on the last completed higher-timeframe bar) AND (ADX filter is disabled OR ADX >= minimum strength). The higher-timeframe regime uses the same sources, lengths, range bounds, and confirmation count as the chart-timeframe regime.
Long: bullish regime is true
Long: bullish transition is true
Short: bearish regime is true
Short: bearish transition is true
Exit: long, bearish transition is true
Exit: short, bullish transition is true