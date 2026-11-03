Calculation: Confirmed swing high/low = the most recent pivot high/low confirmed using the same number of bars on each side, including a pivot confirmed on the current bar.
Calculation: Bullish raw sweep = low < confirmed swing low AND close > confirmed swing low.
Calculation: Bearish raw sweep = high > confirmed swing high AND close < confirmed swing high.
Calculation: Sweep wick ratio = 0 if close = open; otherwise (min(open, close) - low) / abs(close - open) if a bullish raw sweep occurred, else (high - max(open, close)) / abs(close - open) if a bearish raw sweep occurred, else 0.
Calculation: Bullish sweep = bullish raw sweep AND sweep wick ratio >= minimum wick ratio.
Calculation: Bearish sweep = bearish raw sweep AND sweep wick ratio >= minimum wick ratio.
Long: Bullish sweep.
Short: Bearish sweep.
Long: Previous bar's bullish sweep = true AND previous bar's bearish sweep = false AND current bar's bullish sweep = false AND current bar's bearish sweep = false AND previous bar's ATR > 0.
Short: Previous bar's bearish sweep = true AND current bar's bullish sweep = false AND current bar's bearish sweep = false AND previous bar's ATR > 0.