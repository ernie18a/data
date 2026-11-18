Calculation: delta ratio = EMA(volume × (close > open ? directional volume weight : other-bar volume weight), delta lookback) / EMA(volume × (close < open ? directional volume weight : other-bar volume weight), delta lookback)
Calculation: bullish alignment = delta ratio > delta balance threshold AND volatility-series close < EMA(volatility-series close, volatility EMA lookback)
Calculation: bearish alignment = delta ratio < delta balance threshold AND volatility-series close > EMA(volatility-series close, volatility EMA lookback)
Long: bullish alignment
Short: bearish alignment
Long: bullish alignment AND crosses above(close, VWAP - STDEV(close, gamma lookback) × gamma wall width)
Short: bearish alignment AND crosses below(close, VWAP + STDEV(close, gamma lookback) × gamma wall width)
Exit: long, bullish alignment AND crosses above(close, VWAP + STDEV(close, gamma lookback) × gamma wall width) AND NOT crosses above(close, VWAP - STDEV(close, gamma lookback) × gamma wall width)
Exit: short, bearish alignment AND crosses below(close, VWAP - STDEV(close, gamma lookback) × gamma wall width) AND NOT crosses below(close, VWAP + STDEV(close, gamma lookback) × gamma wall width)