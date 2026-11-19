Calculation: prediction line = VWAP(source) when smoothing is enabled and VWAP is selected; otherwise, when smoothing is enabled, the selected SMA, EMA, WMA, or RMA of (SMA(source, N) + sigma * (VWAP(source) - SMA(source, N)))[forecast offset] using the smoothing length; otherwise, (SMA(source, N) + sigma * (VWAP(source) - SMA(source, N)))[forecast offset]
Long: source crosses above prediction line - selected entry-band multiplier * STDEV(close, N) AND position is flat
Long: VWAP(source) > prediction line
Short: VWAP(source) <= prediction line
Long: source > prediction line + first-band multiplier * STDEV(close, N)
Short: source < prediction line - first-band multiplier * STDEV(close, N)
Exit: Long, high >= entry price * (1 + first take-profit distance)
Exit: Long, high >= entry price * (1 + second take-profit distance)
Exit: Long, high >= entry price * (1 + third take-profit distance)
Exit: Long, low <= entry price * (1 - initial stop distance)
Exit: Long, low <= highest high since entry * (1 - trailing-stop distance) AND highest high since entry >= entry price * (1 + first take-profit distance) AND trailing stop is enabled AND 100% minus the three take-profit quantity percentages is positive