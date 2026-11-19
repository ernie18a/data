Calculation: order-flow = EMA(close-position × relative-volume, pressure lookback), where close-position = 2 × (close − low) / (high − low) − 1 when high > low, else −1, and relative-volume = volume / SMA(volume, pressure lookback) when volume > 0 and SMA(volume, pressure lookback) > 0, else 1
Long: KAMA(close, efficiency lookback, fastest smoothing, slowest smoothing) > its value 1 bar ago
Short: KAMA(close, efficiency lookback, fastest smoothing, slowest smoothing) ≤ its value 1 bar ago
Long: close crosses above the latest confirmed pivot high, using the same swing lookback on both sides
Short: close crosses below the latest confirmed pivot low, using the same swing lookback on both sides
Long: order-flow ≥ 0
Short: order-flow < 0
Long: order-flow crosses above 0
Short: order-flow crosses below 0
Long: bullish structure break AND at least one of the previous order-block lookback bars has close < open
Short: bearish structure break AND at least one of the previous order-block lookback bars has close ≥ open
Long: low > high[2]
Short: high < low[2]