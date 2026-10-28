Calculation: Candle body size = |close − open|
Calculation: Wick tolerance = minimum price tick × wick-tolerance ticks
Long: close > open AND candle body size ≥ minimum body size AND (|high − close| ≤ wick tolerance OR |open − low| ≤ wick tolerance) AND (volume filter disabled OR volume > previous bar volume)
Short: close < open AND candle body size ≥ minimum body size AND (|high − open| ≤ wick tolerance OR |close − low| ≤ wick tolerance) AND (volume filter disabled OR volume > previous bar volume)