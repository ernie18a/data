Calculation: opening-range high = maximum high on chart bars during the opening-range duration from session open, reset each session
Calculation: opening-range low = minimum low on chart bars during the opening-range duration from session open, reset each session
Long: RSI(close, RSI lookback, T1 forming bar, sampled on chart bars) > RSI threshold
Short: RSI(close, RSI lookback, T1 forming bar, sampled on chart bars) < RSI threshold
Long: opening range is set AND close crosses above opening-range high
Short: opening range is set AND close crosses below opening-range low
Long: (close crosses above VWAP(hlc3, T2 forming bar, sampled on chart bars) AND RSI(close, RSI lookback, T2 forming bar, sampled on chart bars) > RSI threshold) OR (RSI(close, RSI lookback, T2 forming bar, sampled on chart bars) crosses above RSI threshold AND close > VWAP(hlc3, T2 forming bar, sampled on chart bars))
Short: close crosses below VWAP(hlc3, T2 forming bar, sampled on chart bars) AND RSI(close, RSI lookback, T2 forming bar, sampled on chart bars) < RSI threshold