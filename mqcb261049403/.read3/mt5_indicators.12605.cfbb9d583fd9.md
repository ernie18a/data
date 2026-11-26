Calculation: V = sum(applied price * selected volume, price lookback) / max(sum(selected volume, price lookback), 1)
Calculation: S = 100 * (V - lowest(V, extreme lookback)) / max(highest(V, extreme lookback) - lowest(V, extreme lookback), minimum price increment) - 50
Calculation: F = moving average(S, selected method, smoothing length, phase)
Long: F crosses above moving average(F, selected method, smoothing length, phase)
Short: F crosses below moving average(F, selected method, smoothing length, phase)