Calculation: opening-range high = highest high during the opening-range interval
Calculation: opening-range low = lowest low during the opening-range interval
Long: after the opening-range interval ends, close crosses above opening-range high
Short: after the opening-range interval ends, close crosses below opening-range low
Long: (on chart bars, close crosses above VWAP(hlc3, T1, bar still forming) AND RSI(close, RSI lookback, T1, bar still forming) > RSI threshold) OR (on chart bars, RSI(close, RSI lookback, T1, bar still forming) crosses above RSI threshold AND close > VWAP(hlc3, T1, bar still forming)
Short: on chart bars, close crosses below VWAP(hlc3, T1, bar still forming) AND RSI(close, RSI lookback, T1, bar still forming) < RSI threshold
Long: on chart bars, RSI(close, RSI lookback, T2, bar still forming) > RSI threshold
Short: on chart bars, RSI(close, RSI lookback, T2, bar still forming) < RSI threshold