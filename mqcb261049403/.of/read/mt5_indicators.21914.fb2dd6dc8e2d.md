Calculation: Volume-weighted RSI close = (RSI of close − 50) × volume.
Calculation: Adjusted RSI open = previous bar's volume-weighted RSI close if abs(open − close) ≤ gap threshold; otherwise, (RSI of open − 50) × volume, using the same RSI period as volume-weighted RSI close.
Long: Volume-weighted RSI close ≥ adjusted RSI open.
Short: Volume-weighted RSI close < adjusted RSI open.