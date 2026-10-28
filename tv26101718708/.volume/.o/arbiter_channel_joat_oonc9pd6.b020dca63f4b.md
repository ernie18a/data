Calculation: Donchian midpoint = (highest high + lowest low) / 2 over a lookback
Calculation: Composite baseline = EMA of the weighted average of the enabled Donchian midpoints for conversion, base, their average (Span A), and Span B, optionally including close
Calculation: Channel width = EMA of (ATR × multiplier + EMA of absolute close−open body over a lookback × multiplier), floored at a minimum tick width
Calculation: Upper channel = composite baseline + channel width
Calculation: Lower channel = composite baseline − channel width
Long: close > upper channel AND composite baseline > its value at a shorter lookback ago AND prior trend state ≠ bullish
Short: close < lower channel AND composite baseline < its value at a shorter lookback ago AND prior trend state ≠ bearish