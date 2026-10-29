Calculation: Smoothed midpoint = moving average of (high of the bar with the highest selected OHLC field over its lookback + low of the bar with the lowest selected OHLC field over its separate lookback) / 2; use shorter lookbacks and smoothing for the first midpoint and longer lookbacks and smoothing for the second.
Calculation: Oscillator = first smoothed midpoint minus second smoothed midpoint.
Calculation: Direction = up when oscillator > its previous value, down when oscillator < its previous value, and previous direction when equal; initially undefined.
Long: Chart-timeframe direction = up.
Short: Chart-timeframe direction = down.
Long: Higher-timeframe last completed bar direction = up AND its preceding bar direction = down.
Short: Higher-timeframe last completed bar direction = down AND its preceding bar direction = up.
Exit: long, higher-timeframe last completed bar direction = down OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, higher-timeframe last completed bar direction = up OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.