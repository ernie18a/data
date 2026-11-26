Calculation: weighted RSI(T, bar) = wA × RSI(close, lookbackA, T, bar) + wB × RSI(close, lookbackB, T, bar) + wB × RSI(close, lookbackC, T, bar) + wC × RSI(close, lookbackD, T, bar) + wD × RSI(close, lookbackE, T, bar)
Calculation: smoothed weighted RSI(T, bar) = weighted RSI(T, bar) / smoothing + smoothed weighted RSI(T, preceding bar) × (smoothing − 1) / smoothing; first value = weighted RSI(T, bar) / smoothing
Long: weighted RSI(chart bars, current bar) > smoothed weighted RSI(chart bars, current bar)
Short: weighted RSI(chart bars, current bar) < smoothed weighted RSI(chart bars, current bar)
Long: weighted RSI(T1, still-forming bar) > smoothed weighted RSI(T1, still-forming bar), sampled on chart bars
Short: weighted RSI(T1, still-forming bar) < smoothed weighted RSI(T1, still-forming bar), sampled on chart bars