Calculation: Swing bias = 0 initially; 1 on a confirmed pivot low(low, extreme swing lookback, extreme swing lookback); -1 on a confirmed pivot high(high, extreme swing lookback, extreme swing lookback), with a pivot low taking precedence if both confirm on the same bar.
Calculation: Active structure high = the latest confirmed pivot high(high, structure lookback, structure lookback), cleared after close crosses above it.
Calculation: Active structure low = the latest confirmed pivot low(low, structure lookback, structure lookback), cleared after close crosses below it.
Long: EMA(close, wave lookback) > EMA(close, wave lookback)[1]
Short: EMA(close, wave lookback) <= EMA(close, wave lookback)[1]
Long: confirmed pivot low(low, extreme swing lookback, extreme swing lookback)
Short: confirmed pivot high(high, extreme swing lookback, extreme swing lookback)
Long: confirmed pivot low(low, liquidity lookback, liquidity lookback)
Short: confirmed pivot high(high, liquidity lookback, liquidity lookback)
Long: close crosses above active structure high
Short: close crosses below active structure low
Long: volume <= SMA(volume, high-volume lookback) * high-volume multiplier AND (swing bias = 1 OR (swing bias = 0 AND close >= open))
Short: volume <= SMA(volume, high-volume lookback) * high-volume multiplier AND (swing bias = -1 OR (swing bias = 0 AND close < open))